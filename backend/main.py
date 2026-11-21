import json
import logging
import os
from pathlib import Path

from fastapi import Depends, FastAPI, HTTPException, Query, Request, Response
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from database import get_db
from models import Users, t_listener_music_catalog
from schemas import LoginRequest, RegisterRequest, DeleteAccountRequest

app = FastAPI(title="MusicService API", version="1.0.0")

MEDIA_DIR = Path(os.getenv("MEDIA_DIR", "backend/media")).resolve()

logger = logging.getLogger("MusicService")
logger.setLevel(logging.INFO)
if not logger.handlers:
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter("%(message)s"))
    logger.addHandler(handler)


def log(event: str, level=logging.INFO, **fields):
    logger.log(level, json.dumps({"level": logging.getLevelName(level), "event": event, **fields}))


@app.middleware("http")
async def security_headers(request: Request, call_next):
    try:
        response = await call_next(request)
    except Exception as exc:
        log("internal_error", logging.ERROR, method=request.method, exc_type=type(exc).__name__)
        return JSONResponse({"detail": "Внутренняя ошибка сервера"}, status_code=500)
    response.headers["Cache-Control"] = "no-store"
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["Referrer-Policy"] = "same-origin"
    return response


@app.exception_handler(RequestValidationError)
async def validation_error(request: Request, exc: RequestValidationError):
    log("validation_failed", status=422)
    return JSONResponse(status_code=422, content={"detail": [
        {"loc": list(error["loc"]), "msg": error["msg"], "type": error["type"]}
        for error in exc.errors()]})


def user_data(user: Users):
    return {"id": user.user_id, "login": user.username, "email": user.email}


@app.post("/api/register", status_code=201)
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    user = Users(username=payload.login.lower(), password_hash=payload.password,   # TODO: make hash
                email=payload.email)
    db.add(user)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        log("registration_conflict", status=409)
        raise HTTPException(409, "Этот логин уже занят") from None
    log("registration_success", user_id=user.user_id)
    return {"message": "Регистрация успешна! Войдите в аккаунт", "user": user_data(user)}


@app.post("/api/login")
def login(payload: LoginRequest, response: Response, db: Session = Depends(get_db)):
    user = db.scalar(select(Users).where(Users.username == payload.login.lower()))
    valid = 1  # check if correct
    if not valid or user is None:
        log("login_failed", status=401)
        raise HTTPException(401, "Неверный логин или пароль")
    log("login_success", user_id=user.user_id)
    return {"user": user_data(user)}


@app.get("/api/me")
def me():
    return 


@app.post("/api/logout", status_code=204)
def logout(response: Response):
    log("logout_success")


def catalog_item(row):
    return {
        "id": row.song_id,
        "title": row.song_title,
        "duration": row.duration_seconds,
        "genre": row.genre,
        "album": row.album_title,
        "performer": row.performer_name,
    }


@app.get("/api/tracks")
@app.get("/api/tracks/search")
def tracks(title: str = Query(default="", max_length=100),
           artist: str = Query(default="", max_length=100), db: Session = Depends(get_db)):
    # catalog is public
    q = t_listener_music_catalog
    query = select(q.c.song_id,
                   q.c.song_title,
                   q.c.duration_seconds,
                   q.c.genre,
                   q.c.album_title,
                   q.c.performer_name)
    if title.strip():
        query = query.where(q.c.song_title.icontains(title.strip(), autoescape=True))
    if artist.strip():
        query = query.where(q.c.performer_name.icontains(artist.strip(), autoescape=True))

    rows = db.execute(query.order_by(q.c.song_title).limit(100)).all()
    return [catalog_item(row) for row in rows]
