from typing import Optional
import datetime

from sqlalchemy import BigInteger, Boolean, CheckConstraint, Column, Date, DateTime, ForeignKeyConstraint, Identity, Index, Integer, PrimaryKeyConstraint, String, Table, Text, UniqueConstraint, text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship

class Base(DeclarativeBase):
    pass


t_listener_music_catalog = Table(
    'listener_music_catalog', Base.metadata,
    Column('song_id', Integer),
    Column('song_title', String(200)),
    Column('duration_seconds', Integer),
    Column('genre', String(50)),
    Column('album_title', String(200)),
    Column('release_date', Date),
    Column('access', Integer),
    Column('performer_name', String),
    Column('performer_type', Text)
)


class MainLog(Base):
    __tablename__ = 'main_log'
    __table_args__ = (
        PrimaryKeyConstraint('log_id', name='main_log_pkey'),
    )

    log_id: Mapped[int] = mapped_column(BigInteger, Identity(always=True, start=1, increment=1, minvalue=1, maxvalue=9223372036854775807, cycle=False, cache=1), primary_key=True, autoincrement=True)
    table_name: Mapped[str] = mapped_column(Text, nullable=False)
    operation_type: Mapped[str] = mapped_column(Text, nullable=False)
    operation_time: Mapped[datetime.datetime] = mapped_column(DateTime(True), nullable=False, server_default=text('now()'))
    user_operator: Mapped[str] = mapped_column(Text, nullable=False, server_default=text('CURRENT_USER'))
    old_data: Mapped[Optional[object]] = mapped_column(JSONB)
    new_data: Mapped[Optional[object]] = mapped_column(JSONB)


class Users(Base):
    __tablename__ = 'users'
    __table_args__ = (
        PrimaryKeyConstraint('user_id', name='users_pkey'),
        UniqueConstraint('email', name='users_email_key'),
        UniqueConstraint('username', name='users_username_key')
    )

    user_id: Mapped[int] = mapped_column(Integer, Identity(always=True, start=1, increment=1, minvalue=1, maxvalue=2147483647, cycle=False, cache=1), primary_key=True, autoincrement=True)
    username: Mapped[str] = mapped_column(String(50), nullable=False)
    email: Mapped[str] = mapped_column(String(255), nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    is_musician: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default=text('false'))
    access: Mapped[int] = mapped_column(Integer, nullable=False, server_default=text('0'))

    bands: Mapped[list['Bands']] = relationship('Bands', back_populates='owner_user')
    musicians: Mapped[list['Musicians']] = relationship('Musicians', back_populates='owner_user')


class Bands(Base):
    __tablename__ = 'bands'
    __table_args__ = (
        ForeignKeyConstraint(['owner_user_id'], ['users.user_id'], ondelete='SET NULL', name='bands_owner_user_id_fkey'),
        PrimaryKeyConstraint('band_id', name='bands_pkey'),
        Index('idx_bands_owner', 'owner_user_id')
    )

    band_id: Mapped[int] = mapped_column(Integer, Identity(always=True, start=1, increment=1, minvalue=1, maxvalue=2147483647, cycle=False, cache=1), primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    formed_date: Mapped[Optional[int]] = mapped_column(Integer)
    country: Mapped[Optional[str]] = mapped_column(String(100))
    description: Mapped[Optional[str]] = mapped_column(Text)
    owner_user_id: Mapped[Optional[int]] = mapped_column(Integer)

    owner_user: Mapped[Optional['Users']] = relationship('Users', back_populates='bands')
    albums: Mapped[list['Albums']] = relationship('Albums', back_populates='band')


class Musicians(Base):
    __tablename__ = 'musicians'
    __table_args__ = (
        ForeignKeyConstraint(['owner_user_id'], ['users.user_id'], ondelete='SET NULL', name='musicians_owner_user_id_fkey'),
        PrimaryKeyConstraint('musician_id', name='musicians_pkey'),
        Index('idx_musicians_owner', 'owner_user_id')
    )

    musician_id: Mapped[int] = mapped_column(Integer, Identity(always=True, start=1, increment=1, minvalue=1, maxvalue=2147483647, cycle=False, cache=1), primary_key=True, autoincrement=True)
    first_name: Mapped[str] = mapped_column(String(100), nullable=False)
    last_name: Mapped[str] = mapped_column(String(100), nullable=False)
    stage_name: Mapped[Optional[str]] = mapped_column(String(150))
    country: Mapped[Optional[str]] = mapped_column(String(100))
    biography: Mapped[Optional[str]] = mapped_column(Text)
    owner_user_id: Mapped[Optional[int]] = mapped_column(Integer)

    owner_user: Mapped[Optional['Users']] = relationship('Users', back_populates='musicians')
    albums: Mapped[list['Albums']] = relationship('Albums', back_populates='musician')


class Albums(Base):
    __tablename__ = 'albums'
    __table_args__ = (
        CheckConstraint('musician_id IS NOT NULL AND band_id IS NULL OR musician_id IS NULL AND band_id IS NOT NULL', name='chk_album_artist'),
        ForeignKeyConstraint(['band_id'], ['bands.band_id'], ondelete='RESTRICT', name='albums_band_id_fkey'),
        ForeignKeyConstraint(['musician_id'], ['musicians.musician_id'], ondelete='RESTRICT', name='albums_musician_id_fkey'),
        PrimaryKeyConstraint('album_id', name='albums_pkey'),
        Index('idx_albums_band', 'band_id'),
        Index('idx_albums_musician', 'musician_id')
    )

    album_id: Mapped[int] = mapped_column(Integer, Identity(always=True, start=1, increment=1, minvalue=1, maxvalue=2147483647, cycle=False, cache=1), primary_key=True, autoincrement=True)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    musician_id: Mapped[Optional[int]] = mapped_column(Integer)
    band_id: Mapped[Optional[int]] = mapped_column(Integer)
    release_date: Mapped[Optional[datetime.date]] = mapped_column(Date)
    cover_url: Mapped[Optional[str]] = mapped_column(String(500))

    band: Mapped[Optional['Bands']] = relationship('Bands', back_populates='albums')
    musician: Mapped[Optional['Musicians']] = relationship('Musicians', back_populates='albums')
    songs: Mapped[list['Songs']] = relationship('Songs', back_populates='album')


class Songs(Base):
    __tablename__ = 'songs'
    __table_args__ = (
        CheckConstraint('duration_seconds > 0', name='songs_duration_seconds_check'),
        CheckConstraint('track_number > 0', name='songs_track_number_check'),
        ForeignKeyConstraint(['album_id'], ['albums.album_id'], ondelete='CASCADE', name='songs_album_id_fkey'),
        PrimaryKeyConstraint('song_id', name='songs_pkey'),
        UniqueConstraint('album_id', 'track_number', name='songs_album_id_track_number_key'),
        Index('idx_songs_album', 'album_id'),
        Index('idx_songs_genre', 'genre'),
        Index('idx_songs_title', 'title')
    )

    song_id: Mapped[int] = mapped_column(Integer, Identity(always=True, start=1, increment=1, minvalue=1, maxvalue=2147483647, cycle=False, cache=1), primary_key=True, autoincrement=True)
    album_id: Mapped[int] = mapped_column(Integer, nullable=False)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    track_number: Mapped[int] = mapped_column(Integer, nullable=False)
    duration_seconds: Mapped[int] = mapped_column(Integer, nullable=False)
    file_path: Mapped[str] = mapped_column(String(500), nullable=False)
    access: Mapped[int] = mapped_column(Integer, nullable=False, server_default=text('0'))
    genre: Mapped[Optional[str]] = mapped_column(String(50))

    album: Mapped['Albums'] = relationship('Albums', back_populates='songs')
