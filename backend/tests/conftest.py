import sys
import uuid
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select

from database import DATABASE_URL, get_db
import main
from models import Base, Users, Albums, Songs, t_listener_music_catalog


def cleanup_user(db_session, username):
    user = db_session.scalar(select(Users).where(Users.username == username.lower()))
    if user:
        db_session.delete(user)
        db_session.commit()

@pytest.fixture(scope="session")
def engine():
    return create_engine(DATABASE_URL)

@pytest.fixture
def db_session(engine):
    Session = sessionmaker(bind=engine)
    session = Session()
    try:
        yield session
    finally:
        session.close()

@pytest.fixture
def client(db_session):
    def override_get_db():
        yield db_session
    main.app.dependency_overrides[get_db] = override_get_db
    with TestClient(main.app) as c:
        yield c
    main.app.dependency_overrides.clear()

@pytest.fixture
def media_dir(tmp_path, monkeypatch):
    """Подменяет MEDIA_DIR на временную папку на время теста."""
    monkeypatch.setattr(main, "MEDIA_DIR", tmp_path)
    return tmp_path

@pytest.fixture
def client_access(client, db_session):
    username = f"user_{uuid.uuid4().hex[:8]}"
    client.post("/api/register", json={
        "login": username, "password": "Secret123!",
        "email": f"{username}@e.com",
    })
    user = db_session.scalar(select(Users).where(Users.username == username))
    user.access = 1
    db_session.commit()
    client.post("/api/login", json={"login": username, "password": "Secret123!"})
    yield client
    cleanup_user(db_session, username)

@pytest.fixture
def make_album(db_session):
    def _make(title="Test album"):
        from models import Albums  # подставь реальное имя модели альбома
        album = Albums(title=title, musician_id=1)  # имена полей подгони под модель
        db_session.add(album)
        db_session.commit()
        return album
    return _make

@pytest.fixture
def make_song(db_session, media_dir, make_album):
    counter = iter(range(1000))

    def _make(access=1, file_path=None, content=b"some-mp3-bytes"):
        n = next(counter)
        fp = file_path or f"songs/test_{n}.mp3"
        (media_dir / fp).parent.mkdir(parents=True, exist_ok=True)
        (media_dir / fp).write_bytes(content)
        song = Songs(
            album_id=make_album().album_id,  # ← обязательный FK
            title=f"Test track {n}",
            track_number=1,                  # ← NOT NULL
            duration_seconds=67,            # ← NOT NULL
            file_path=fp,
            access=access,
            genre="test",                    # ← NOT NULL
        )
        db_session.add(song)
        db_session.commit()
        return song
    return _make
