import uuid

from models import Users
from conftest import cleanup_user

def unique_username(prefix="test"):
    return f"{prefix}_{uuid.uuid4().hex[:8]}"


def test_register_success(client, db_session):
    username = unique_username("reg")
    try:
        r = client.post("/api/register", json={
            "login": username,
            "password": "Secret123!",
            "email": f"{username}@example.com",
        })
        assert r.status_code == 201
        assert r.json()["user"]["login"] == username.lower()
    finally:
        cleanup_user(db_session, username)


def test_register_duplicate_username(client, db_session):
    username = unique_username("dup")
    payload = {"login": username, "password": "Secret123!", "email": f"{username}@e.com"}
    try:
        client.post("/api/register", json=payload)
        r = client.post("/api/register", json={**payload, "email": f"{username}2@e.com"})
        assert r.status_code == 409
    finally:
        cleanup_user(db_session, username)


def test_register_duplicate_email(client, db_session):
    username = unique_username("email")
    email = f"{username}@example.com"
    payload = {"login": username, "password": "Secret123!", "email": email}
    try:
        client.post("/api/register", json=payload)
        other_username = unique_username("email2")
        r = client.post("/api/register", json={
            "login": other_username,
            "password": "Secret123!",
            "email": email,
        })
        assert r.status_code == 409
        cleanup_user(db_session, other_username)
    finally:
        cleanup_user(db_session, username)


def test_register_weak_password(client):
    r = client.post("/api/register", json={
        "login": unique_username("weak"),
        "password": "short",
        "email": f"{uuid.uuid4().hex[:8]}@example.com",
    })
    assert r.status_code == 422


def test_login_success(client, db_session):
    username = unique_username("log")
    try:
        client.post("/api/register", json={
            "login": username,
            "password": "Secret123!",
            "email": f"{username}@e.com",
        })
        r = client.post("/api/login", json={"login": username, "password": "Secret123!"})
        assert r.status_code == 200
        assert r.json()["user"]["login"] == username.lower()
    finally:
        cleanup_user(db_session, username)


def test_login_unknown_user(client):
    r = client.post("/api/login", json={"login": "no_such_user", "password": "x"})
    assert r.status_code == 401


def test_logout(client):
    r = client.post("/api/logout")
    assert r.status_code == 204


def test_tracks_returns_list(client):
    r = client.get("/api/tracks")
    assert r.status_code == 200
    assert isinstance(r.json(), list)


def test_tracks_search_by_title(client):
    r = client.get("/api/tracks/search", params={"title": "a"})
    assert r.status_code == 200
    assert isinstance(r.json(), list)


def test_tracks_search_by_artist(client):
    r = client.get("/api/tracks/search", params={"artist": "a"})
    assert r.status_code == 200
    assert isinstance(r.json(), list)


def test_stream_unauthorized(client):
    r = client.get("/api/tracks/1/stream")
    assert r.status_code == 401


def test_stream_track_not_found(client_access):
    r = client_access.get("/api/tracks/999999/stream")
    assert r.status_code == 404


def test_stream_success(client_access, make_song):
    c = b"\xff\xfb\x90\x00some-mp3-data"
    song = make_song(access=1, content=c)
    r = client_access.get(f"/api/tracks/{song.song_id}/stream")
    assert r.status_code == 200
    assert r.content == c


def test_stream_access_denied(client_access, db_session, make_song):
    song = make_song(access=2)
    r = client_access.get(f"/api/tracks/{song.song_id}/stream")
    assert r.status_code == 403


def test_path_traversal(client_access, db_session, tmp_path, make_song):
    secret = tmp_path / "secret.txt"
    secret.write_text("top secret")
    song = make_song(access=1)
    song.file_path = "../secret.txt"
    db_session.commit()
    r = client_access.get(f"/api/tracks/{song.song_id}/stream")
    assert r.status_code == 404


def test_stream_track_metadata(client, make_song):
    song = make_song(access=2)
    r = client.get(f"/api/tracks/{song.song_id}")
    assert r.status_code == 200
    assert r.json()["title"] == song.title


def test_no_such_file(client_access, db_session, media_dir, make_song):
    song = make_song(access=1)
    song.file_path = "not_file.mp3"
    db_session.commit()
    r = client_access.get(f"/api/tracks/{song.song_id}/stream")
    assert r.status_code == 404