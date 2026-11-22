--
-- PostgreSQL database dump
--

\restrict F47Ofx70UosbetNDRCPjA3NQlpBTtqIJGNoBerHND09kqtweCbkzwUG4KQDEgpO

-- Dumped from database version 17.11 (Debian 17.11-1.pgdg13+2)
-- Dumped by pg_dump version 17.11 (Debian 17.11-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: albums; Type: TABLE; Schema: public; Owner: music_BD
--

CREATE TABLE public.albums (
    album_id integer NOT NULL,
    title character varying(200) NOT NULL,
    musician_id integer,
    band_id integer,
    release_date date,
    cover_url character varying(500),
    CONSTRAINT chk_album_artist CHECK ((((musician_id IS NOT NULL) AND (band_id IS NULL)) OR ((musician_id IS NULL) AND (band_id IS NOT NULL))))
);


ALTER TABLE public.albums OWNER TO "music_BD";

--
-- Name: albums_album_id_seq; Type: SEQUENCE; Schema: public; Owner: music_BD
--

ALTER TABLE public.albums ALTER COLUMN album_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.albums_album_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: bands; Type: TABLE; Schema: public; Owner: music_BD
--

CREATE TABLE public.bands (
    band_id integer NOT NULL,
    name character varying(150) NOT NULL,
    formed_date integer,
    country character varying(100),
    description text,
    owner_user_id integer
);


ALTER TABLE public.bands OWNER TO "music_BD";

--
-- Name: bands_band_id_seq; Type: SEQUENCE; Schema: public; Owner: music_BD
--

ALTER TABLE public.bands ALTER COLUMN band_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.bands_band_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: musicians; Type: TABLE; Schema: public; Owner: music_BD
--

CREATE TABLE public.musicians (
    musician_id integer NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    stage_name character varying(150),
    country character varying(100),
    biography text,
    owner_user_id integer
);


ALTER TABLE public.musicians OWNER TO "music_BD";

--
-- Name: songs; Type: TABLE; Schema: public; Owner: music_BD
--

CREATE TABLE public.songs (
    song_id integer NOT NULL,
    album_id integer NOT NULL,
    title character varying(200) NOT NULL,
    track_number integer NOT NULL,
    duration_seconds integer NOT NULL,
    genre character varying(50),
    file_path character varying(500) NOT NULL,
    access integer DEFAULT 0 NOT NULL,
    CONSTRAINT songs_duration_seconds_check CHECK ((duration_seconds > 0)),
    CONSTRAINT songs_track_number_check CHECK ((track_number > 0))
);


ALTER TABLE public.songs OWNER TO "music_BD";

--
-- Name: listener_music_catalog; Type: VIEW; Schema: public; Owner: music_BD
--

CREATE VIEW public.listener_music_catalog AS
 SELECT s.song_id,
    s.title AS song_title,
    s.duration_seconds,
    s.genre,
    a.title AS album_title,
    a.release_date,
    s.access,
    COALESCE(b.name, m.stage_name, (concat_ws(' '::text, m.first_name, m.last_name))::character varying) AS performer_name,
        CASE
            WHEN (m.musician_id IS NOT NULL) THEN 'Musician'::text
            ELSE 'Band'::text
        END AS performer_type
   FROM (((public.songs s
     JOIN public.albums a ON ((a.album_id = s.album_id)))
     LEFT JOIN public.musicians m ON ((m.musician_id = a.musician_id)))
     LEFT JOIN public.bands b ON ((b.band_id = a.band_id)));


ALTER VIEW public.listener_music_catalog OWNER TO "music_BD";

--
-- Name: main_log; Type: TABLE; Schema: public; Owner: music_BD
--

CREATE TABLE public.main_log (
    log_id bigint NOT NULL,
    table_name text NOT NULL,
    operation_type text NOT NULL,
    operation_time timestamp with time zone DEFAULT now() NOT NULL,
    user_operator text DEFAULT CURRENT_USER NOT NULL,
    old_data jsonb,
    new_data jsonb
);


ALTER TABLE public.main_log OWNER TO "music_BD";

--
-- Name: main_log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: music_BD
--

ALTER TABLE public.main_log ALTER COLUMN log_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.main_log_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: musicians_musician_id_seq; Type: SEQUENCE; Schema: public; Owner: music_BD
--

ALTER TABLE public.musicians ALTER COLUMN musician_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.musicians_musician_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: songs_song_id_seq; Type: SEQUENCE; Schema: public; Owner: music_BD
--

ALTER TABLE public.songs ALTER COLUMN song_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.songs_song_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: music_BD
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    is_musician boolean DEFAULT false NOT NULL,
    access integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.users OWNER TO "music_BD";

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: music_BD
--

ALTER TABLE public.users ALTER COLUMN user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: albums; Type: TABLE DATA; Schema: public; Owner: music_BD
--

COPY public.albums (album_id, title, musician_id, band_id, release_date, cover_url) FROM stdin;
1	Tales from the Kingdom of Fife	\N	1	2013-03-29	\N
2	Space 1992: Rise of the Chaos Wizards	\N	1	2015-09-25	\N
3	Legends from Beyond the Galactic Terrorvortex	\N	1	2019-05-31	\N
4	Return to the Kingdom of Fife	\N	1	2023-06-02	\N
5	Space 1993: Wrath of Kor-Virliath	\N	1	2026-10-16	\N
6	He Has Returned	\N	1	2024-11-29	\N
7	No Grave But the Sea	\N	2	2017-05-26	\N
8	SHAMAN	8	\N	2024-01-01	\N
9	The Last Stand	\N	4	2016-08-19	\N
10	Toxicity	\N	5	2001-09-04	\N
11	Utiliarian	\N	6	2012-02-28	\N
12	Siege Ubsessed!	\N	7	2023-02-03	\N
13	The Last Stand	\N	4	2016-08-19	\N
14	Toxicity	\N	5	2001-09-04	\N
15	Utiliarian	\N	6	2012-02-28	\N
16	Siege Ubsessed!	\N	7	2023-02-03	\N
17	Die Urkatastrophe	\N	8	2024-09-20	\N
20	Test album	1	\N	\N	\N
21	Test album	1	\N	\N	\N
22	Test album	1	\N	\N	\N
23	Test album	1	\N	\N	\N
24	Test album	1	\N	\N	\N
25	Test album	1	\N	\N	\N
26	Test album	1	\N	\N	\N
27	Test album	1	\N	\N	\N
28	Test album	1	\N	\N	\N
29	Test album	1	\N	\N	\N
30	Test album	1	\N	\N	\N
31	Test album	1	\N	\N	\N
32	Test album	1	\N	\N	\N
33	Test album	1	\N	\N	\N
34	Test album	1	\N	\N	\N
35	Test album	1	\N	\N	\N
36	Test album	1	\N	\N	\N
37	Test album	1	\N	\N	\N
38	Test album	1	\N	\N	\N
39	Test album	1	\N	\N	\N
40	Test album	1	\N	\N	\N
\.


--
-- Data for Name: bands; Type: TABLE DATA; Schema: public; Owner: music_BD
--

COPY public.bands (band_id, name, formed_date, country, description, owner_user_id) FROM stdin;
1	Gloryhammer	2010	United Kingdom		5
2	Alestorm	2004	Scotland		7
3	Angus McSix	2022	Switzerland		6
4	Sabaton	1999	Sweden		\N
5	System of a Down	1994	U.S.		\N
6	Napalm Death	1981	England		\N
7	Curta’n Wall	2020	U.S.		\N
8	Kanonenfieber	2020	Germany		\N
\.


--
-- Data for Name: main_log; Type: TABLE DATA; Schema: public; Owner: music_BD
--

COPY public.main_log (log_id, table_name, operation_type, operation_time, user_operator, old_data, new_data) FROM stdin;
1	bands	I	2026-11-07 00:40:37.934066+00	postgres	\N	{"name": "Kanonenfieber", "band_id": 8, "country": "Germany", "description": null, "formed_date": 2020, "owner_user_id": null}
2	bands	U	2026-11-07 00:44:02.302407+00	postgres	{"name": "Kanonenfieber", "band_id": 8, "country": "Germany", "description": null, "formed_date": 2020, "owner_user_id": null}	{"name": "Kanonenfieber", "band_id": 8, "country": "Germany", "description": "Their lyrics are generally centered on World War I.", "formed_date": 2020, "owner_user_id": null}
3	bands	I	2026-11-07 00:45:21.58799+00	postgres	\N	{"name": "test", "band_id": 9, "country": "Russia", "description": null, "formed_date": 0, "owner_user_id": null}
4	bands	D	2026-11-07 00:45:56.129963+00	postgres	{"name": "test", "band_id": 9, "country": "Russia", "description": null, "formed_date": 0, "owner_user_id": null}	\N
5	musicians	I	2026-11-21 14:38:33.744008+00	postgres	\N	{"country": "Russia", "biography": "Russian singer known for patriotic songs", "last_name": "Dronov", "first_name": "Yaroslav", "stage_name": "SHAMAN", "musician_id": 8, "owner_user_id": null}
6	albums	I	2026-11-21 14:40:16.909328+00	postgres	\N	{"title": "SHAMAN", "band_id": null, "album_id": 8, "cover_url": null, "musician_id": 8, "release_date": "2024-01-01"}
7	songs	I	2026-11-21 14:42:29.397111+00	postgres	\N	{"genre": "pop", "title": "Встанем", "access": 0, "song_id": 16, "album_id": 8, "file_path": "", "track_number": 1, "duration_seconds": 240}
8	songs	I	2026-11-21 14:42:29.397111+00	postgres	\N	{"genre": "pop", "title": "Я русский", "access": 0, "song_id": 17, "album_id": 8, "file_path": "", "track_number": 2, "duration_seconds": 220}
9	albums	I	2026-11-21 14:57:20.940554+00	postgres	\N	{"title": "The Last Stand", "band_id": 4, "album_id": 9, "cover_url": null, "musician_id": null, "release_date": "2016-08-19"}
10	albums	I	2026-11-21 14:57:20.946334+00	postgres	\N	{"title": "Toxicity", "band_id": 5, "album_id": 10, "cover_url": null, "musician_id": null, "release_date": "2001-09-04"}
11	albums	I	2026-11-21 14:57:20.948403+00	postgres	\N	{"title": "Utiliarian", "band_id": 6, "album_id": 11, "cover_url": null, "musician_id": null, "release_date": "2012-02-28"}
12	albums	I	2026-11-21 14:57:20.950148+00	postgres	\N	{"title": "Siege Ubsessed!", "band_id": 7, "album_id": 12, "cover_url": null, "musician_id": null, "release_date": "2023-02-03"}
13	albums	I	2026-11-21 14:59:13.55034+00	postgres	\N	{"title": "The Last Stand", "band_id": 4, "album_id": 13, "cover_url": null, "musician_id": null, "release_date": "2016-08-19"}
14	songs	I	2026-11-21 14:59:13.555261+00	postgres	\N	{"genre": "power metal", "title": "The Last Stand", "access": 0, "song_id": 22, "album_id": 9, "file_path": "", "track_number": 1, "duration_seconds": 250}
15	songs	I	2026-11-21 14:59:13.555261+00	postgres	\N	{"genre": "power metal", "title": "Sparta", "access": 0, "song_id": 23, "album_id": 9, "file_path": "", "track_number": 2, "duration_seconds": 230}
16	albums	I	2026-11-21 14:59:13.557237+00	postgres	\N	{"title": "Toxicity", "band_id": 5, "album_id": 14, "cover_url": null, "musician_id": null, "release_date": "2001-09-04"}
17	songs	I	2026-11-21 14:59:13.558576+00	postgres	\N	{"genre": "nu metal", "title": "Chop Suey!", "access": 0, "song_id": 24, "album_id": 10, "file_path": "", "track_number": 1, "duration_seconds": 210}
18	songs	I	2026-11-21 14:59:13.558576+00	postgres	\N	{"genre": "nu metal", "title": "Toxicity", "access": 0, "song_id": 25, "album_id": 10, "file_path": "", "track_number": 2, "duration_seconds": 220}
19	albums	I	2026-11-21 14:59:13.560084+00	postgres	\N	{"title": "Utiliarian", "band_id": 6, "album_id": 15, "cover_url": null, "musician_id": null, "release_date": "2012-02-28"}
20	songs	I	2026-11-21 14:59:13.561083+00	postgres	\N	{"genre": "grindcore", "title": "The Wolf I Feed", "access": 0, "song_id": 26, "album_id": 11, "file_path": "", "track_number": 5, "duration_seconds": 177}
21	songs	I	2026-11-21 14:59:13.561083+00	postgres	\N	{"genre": "grindcore", "title": "Fall on Their Swords", "access": 0, "song_id": 27, "album_id": 11, "file_path": "", "track_number": 7, "duration_seconds": 237}
22	albums	I	2026-11-21 14:59:13.562318+00	postgres	\N	{"title": "Siege Ubsessed!", "band_id": 7, "album_id": 16, "cover_url": null, "musician_id": null, "release_date": "2023-02-03"}
23	songs	I	2026-11-21 14:59:13.563604+00	postgres	\N	{"genre": "black metal", "title": "Elephantry", "access": 0, "song_id": 28, "album_id": 12, "file_path": "", "track_number": 3, "duration_seconds": 191}
24	songs	I	2026-11-21 14:59:13.563604+00	postgres	\N	{"genre": "black metal", "title": "Siege Ubsessed", "access": 0, "song_id": 29, "album_id": 12, "file_path": "", "track_number": 2, "duration_seconds": 213}
25	songs	I	2026-11-21 15:02:33.0702+00	postgres	\N	{"genre": "nu metal", "title": "Boom!", "access": 0, "song_id": 30, "album_id": 10, "file_path": "", "track_number": 3, "duration_seconds": 135}
26	songs	I	2026-11-21 15:02:33.0702+00	postgres	\N	{"genre": "nu metal", "title": "Soldier Side", "access": 0, "song_id": 31, "album_id": 10, "file_path": "", "track_number": 4, "duration_seconds": 220}
27	songs	U	2026-11-21 15:05:15.731308+00	postgres	{"genre": "nu metal", "title": "Chop Suey!", "access": 0, "song_id": 24, "album_id": 10, "file_path": "", "track_number": 1, "duration_seconds": 210}	{"genre": "nu metal", "title": "Chop Suey!", "access": 2, "song_id": 24, "album_id": 10, "file_path": "", "track_number": 1, "duration_seconds": 210}
28	songs	U	2026-11-21 15:05:15.731308+00	postgres	{"genre": "nu metal", "title": "Toxicity", "access": 0, "song_id": 25, "album_id": 10, "file_path": "", "track_number": 2, "duration_seconds": 220}	{"genre": "nu metal", "title": "Toxicity", "access": 2, "song_id": 25, "album_id": 10, "file_path": "", "track_number": 2, "duration_seconds": 220}
29	songs	U	2026-11-21 15:05:15.731308+00	postgres	{"genre": "nu metal", "title": "Boom!", "access": 0, "song_id": 30, "album_id": 10, "file_path": "", "track_number": 3, "duration_seconds": 135}	{"genre": "nu metal", "title": "Boom!", "access": 2, "song_id": 30, "album_id": 10, "file_path": "", "track_number": 3, "duration_seconds": 135}
30	songs	U	2026-11-21 15:05:15.731308+00	postgres	{"genre": "nu metal", "title": "Soldier Side", "access": 0, "song_id": 31, "album_id": 10, "file_path": "", "track_number": 4, "duration_seconds": 220}	{"genre": "nu metal", "title": "Soldier Side", "access": 2, "song_id": 31, "album_id": 10, "file_path": "", "track_number": 4, "duration_seconds": 220}
31	songs	U	2026-11-21 15:06:03.510181+00	postgres	{"genre": "epic power metal", "title": "He Has Returned", "access": 0, "song_id": 8, "album_id": 6, "file_path": "song1.mp3", "track_number": 1, "duration_seconds": 265}	{"genre": "epic power metal", "title": "He Has Returned", "access": 1, "song_id": 8, "album_id": 6, "file_path": "song1.mp3", "track_number": 1, "duration_seconds": 265}
32	songs	U	2026-11-21 15:06:03.510181+00	postgres	{"genre": "epic power metal", "title": "The Siege of Dunkeld (In Hoots We Trust)", "access": 0, "song_id": 9, "album_id": 3, "file_path": "song2.mp3", "track_number": 2, "duration_seconds": 286}	{"genre": "epic power metal", "title": "The Siege of Dunkeld (In Hoots We Trust)", "access": 1, "song_id": 9, "album_id": 3, "file_path": "song2.mp3", "track_number": 2, "duration_seconds": 286}
33	songs	U	2026-11-21 15:06:03.510181+00	postgres	{"genre": "epic power metal", "title": "Masters of the Galaxy", "access": 0, "song_id": 10, "album_id": 3, "file_path": "song3.mp3", "track_number": 3, "duration_seconds": 265}	{"genre": "epic power metal", "title": "Masters of the Galaxy", "access": 1, "song_id": 10, "album_id": 3, "file_path": "song3.mp3", "track_number": 3, "duration_seconds": 265}
34	songs	U	2026-11-21 15:06:03.510181+00	postgres	{"genre": "epic power metal", "title": "The Land of Unicorns", "access": 0, "song_id": 11, "album_id": 3, "file_path": "song4.mp3", "track_number": 4, "duration_seconds": 264}	{"genre": "epic power metal", "title": "The Land of Unicorns", "access": 1, "song_id": 11, "album_id": 3, "file_path": "song4.mp3", "track_number": 4, "duration_seconds": 264}
35	songs	U	2026-11-21 15:06:03.510181+00	postgres	{"genre": "epic power metal", "title": "Power of the Laser Dragon Fire", "access": 0, "song_id": 12, "album_id": 3, "file_path": "song5.mp3", "track_number": 5, "duration_seconds": 306}	{"genre": "epic power metal", "title": "Power of the Laser Dragon Fire", "access": 1, "song_id": 12, "album_id": 3, "file_path": "song5.mp3", "track_number": 5, "duration_seconds": 306}
36	songs	U	2026-11-21 15:06:03.510181+00	postgres	{"genre": "epic power metal", "title": "Gloryhammer", "access": 0, "song_id": 13, "album_id": 3, "file_path": "song6.mp3", "track_number": 7, "duration_seconds": 300}	{"genre": "epic power metal", "title": "Gloryhammer", "access": 1, "song_id": 13, "album_id": 3, "file_path": "song6.mp3", "track_number": 7, "duration_seconds": 300}
37	songs	U	2026-11-21 15:06:03.510181+00	postgres	{"genre": "epic power metal", "title": "Hootsforce", "access": 0, "song_id": 14, "album_id": 3, "file_path": "song7.mp3", "track_number": 8, "duration_seconds": 230}	{"genre": "epic power metal", "title": "Hootsforce", "access": 1, "song_id": 14, "album_id": 3, "file_path": "song7.mp3", "track_number": 8, "duration_seconds": 230}
38	users	D	2026-11-21 15:10:08.962103+00	postgres	{"email": "l04@example.test", "access": 0, "user_id": 4, "username": "listener4", "is_musician": false, "password_hash": "hash_l04"}	\N
39	playlists	D	2026-11-21 15:10:08.962103+00	postgres	{"title": "Избранное", "user_id": 4, "description": "", "playlist_id": 4}	\N
40	playlists	D	2026-11-21 15:10:08.962103+00	postgres	{"title": "Для наблюдения за муравьями", "user_id": 4, "description": "", "playlist_id": 6}	\N
41	playlists	D	2026-11-21 15:10:08.962103+00	postgres	{"title": "Избранное", "user_id": 4, "description": "", "playlist_id": 11}	\N
42	playlists	D	2026-11-21 15:10:08.962103+00	postgres	{"title": "Для наблюдения за муравьями", "user_id": 4, "description": "", "playlist_id": 13}	\N
43	listening_stats	D	2026-11-21 15:10:08.962103+00	postgres	{"song_id": 9, "user_id": 4, "is_liked": true, "play_count": 6, "last_listened_at": "2026-10-07T22:10:00"}	\N
44	listening_stats	D	2026-11-21 15:10:08.962103+00	postgres	{"song_id": 8, "user_id": 4, "is_liked": true, "play_count": 42, "last_listened_at": "2026-10-03T12:34:56"}	\N
45	users	U	2026-11-21 15:11:32.674885+00	postgres	{"email": "l02@example.test", "access": 0, "user_id": 2, "username": "listener2", "is_musician": false, "password_hash": "hash_l02"}	{"email": "l02@example.test", "access": 1, "user_id": 2, "username": "listener2", "is_musician": false, "password_hash": "hash_l02"}
46	users	U	2026-11-21 15:11:42.074568+00	postgres	{"email": "l03@example.test", "access": 0, "user_id": 3, "username": "listener3", "is_musician": false, "password_hash": "hash_l03"}	{"email": "l03@example.test", "access": 2, "user_id": 3, "username": "listener3", "is_musician": false, "password_hash": "hash_l03"}
47	musicians	U	2026-11-21 15:21:36.047052+00	postgres	{"country": "Russia", "biography": "Russian singer known for patriotic songs", "last_name": "Dronov", "first_name": "Yaroslav", "stage_name": "SHAMAN", "musician_id": 8, "owner_user_id": null}	{"country": "Russia", "biography": "Russian singer known for an absence of talent", "last_name": "Dronov", "first_name": "Yaroslav", "stage_name": "SHAMAN", "musician_id": 8, "owner_user_id": null}
48	bands	U	2026-11-21 15:22:32.220101+00	postgres	{"name": "Gloryhammer", "band_id": 1, "country": "United Kingdom", "description": "", "formed_date": 2010, "owner_user_id": 5}	{"name": "Gloryhammer", "band_id": 1, "country": "United Kingdom", "description": "", "formed_date": 2010, "owner_user_id": 5}
49	bands	U	2026-11-21 15:22:32.220101+00	postgres	{"name": "Alestorm", "band_id": 2, "country": "Scotland", "description": "", "formed_date": 2004, "owner_user_id": 7}	{"name": "Alestorm", "band_id": 2, "country": "Scotland", "description": "", "formed_date": 2004, "owner_user_id": 7}
50	bands	U	2026-11-21 15:22:32.220101+00	postgres	{"name": "Angus McSix", "band_id": 3, "country": "Switzerland", "description": "", "formed_date": 2022, "owner_user_id": 6}	{"name": "Angus McSix", "band_id": 3, "country": "Switzerland", "description": "", "formed_date": 2022, "owner_user_id": 6}
51	bands	U	2026-11-21 15:22:32.220101+00	postgres	{"name": "Sabaton", "band_id": 4, "country": "Sweden", "description": "", "formed_date": 1999, "owner_user_id": null}	{"name": "Sabaton", "band_id": 4, "country": "Sweden", "description": "", "formed_date": 1999, "owner_user_id": null}
52	bands	U	2026-11-21 15:22:32.220101+00	postgres	{"name": "System of a Down", "band_id": 5, "country": "U.S.", "description": "", "formed_date": 1994, "owner_user_id": null}	{"name": "System of a Down", "band_id": 5, "country": "U.S.", "description": "", "formed_date": 1994, "owner_user_id": null}
53	bands	U	2026-11-21 15:22:32.220101+00	postgres	{"name": "Napalm Death", "band_id": 6, "country": "England", "description": "", "formed_date": 1981, "owner_user_id": null}	{"name": "Napalm Death", "band_id": 6, "country": "England", "description": "", "formed_date": 1981, "owner_user_id": null}
54	bands	U	2026-11-21 15:22:32.220101+00	postgres	{"name": "Curta’n Wall", "band_id": 7, "country": "U.S.", "description": "", "formed_date": 2020, "owner_user_id": null}	{"name": "Curta’n Wall", "band_id": 7, "country": "U.S.", "description": "", "formed_date": 2020, "owner_user_id": null}
55	bands	U	2026-11-21 15:22:32.220101+00	postgres	{"name": "Kanonenfieber", "band_id": 8, "country": "Germany", "description": "Their lyrics are generally centered on World War I.", "formed_date": 2020, "owner_user_id": null}	{"name": "Kanonenfieber", "band_id": 8, "country": "Germany", "description": "", "formed_date": 2020, "owner_user_id": null}
56	albums	I	2026-11-21 15:28:15.541477+00	postgres	\N	{"title": "Die Urkatastrophe", "band_id": 8, "album_id": 17, "cover_url": null, "musician_id": null, "release_date": "2024-09-20"}
57	songs	I	2026-11-21 15:29:42.193482+00	postgres	\N	{"genre": "blackened death metal", "title": "Menschenmühle", "access": 0, "song_id": 32, "album_id": 17, "file_path": "", "track_number": 2, "duration_seconds": 219}
58	songs	I	2026-11-21 15:29:42.193482+00	postgres	\N	{"genre": "blackened death metal", "title": "Sturmtrupp", "access": 0, "song_id": 33, "album_id": 17, "file_path": "", "track_number": 3, "duration_seconds": 272}
59	songs	I	2026-11-21 15:29:42.193482+00	postgres	\N	{"genre": "blackened death metal", "title": "Panzerhenker", "access": 0, "song_id": 34, "album_id": 17, "file_path": "", "track_number": 8, "duration_seconds": 309}
60	users	U	2026-11-21 15:46:52.832671+00	postgres	{"email": "l01@example.test", "access": 0, "user_id": 1, "username": "listener1", "is_musician": false, "password_hash": "hash_l01"}	{"email": "l01@example.test", "access": 0, "user_id": 1, "username": "listener1", "is_musician": false, "password_hash": "$argon2id$v=19$m=65536,t=3,p=2$HQ6jTbioBVqu6gOcqFmRlg$8D2m1W+TsZEvn7NC+B4JOsmwrfKdo+84hEsXl8z8Ofg"}
61	users	U	2026-11-21 15:46:52.841077+00	postgres	{"email": "l02@example.test", "access": 1, "user_id": 2, "username": "listener2", "is_musician": false, "password_hash": "hash_l02"}	{"email": "l02@example.test", "access": 1, "user_id": 2, "username": "listener2", "is_musician": false, "password_hash": "$argon2id$v=19$m=65536,t=3,p=2$2zEWRUlb474Edr0MGx9/bw$WKgQ1CgziimfrTCSSR2+Ipy/hN1XYc+A2NvfVJMEPrk"}
62	users	U	2026-11-21 15:46:52.842611+00	postgres	{"email": "l03@example.test", "access": 2, "user_id": 3, "username": "listener3", "is_musician": false, "password_hash": "hash_l03"}	{"email": "l03@example.test", "access": 2, "user_id": 3, "username": "listener3", "is_musician": false, "password_hash": "$argon2id$v=19$m=65536,t=3,p=2$pNwk+HEElvTssH+NznGOJg$nhorf/Rmp8S2BuH+NSNcu4N3ftothTYBW6IGF9+sBlo"}
63	songs	U	2026-11-21 16:07:42.938699+00	postgres	{"genre": "pop", "title": "Встанем", "access": 0, "song_id": 16, "album_id": 8, "file_path": "", "track_number": 1, "duration_seconds": 240}	{"genre": "pop", "title": "Встанем", "access": 0, "song_id": 16, "album_id": 8, "file_path": "song8", "track_number": 1, "duration_seconds": 240}
64	songs	U	2026-11-21 16:07:42.938699+00	postgres	{"genre": "pop", "title": "Я русский", "access": 0, "song_id": 17, "album_id": 8, "file_path": "", "track_number": 2, "duration_seconds": 220}	{"genre": "pop", "title": "Я русский", "access": 0, "song_id": 17, "album_id": 8, "file_path": "song8", "track_number": 2, "duration_seconds": 220}
65	songs	U	2026-11-21 16:08:31.879988+00	postgres	{"genre": "pop", "title": "Встанем", "access": 0, "song_id": 16, "album_id": 8, "file_path": "song8", "track_number": 1, "duration_seconds": 240}	{"genre": "pop", "title": "Встанем", "access": 0, "song_id": 16, "album_id": 8, "file_path": "song8.mp3", "track_number": 1, "duration_seconds": 240}
66	songs	U	2026-11-21 16:08:31.879988+00	postgres	{"genre": "pop", "title": "Я русский", "access": 0, "song_id": 17, "album_id": 8, "file_path": "song8", "track_number": 2, "duration_seconds": 220}	{"genre": "pop", "title": "Я русский", "access": 0, "song_id": 17, "album_id": 8, "file_path": "song8.mp3", "track_number": 2, "duration_seconds": 220}
67	songs	U	2026-11-21 16:09:04.609642+00	postgres	{"genre": "power metal", "title": "The Last Stand", "access": 0, "song_id": 22, "album_id": 9, "file_path": "", "track_number": 1, "duration_seconds": 250}	{"genre": "power metal", "title": "The Last Stand", "access": 0, "song_id": 22, "album_id": 9, "file_path": "song7.mp3", "track_number": 1, "duration_seconds": 250}
68	songs	U	2026-11-21 16:09:04.609642+00	postgres	{"genre": "power metal", "title": "Sparta", "access": 0, "song_id": 23, "album_id": 9, "file_path": "", "track_number": 2, "duration_seconds": 230}	{"genre": "power metal", "title": "Sparta", "access": 0, "song_id": 23, "album_id": 9, "file_path": "song7.mp3", "track_number": 2, "duration_seconds": 230}
69	songs	U	2026-11-21 16:09:04.609642+00	postgres	{"genre": "grindcore", "title": "The Wolf I Feed", "access": 0, "song_id": 26, "album_id": 11, "file_path": "", "track_number": 5, "duration_seconds": 177}	{"genre": "grindcore", "title": "The Wolf I Feed", "access": 0, "song_id": 26, "album_id": 11, "file_path": "song7.mp3", "track_number": 5, "duration_seconds": 177}
70	songs	U	2026-11-21 16:09:04.609642+00	postgres	{"genre": "grindcore", "title": "Fall on Their Swords", "access": 0, "song_id": 27, "album_id": 11, "file_path": "", "track_number": 7, "duration_seconds": 237}	{"genre": "grindcore", "title": "Fall on Their Swords", "access": 0, "song_id": 27, "album_id": 11, "file_path": "song7.mp3", "track_number": 7, "duration_seconds": 237}
71	songs	U	2026-11-21 16:09:04.609642+00	postgres	{"genre": "black metal", "title": "Elephantry", "access": 0, "song_id": 28, "album_id": 12, "file_path": "", "track_number": 3, "duration_seconds": 191}	{"genre": "black metal", "title": "Elephantry", "access": 0, "song_id": 28, "album_id": 12, "file_path": "song7.mp3", "track_number": 3, "duration_seconds": 191}
72	songs	U	2026-11-21 16:09:04.609642+00	postgres	{"genre": "black metal", "title": "Siege Ubsessed", "access": 0, "song_id": 29, "album_id": 12, "file_path": "", "track_number": 2, "duration_seconds": 213}	{"genre": "black metal", "title": "Siege Ubsessed", "access": 0, "song_id": 29, "album_id": 12, "file_path": "song7.mp3", "track_number": 2, "duration_seconds": 213}
73	songs	U	2026-11-21 16:09:04.609642+00	postgres	{"genre": "nu metal", "title": "Chop Suey!", "access": 2, "song_id": 24, "album_id": 10, "file_path": "", "track_number": 1, "duration_seconds": 210}	{"genre": "nu metal", "title": "Chop Suey!", "access": 2, "song_id": 24, "album_id": 10, "file_path": "song7.mp3", "track_number": 1, "duration_seconds": 210}
74	songs	U	2026-11-21 16:09:04.609642+00	postgres	{"genre": "nu metal", "title": "Toxicity", "access": 2, "song_id": 25, "album_id": 10, "file_path": "", "track_number": 2, "duration_seconds": 220}	{"genre": "nu metal", "title": "Toxicity", "access": 2, "song_id": 25, "album_id": 10, "file_path": "song7.mp3", "track_number": 2, "duration_seconds": 220}
75	songs	U	2026-11-21 16:09:04.609642+00	postgres	{"genre": "nu metal", "title": "Boom!", "access": 2, "song_id": 30, "album_id": 10, "file_path": "", "track_number": 3, "duration_seconds": 135}	{"genre": "nu metal", "title": "Boom!", "access": 2, "song_id": 30, "album_id": 10, "file_path": "song7.mp3", "track_number": 3, "duration_seconds": 135}
76	songs	U	2026-11-21 16:09:04.609642+00	postgres	{"genre": "nu metal", "title": "Soldier Side", "access": 2, "song_id": 31, "album_id": 10, "file_path": "", "track_number": 4, "duration_seconds": 220}	{"genre": "nu metal", "title": "Soldier Side", "access": 2, "song_id": 31, "album_id": 10, "file_path": "song7.mp3", "track_number": 4, "duration_seconds": 220}
77	songs	U	2026-11-21 16:09:04.609642+00	postgres	{"genre": "blackened death metal", "title": "Menschenmühle", "access": 0, "song_id": 32, "album_id": 17, "file_path": "", "track_number": 2, "duration_seconds": 219}	{"genre": "blackened death metal", "title": "Menschenmühle", "access": 0, "song_id": 32, "album_id": 17, "file_path": "song7.mp3", "track_number": 2, "duration_seconds": 219}
78	songs	U	2026-11-21 16:09:04.609642+00	postgres	{"genre": "blackened death metal", "title": "Sturmtrupp", "access": 0, "song_id": 33, "album_id": 17, "file_path": "", "track_number": 3, "duration_seconds": 272}	{"genre": "blackened death metal", "title": "Sturmtrupp", "access": 0, "song_id": 33, "album_id": 17, "file_path": "song7.mp3", "track_number": 3, "duration_seconds": 272}
79	songs	U	2026-11-21 16:09:04.609642+00	postgres	{"genre": "blackened death metal", "title": "Panzerhenker", "access": 0, "song_id": 34, "album_id": 17, "file_path": "", "track_number": 8, "duration_seconds": 309}	{"genre": "blackened death metal", "title": "Panzerhenker", "access": 0, "song_id": 34, "album_id": 17, "file_path": "song7.mp3", "track_number": 8, "duration_seconds": 309}
\.


--
-- Data for Name: musicians; Type: TABLE DATA; Schema: public; Owner: music_BD
--

COPY public.musicians (musician_id, first_name, last_name, stage_name, country, biography, owner_user_id) FROM stdin;
1	Christopher	Bowes	Zargothrax	Scotland		7
2	Paul	Templing	Ser Proletius	United Kingdom		5
3	James	Cartwright	The Hootsman	United Kingdom		5
4	Ben	Turk	Ralathor	United Kingdom		5
5	Michael	Sozos	Angus McFife	United Kingdom		5
6	Michael	Barber	Zargothrax	United Kingdom		5
7	Thomas	Winkler	Angus McSix	Switzerland		6
8	Yaroslav	Dronov	SHAMAN	Russia	Russian singer known for an absence of talent	\N
\.


--
-- Data for Name: songs; Type: TABLE DATA; Schema: public; Owner: music_BD
--

COPY public.songs (song_id, album_id, title, track_number, duration_seconds, genre, file_path, access) FROM stdin;
8	6	He Has Returned	1	265	epic power metal	song1.mp3	1
9	3	The Siege of Dunkeld (In Hoots We Trust)	2	286	epic power metal	song2.mp3	1
10	3	Masters of the Galaxy	3	265	epic power metal	song3.mp3	1
11	3	The Land of Unicorns	4	264	epic power metal	song4.mp3	1
12	3	Power of the Laser Dragon Fire	5	306	epic power metal	song5.mp3	1
13	3	Gloryhammer	7	300	epic power metal	song6.mp3	1
14	3	Hootsforce	8	230	epic power metal	song7.mp3	1
16	8	Встанем	1	240	pop	song8.mp3	0
17	8	Я русский	2	220	pop	song8.mp3	0
22	9	The Last Stand	1	250	power metal	song7.mp3	0
23	9	Sparta	2	230	power metal	song7.mp3	0
26	11	The Wolf I Feed	5	177	grindcore	song7.mp3	0
27	11	Fall on Their Swords	7	237	grindcore	song7.mp3	0
28	12	Elephantry	3	191	black metal	song7.mp3	0
29	12	Siege Ubsessed	2	213	black metal	song7.mp3	0
24	10	Chop Suey!	1	210	nu metal	song7.mp3	2
25	10	Toxicity	2	220	nu metal	song7.mp3	2
30	10	Boom!	3	135	nu metal	song7.mp3	2
31	10	Soldier Side	4	220	nu metal	song7.mp3	2
32	17	Menschenmühle	2	219	blackened death metal	song7.mp3	0
33	17	Sturmtrupp	3	272	blackened death metal	song7.mp3	0
34	17	Panzerhenker	8	309	blackened death metal	song7.mp3	0
68	20	Test track 0	1	67	test	songs/test_0.mp3	1
69	21	Test track 0	1	67	test	songs/test_0.mp3	1
70	22	Test track 0	1	67	test	songs/test_0.mp3	1
71	23	Test track 0	1	67	test	songs/test_0.mp3	5
72	24	Test track 0	1	67	test	songs/deleted.mp3	1
73	25	Test track 0	1	67	test	../secret.txt	1
74	26	Test track 0	1	67	test	songs/test_0.mp3	5
75	27	Test track 0	1	67	test	songs/test_0.mp3	1
76	28	Test track 0	1	67	test	songs/test_0.mp3	5
77	29	Test track 0	1	67	test	songs/deleted.mp3	1
78	30	Test track 0	1	67	test	../secret.txt	1
79	31	Test track 0	1	67	test	songs/test_0.mp3	5
80	32	Test track 0	1	67	test	songs/test_0.mp3	1
81	33	Test track 0	1	67	test	songs/test_0.mp3	5
82	34	Test track 0	1	67	test	songs/deleted.mp3	1
83	35	Test track 0	1	67	test	../secret.txt	1
84	36	Test track 0	1	67	test	songs/test_0.mp3	5
85	37	Test track 0	1	67	test	songs/test_0.mp3	1
86	38	Test track 0	1	67	test	songs/test_0.mp3	2
87	39	Test track 0	1	67	test	../secret.txt	1
88	40	Test track 0	1	67	test	songs/test_0.mp3	2
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: music_BD
--

COPY public.users (user_id, username, email, password_hash, is_musician, access) FROM stdin;
5	gloryhammer	a01@gmail.com	hash_a01	t	0
6	thomas	a02@gmail.com	hash_a02	t	0
7	alestorm	a03@gmail.com	hash_a03	t	0
1	listener1	l01@example.test	$argon2id$v=19$m=65536,t=3,p=2$HQ6jTbioBVqu6gOcqFmRlg$8D2m1W+TsZEvn7NC+B4JOsmwrfKdo+84hEsXl8z8Ofg	f	0
2	listener2	l02@example.test	$argon2id$v=19$m=65536,t=3,p=2$2zEWRUlb474Edr0MGx9/bw$WKgQ1CgziimfrTCSSR2+Ipy/hN1XYc+A2NvfVJMEPrk	f	1
3	listener3	l03@example.test	$argon2id$v=19$m=65536,t=3,p=2$pNwk+HEElvTssH+NznGOJg$nhorf/Rmp8S2BuH+NSNcu4N3ftothTYBW6IGF9+sBlo	f	2
60	user_f24a0434	user_f24a0434@e.com	$argon2id$v=19$m=65536,t=3,p=2$Ztasot6fi24vXydRq/kcng$dKSityI73A2AFCFfflz90vSScCHys4X5OcOyAofjstM	f	1
61	reg_49c73186	reg_49c73186@example.com	$argon2id$v=19$m=65536,t=3,p=2$pF4VNe8NV3KoNwxwoyoRsw$SAIbUCGIe/9eX14K82TUNCsfMdlAsuAzywrnSIPylko	f	0
68	user_a737cbab	user_a737cbab@e.com	$argon2id$v=19$m=65536,t=3,p=2$d0+aWBFTllzbl2i/OJL3Ug$+9IUC1H9xSea7AGkouJneebq7UF28shWMQd3iX8kLVE	f	1
76	user_1bd9fbc0	user_1bd9fbc0@e.com	$argon2id$v=19$m=65536,t=3,p=2$dVFb4OYP/OPtXuwHDqv4Ww$OOIs93i34EbnLIZsyqNQAYu/XYzarDmIwdt+oEin7UQ	f	1
142	user_5d2686b1	user_5d2686b1@e.com	$argon2id$v=19$m=65536,t=3,p=2$FHKBtmygIAxfHPVknLP0pA$vthm39V2BXGlm9Qrrxbruxa/zjbdi8U0U2lXbmDbNKU	f	1
150	user_3e2c972f	user_3e2c972f@e.com	$argon2id$v=19$m=65536,t=3,p=2$ZjO5g255aLp6UyzsIf8PaQ$F8OHeP7xBPrBFEjyNWehQwqrU/v5BqLusqDLXlS+QBI	f	1
\.


--
-- Name: albums_album_id_seq; Type: SEQUENCE SET; Schema: public; Owner: music_BD
--

SELECT pg_catalog.setval('public.albums_album_id_seq', 40, true);


--
-- Name: bands_band_id_seq; Type: SEQUENCE SET; Schema: public; Owner: music_BD
--

SELECT pg_catalog.setval('public.bands_band_id_seq', 9, true);


--
-- Name: main_log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: music_BD
--

SELECT pg_catalog.setval('public.main_log_log_id_seq', 79, true);


--
-- Name: musicians_musician_id_seq; Type: SEQUENCE SET; Schema: public; Owner: music_BD
--

SELECT pg_catalog.setval('public.musicians_musician_id_seq', 8, true);


--
-- Name: songs_song_id_seq; Type: SEQUENCE SET; Schema: public; Owner: music_BD
--

SELECT pg_catalog.setval('public.songs_song_id_seq', 88, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: music_BD
--

SELECT pg_catalog.setval('public.users_user_id_seq', 209, true);


--
-- Name: albums albums_pkey; Type: CONSTRAINT; Schema: public; Owner: music_BD
--

ALTER TABLE ONLY public.albums
    ADD CONSTRAINT albums_pkey PRIMARY KEY (album_id);


--
-- Name: bands bands_pkey; Type: CONSTRAINT; Schema: public; Owner: music_BD
--

ALTER TABLE ONLY public.bands
    ADD CONSTRAINT bands_pkey PRIMARY KEY (band_id);


--
-- Name: main_log main_log_pkey; Type: CONSTRAINT; Schema: public; Owner: music_BD
--

ALTER TABLE ONLY public.main_log
    ADD CONSTRAINT main_log_pkey PRIMARY KEY (log_id);


--
-- Name: musicians musicians_pkey; Type: CONSTRAINT; Schema: public; Owner: music_BD
--

ALTER TABLE ONLY public.musicians
    ADD CONSTRAINT musicians_pkey PRIMARY KEY (musician_id);


--
-- Name: songs songs_album_id_track_number_key; Type: CONSTRAINT; Schema: public; Owner: music_BD
--

ALTER TABLE ONLY public.songs
    ADD CONSTRAINT songs_album_id_track_number_key UNIQUE (album_id, track_number);


--
-- Name: songs songs_pkey; Type: CONSTRAINT; Schema: public; Owner: music_BD
--

ALTER TABLE ONLY public.songs
    ADD CONSTRAINT songs_pkey PRIMARY KEY (song_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: music_BD
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: music_BD
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: music_BD
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_albums_band; Type: INDEX; Schema: public; Owner: music_BD
--

CREATE INDEX idx_albums_band ON public.albums USING btree (band_id);


--
-- Name: idx_albums_musician; Type: INDEX; Schema: public; Owner: music_BD
--

CREATE INDEX idx_albums_musician ON public.albums USING btree (musician_id);


--
-- Name: idx_bands_owner; Type: INDEX; Schema: public; Owner: music_BD
--

CREATE INDEX idx_bands_owner ON public.bands USING btree (owner_user_id);


--
-- Name: idx_musicians_owner; Type: INDEX; Schema: public; Owner: music_BD
--

CREATE INDEX idx_musicians_owner ON public.musicians USING btree (owner_user_id);


--
-- Name: idx_songs_album; Type: INDEX; Schema: public; Owner: music_BD
--

CREATE INDEX idx_songs_album ON public.songs USING btree (album_id);


--
-- Name: idx_songs_genre; Type: INDEX; Schema: public; Owner: music_BD
--

CREATE INDEX idx_songs_genre ON public.songs USING btree (genre);


--
-- Name: idx_songs_title; Type: INDEX; Schema: public; Owner: music_BD
--

CREATE INDEX idx_songs_title ON public.songs USING btree (title);


--
-- PostgreSQL database dump complete
--

\unrestrict F47Ofx70UosbetNDRCPjA3NQlpBTtqIJGNoBerHND09kqtweCbkzwUG4KQDEgpO

