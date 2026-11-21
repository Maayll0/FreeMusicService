import json
import logging
import os
from pathlib import Path
import time
import jwt

from fastapi import Cookie, Depends, FastAPI, HTTPException, Query, Request, Response
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from database import get_db
from models import Users, t_listener_music_catalog
from schemas import LoginRequest, RegisterRequest, DeleteAccountRequest
from security import hash_password, verify_password

app = FastAPI(title="MusicService API", version="1.0.0")

COOKIE = "musicaccess_session"
SECURE_COOKIE = os.getenv("APP_ENV", "development") == "production"
SESSION_SECONDS = 60 * 60 * 72     # 3 days
MEDIA_DIR = Path(os.getenv("MEDIA_DIR", "backend/media")).resolve()
SECRET = os.getenv("JWT_SECRET")
if not SECRET:
    raise RuntimeError("JWT_SECRET не задан")
ALGO = "HS256"
DEFAULT_HASH = 'Password_123'

logger = logging.getLogger("MusicService")
logger.setLevel(logging.INFO)
if not logger.handlers:
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter("%(message)s"))
    logger.addHandler(handler)


def log(event: str, level=logging.INFO, **fields):
    logger.log(level, json.dumps({"level": logging.getLevelName(level), "event": event, **fields}))


def create_token(user_id: int) -> str:
    now = int(time.time())
    payload = {"sub": str(user_id), "iat": now, "exp": now + SESSION_SECONDS}
    return jwt.encode(payload, SECRET, algorithm=ALGO)


def current_user(
    token: str | None = Cookie(default=None, alias=COOKIE),
    db: Session = Depends(get_db),
):
    if not token:
        raise HTTPException(401, "Войдите в аккаунт")
    try:
        payload = jwt.decode(token, SECRET, algorithms=[ALGO])
    except jwt.ExpiredSignatureError:
        raise HTTPException(401, "Сессия истекла")
    except jwt.InvalidTokenError:
        raise HTTPException(401, "Сессия недействительна")
    user = db.get(Users, int(payload["sub"]))
    if user is None:
        raise HTTPException(401, "Войдите в аккаунт")
    return user


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
    user = Users(username=payload.login.lower(), password_hash=hash_password(payload.password),
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
    valid = verify_password(payload.password, user.password_hash if user else DEFAULT_HASH)
    if not valid or user is None:
        log("login_failed", status=401)
        raise HTTPException(401, "Неверный логин или пароль")
    response.set_cookie(
        COOKIE, create_token(user.user_id), max_age=SESSION_SECONDS,
        httponly=True, secure=SECURE_COOKIE, samesite="lax", path="/",
    )
    log("login_success", user_id=user.user_id)
    return {"user": user_data(user)}


@app.get("/api/me")
def me(user: Users = Depends(current_user)):
    return {"user": user_data(user)}


@app.post("/api/logout", status_code=204)
def logout(response: Response):
    response.delete_cookie(COOKIE, path="/", httponly=True,
                           secure=SECURE_COOKIE, samesite="lax")
    log("logout_success")


@app.delete("/api/me", status_code=204)
def delete_account(payload: DeleteAccountRequest, response: Response,
                   user: Users = Depends(current_user), db: Session = Depends(get_db)):
    if not verify_password(payload.password, user.password_hash):
        raise HTTPException(400, "Неверный пароль")
    db.delete(user)
    db.commit()
    response.delete_cookie(COOKIE, path="/", httponly=True,
                           secure=SECURE_COOKIE, samesite="lax")
    log("account_deleted", user_id=user.user_id)


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
