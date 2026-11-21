--
-- PostgreSQL database dump
--

\restrict M3N7FgNtaODcQx1GhuLGiBOh7PexY1pnubw7HPwO13C1I9hmWTPMgI3wZf1tBsl

-- Dumped from database version 17.11 (Debian 17.11-0+deb13u1)
-- Dumped by pg_dump version 17.11 (Debian 17.11-0+deb13u1)

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
-- Name: albums; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.albums OWNER TO postgres;

--
-- Name: albums_album_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
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
-- Name: bands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bands (
    band_id integer NOT NULL,
    name character varying(150) NOT NULL,
    formed_date integer,
    country character varying(100),
    description text,
    owner_user_id integer
);


ALTER TABLE public.bands OWNER TO postgres;

--
-- Name: musicians; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.musicians OWNER TO postgres;

--
-- Name: songs; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.songs OWNER TO postgres;

--
-- Name: bands_band_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
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
-- Name: listener_music_catalog; Type: VIEW; Schema: public; Owner: postgres
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


ALTER VIEW public.listener_music_catalog OWNER TO postgres;

--
-- Name: musicians_musician_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
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
-- Name: songs_song_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
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
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    is_musician boolean DEFAULT false NOT NULL,
    access integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
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
-- Data for Name: albums; Type: TABLE DATA; Schema: public; Owner: postgres
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
\.


--
-- Data for Name: bands; Type: TABLE DATA; Schema: public; Owner: postgres
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
-- Data for Name: musicians; Type: TABLE DATA; Schema: public; Owner: postgres
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
-- Data for Name: songs; Type: TABLE DATA; Schema: public; Owner: postgres
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
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, username, email, password_hash, is_musician, access) FROM stdin;
5	gloryhammer	a01@gmail.com	hash_a01	t	0
6	thomas	a02@gmail.com	hash_a02	t	0
7	alestorm	a03@gmail.com	hash_a03	t	0
1	listener1	l01@example.test	$argon2id$v=19$m=65536,t=3,p=2$HQ6jTbioBVqu6gOcqFmRlg$8D2m1W+TsZEvn7NC+B4JOsmwrfKdo+84hEsXl8z8Ofg	f	0
2	listener2	l02@example.test	$argon2id$v=19$m=65536,t=3,p=2$2zEWRUlb474Edr0MGx9/bw$WKgQ1CgziimfrTCSSR2+Ipy/hN1XYc+A2NvfVJMEPrk	f	1
3	listener3	l03@example.test	$argon2id$v=19$m=65536,t=3,p=2$pNwk+HEElvTssH+NznGOJg$nhorf/Rmp8S2BuH+NSNcu4N3ftothTYBW6IGF9+sBlo	f	2
\.


--
-- Name: albums_album_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.albums_album_id_seq', 17, true);


--
-- Name: bands_band_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bands_band_id_seq', 9, true);


--
-- Name: musicians_musician_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.musicians_musician_id_seq', 8, true);


--
-- Name: songs_song_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.songs_song_id_seq', 34, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 8, true);


--
-- Name: albums albums_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.albums
    ADD CONSTRAINT albums_pkey PRIMARY KEY (album_id);


--
-- Name: bands bands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bands
    ADD CONSTRAINT bands_pkey PRIMARY KEY (band_id);


--
-- Name: musicians musicians_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musicians
    ADD CONSTRAINT musicians_pkey PRIMARY KEY (musician_id);


--
-- Name: songs songs_album_id_track_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.songs
    ADD CONSTRAINT songs_album_id_track_number_key UNIQUE (album_id, track_number);


--
-- Name: songs songs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.songs
    ADD CONSTRAINT songs_pkey PRIMARY KEY (song_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_albums_band; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_albums_band ON public.albums USING btree (band_id);


--
-- Name: idx_albums_musician; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_albums_musician ON public.albums USING btree (musician_id);


--
-- Name: idx_bands_owner; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bands_owner ON public.bands USING btree (owner_user_id);


--
-- Name: idx_musicians_owner; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_musicians_owner ON public.musicians USING btree (owner_user_id);


--
-- Name: idx_songs_album; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_songs_album ON public.songs USING btree (album_id);


--
-- Name: idx_songs_genre; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_songs_genre ON public.songs USING btree (genre);


--
-- Name: idx_songs_title; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_songs_title ON public.songs USING btree (title);


--
-- Name: albums trg_log_albums; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_albums AFTER INSERT OR DELETE OR UPDATE ON public.albums FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();


--
-- Name: bands trg_log_bands; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_bands AFTER INSERT OR DELETE OR UPDATE ON public.bands FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();


--
-- Name: musicians trg_log_musicians; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_musicians AFTER INSERT OR DELETE OR UPDATE ON public.musicians FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();


--
-- Name: songs trg_log_songs; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_songs AFTER INSERT OR DELETE OR UPDATE ON public.songs FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();


--
-- Name: users trg_log_users; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_users AFTER INSERT OR DELETE OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();


--
-- Name: albums albums_band_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.albums
    ADD CONSTRAINT albums_band_id_fkey FOREIGN KEY (band_id) REFERENCES public.bands(band_id) ON DELETE RESTRICT;


--
-- Name: albums albums_musician_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.albums
    ADD CONSTRAINT albums_musician_id_fkey FOREIGN KEY (musician_id) REFERENCES public.musicians(musician_id) ON DELETE RESTRICT;


--
-- Name: bands bands_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bands
    ADD CONSTRAINT bands_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES public.users(user_id) ON DELETE SET NULL;


--
-- Name: musicians musicians_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musicians
    ADD CONSTRAINT musicians_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES public.users(user_id) ON DELETE SET NULL;


--
-- Name: songs songs_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.songs
    ADD CONSTRAINT songs_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.albums(album_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict M3N7FgNtaODcQx1GhuLGiBOh7PexY1pnubw7HPwO13C1I9hmWTPMgI3wZf1tBsl

