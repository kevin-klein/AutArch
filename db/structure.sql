SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: anthropologies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.anthropologies (
    id bigint NOT NULL,
    sex_morph integer,
    sex_gen integer,
    sex_consensus integer,
    age_as_reported character varying,
    age_class integer,
    height double precision,
    pathologies_type character varying,
    skeleton_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    species integer
);


--
-- Name: anthropologies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.anthropologies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anthropologies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.anthropologies_id_seq OWNED BY public.anthropologies.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: bones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bones (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: bones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bones_id_seq OWNED BY public.bones.id;


--
-- Name: c14_dates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.c14_dates (
    id bigint NOT NULL,
    c14_type integer NOT NULL,
    lab_id character varying,
    age_bp integer,
    "interval" integer,
    material integer,
    calbc_1_sigma_max double precision,
    calbc_1_sigma_min double precision,
    calbc_2_sigma_max double precision,
    calbc_2_sigma_min double precision,
    date_note character varying,
    cal_method integer,
    ref_14c character varying,
    chronology_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    bone_id bigint
);


--
-- Name: c14_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.c14_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: c14_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.c14_dates_id_seq OWNED BY public.c14_dates.id;


--
-- Name: chronologies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chronologies (
    id bigint NOT NULL,
    context_from integer,
    context_to integer,
    skeleton_id bigint,
    grave_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    period_id bigint
);


--
-- Name: chronologies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chronologies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chronologies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chronologies_id_seq OWNED BY public.chronologies.id;


--
-- Name: cultures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cultures (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cultures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cultures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cultures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cultures_id_seq OWNED BY public.cultures.id;


--
-- Name: figures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.figures (
    id bigint NOT NULL,
    page_id bigint NOT NULL,
    x1 integer NOT NULL,
    x2 integer NOT NULL,
    y1 integer NOT NULL,
    y2 integer NOT NULL,
    type character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    area double precision,
    perimeter double precision,
    meter_ratio double precision,
    angle double precision,
    parent_id integer,
    identifier character varying,
    width double precision,
    height double precision,
    text character varying,
    site_id bigint,
    validated boolean DEFAULT false NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    disturbed boolean DEFAULT false NOT NULL,
    contour text DEFAULT '[]'::text NOT NULL,
    deposition_type integer DEFAULT 0 NOT NULL,
    publication_id integer,
    percentage_scale integer,
    page_size integer,
    manual_bounding_box boolean DEFAULT false,
    bounding_box_angle integer,
    bounding_box_height double precision,
    bounding_box_width double precision,
    control_point_1_x integer,
    control_point_1_y integer,
    control_point_2_x integer,
    control_point_2_y integer,
    control_point_3_x integer,
    control_point_3_y integer,
    control_point_4_x integer,
    control_point_4_y integer,
    anchor_point_1_x integer,
    anchor_point_1_y integer,
    anchor_point_2_x integer,
    anchor_point_2_y integer,
    anchor_point_3_x integer,
    anchor_point_3_y integer,
    anchor_point_4_x integer,
    anchor_point_4_y integer,
    probability double precision,
    contour_info jsonb,
    real_world_area double precision,
    real_world_width double precision,
    real_world_height double precision,
    real_world_perimeter double precision,
    features double precision[] DEFAULT '{}'::double precision[] NOT NULL,
    efds double precision[] DEFAULT '{}'::double precision[] NOT NULL,
    internment_type integer,
    dummy boolean DEFAULT false NOT NULL,
    actual_height_mm integer
);


--
-- Name: figures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.figures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: figures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.figures_id_seq OWNED BY public.figures.id;


--
-- Name: figures_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.figures_tags (
    id bigint NOT NULL,
    tag_id bigint,
    figure_id bigint
);


--
-- Name: figures_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.figures_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: figures_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.figures_tags_id_seq OWNED BY public.figures_tags.id;


--
-- Name: genetics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genetics (
    id bigint NOT NULL,
    data_type integer,
    endo_content double precision,
    ref_gen character varying,
    skeleton_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    mt_haplogroup_id bigint,
    y_haplogroup_id bigint,
    bone_id bigint
);


--
-- Name: genetics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.genetics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genetics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.genetics_id_seq OWNED BY public.genetics.id;


--
-- Name: images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.images (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    width integer,
    height integer
);


--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.images_id_seq OWNED BY public.images.id;


--
-- Name: key_points; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.key_points (
    id bigint NOT NULL,
    label integer NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    figure_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: key_points_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.key_points_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: key_points_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.key_points_id_seq OWNED BY public.key_points.id;


--
-- Name: kurgans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kurgans (
    id bigint NOT NULL,
    width integer,
    height integer,
    name character varying NOT NULL,
    publication_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: kurgans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kurgans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kurgans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kurgans_id_seq OWNED BY public.kurgans.id;


--
-- Name: mt_haplogroups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mt_haplogroups (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: mt_haplogroups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mt_haplogroups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mt_haplogroups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mt_haplogroups_id_seq OWNED BY public.mt_haplogroups.id;


--
-- Name: object_similarities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.object_similarities (
    id bigint NOT NULL,
    type character varying,
    similarity double precision,
    first_id bigint NOT NULL,
    second_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: object_similarities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.object_similarities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: object_similarities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.object_similarities_id_seq OWNED BY public.object_similarities.id;


--
-- Name: page_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_texts (
    id bigint NOT NULL,
    page_id bigint NOT NULL,
    text character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: page_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_texts_id_seq OWNED BY public.page_texts.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    id bigint NOT NULL,
    publication_id bigint NOT NULL,
    number integer,
    image_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pages_id_seq OWNED BY public.pages.id;


--
-- Name: periods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.periods (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: periods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.periods_id_seq OWNED BY public.periods.id;


--
-- Name: publications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publications (
    id bigint NOT NULL,
    author character varying,
    title character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    year character varying,
    user_id bigint,
    public boolean DEFAULT false NOT NULL,
    summary text
);


--
-- Name: publications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.publications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.publications_id_seq OWNED BY public.publications.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: share_publications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.share_publications (
    id bigint NOT NULL,
    publication_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: share_publications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.share_publications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: share_publications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.share_publications_id_seq OWNED BY public.share_publications.id;


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sites (
    id bigint NOT NULL,
    lat double precision,
    lon double precision,
    name character varying,
    locality character varying,
    country_code integer,
    site_code character varying
);


--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sites_id_seq OWNED BY public.sites.id;


--
-- Name: skeletons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.skeletons (
    id bigint NOT NULL,
    figure_id integer NOT NULL,
    angle double precision,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    skeleton_id character varying,
    funerary_practice integer,
    inhumation_type integer,
    anatonimcal_connection integer,
    body_position integer,
    crouching_type integer,
    other character varying,
    head_facing double precision,
    ochre integer,
    ochre_position integer,
    skeleton_figure_id bigint,
    site_id bigint
);


--
-- Name: skeletons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.skeletons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: skeletons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.skeletons_id_seq OWNED BY public.skeletons.id;


--
-- Name: stable_isotopes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stable_isotopes (
    id bigint NOT NULL,
    skeleton_id bigint NOT NULL,
    iso_id character varying,
    iso_value double precision,
    ref_iso character varying,
    isotope integer,
    baseline integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    bone_id bigint
);


--
-- Name: stable_isotopes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stable_isotopes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stable_isotopes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stable_isotopes_id_seq OWNED BY public.stable_isotopes.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: taxonomies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.taxonomies (
    id bigint NOT NULL,
    skeleton_id bigint,
    culture_note character varying,
    culture_reference character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    culture_id bigint
);


--
-- Name: taxonomies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.taxonomies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxonomies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.taxonomies_id_seq OWNED BY public.taxonomies.id;


--
-- Name: text_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.text_items (
    id bigint NOT NULL,
    page_id bigint NOT NULL,
    text character varying,
    x1 integer,
    x2 integer,
    y1 integer,
    y2 integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: text_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.text_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: text_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.text_items_id_seq OWNED BY public.text_items.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying,
    code_hash character varying,
    name character varying,
    role integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: y_haplogroups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.y_haplogroups (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: y_haplogroups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.y_haplogroups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: y_haplogroups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.y_haplogroups_id_seq OWNED BY public.y_haplogroups.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: anthropologies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anthropologies ALTER COLUMN id SET DEFAULT nextval('public.anthropologies_id_seq'::regclass);


--
-- Name: bones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bones ALTER COLUMN id SET DEFAULT nextval('public.bones_id_seq'::regclass);


--
-- Name: c14_dates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.c14_dates ALTER COLUMN id SET DEFAULT nextval('public.c14_dates_id_seq'::regclass);


--
-- Name: chronologies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chronologies ALTER COLUMN id SET DEFAULT nextval('public.chronologies_id_seq'::regclass);


--
-- Name: cultures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cultures ALTER COLUMN id SET DEFAULT nextval('public.cultures_id_seq'::regclass);


--
-- Name: figures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.figures ALTER COLUMN id SET DEFAULT nextval('public.figures_id_seq'::regclass);


--
-- Name: figures_tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.figures_tags ALTER COLUMN id SET DEFAULT nextval('public.figures_tags_id_seq'::regclass);


--
-- Name: genetics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genetics ALTER COLUMN id SET DEFAULT nextval('public.genetics_id_seq'::regclass);


--
-- Name: images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.images ALTER COLUMN id SET DEFAULT nextval('public.images_id_seq'::regclass);


--
-- Name: key_points id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_points ALTER COLUMN id SET DEFAULT nextval('public.key_points_id_seq'::regclass);


--
-- Name: kurgans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kurgans ALTER COLUMN id SET DEFAULT nextval('public.kurgans_id_seq'::regclass);


--
-- Name: mt_haplogroups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mt_haplogroups ALTER COLUMN id SET DEFAULT nextval('public.mt_haplogroups_id_seq'::regclass);


--
-- Name: object_similarities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_similarities ALTER COLUMN id SET DEFAULT nextval('public.object_similarities_id_seq'::regclass);


--
-- Name: page_texts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_texts ALTER COLUMN id SET DEFAULT nextval('public.page_texts_id_seq'::regclass);


--
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_id_seq'::regclass);


--
-- Name: periods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periods ALTER COLUMN id SET DEFAULT nextval('public.periods_id_seq'::regclass);


--
-- Name: publications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publications ALTER COLUMN id SET DEFAULT nextval('public.publications_id_seq'::regclass);


--
-- Name: share_publications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_publications ALTER COLUMN id SET DEFAULT nextval('public.share_publications_id_seq'::regclass);


--
-- Name: sites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites ALTER COLUMN id SET DEFAULT nextval('public.sites_id_seq'::regclass);


--
-- Name: skeletons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.skeletons ALTER COLUMN id SET DEFAULT nextval('public.skeletons_id_seq'::regclass);


--
-- Name: stable_isotopes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stable_isotopes ALTER COLUMN id SET DEFAULT nextval('public.stable_isotopes_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: taxonomies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taxonomies ALTER COLUMN id SET DEFAULT nextval('public.taxonomies_id_seq'::regclass);


--
-- Name: text_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_items ALTER COLUMN id SET DEFAULT nextval('public.text_items_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: y_haplogroups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.y_haplogroups ALTER COLUMN id SET DEFAULT nextval('public.y_haplogroups_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: anthropologies anthropologies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anthropologies
    ADD CONSTRAINT anthropologies_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: bones bones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bones
    ADD CONSTRAINT bones_pkey PRIMARY KEY (id);


--
-- Name: c14_dates c14_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.c14_dates
    ADD CONSTRAINT c14_dates_pkey PRIMARY KEY (id);


--
-- Name: chronologies chronologies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chronologies
    ADD CONSTRAINT chronologies_pkey PRIMARY KEY (id);


--
-- Name: cultures cultures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cultures
    ADD CONSTRAINT cultures_pkey PRIMARY KEY (id);


--
-- Name: figures figures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.figures
    ADD CONSTRAINT figures_pkey PRIMARY KEY (id);


--
-- Name: figures_tags figures_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.figures_tags
    ADD CONSTRAINT figures_tags_pkey PRIMARY KEY (id);


--
-- Name: genetics genetics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genetics
    ADD CONSTRAINT genetics_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: key_points key_points_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_points
    ADD CONSTRAINT key_points_pkey PRIMARY KEY (id);


--
-- Name: kurgans kurgans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kurgans
    ADD CONSTRAINT kurgans_pkey PRIMARY KEY (id);


--
-- Name: mt_haplogroups mt_haplogroups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mt_haplogroups
    ADD CONSTRAINT mt_haplogroups_pkey PRIMARY KEY (id);


--
-- Name: object_similarities object_similarities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_similarities
    ADD CONSTRAINT object_similarities_pkey PRIMARY KEY (id);


--
-- Name: page_texts page_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_texts
    ADD CONSTRAINT page_texts_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: periods periods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: publications publications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT publications_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: share_publications share_publications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_publications
    ADD CONSTRAINT share_publications_pkey PRIMARY KEY (id);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: skeletons skeletons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.skeletons
    ADD CONSTRAINT skeletons_pkey PRIMARY KEY (id);


--
-- Name: stable_isotopes stable_isotopes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stable_isotopes
    ADD CONSTRAINT stable_isotopes_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: taxonomies taxonomies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taxonomies
    ADD CONSTRAINT taxonomies_pkey PRIMARY KEY (id);


--
-- Name: text_items text_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_items
    ADD CONSTRAINT text_items_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: y_haplogroups y_haplogroups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.y_haplogroups
    ADD CONSTRAINT y_haplogroups_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_anthropologies_on_skeleton_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_anthropologies_on_skeleton_id ON public.anthropologies USING btree (skeleton_id);


--
-- Name: index_c14_dates_on_bone_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_c14_dates_on_bone_id ON public.c14_dates USING btree (bone_id);


--
-- Name: index_c14_dates_on_chronology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_c14_dates_on_chronology_id ON public.c14_dates USING btree (chronology_id);


--
-- Name: index_chronologies_on_grave_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chronologies_on_grave_id ON public.chronologies USING btree (grave_id);


--
-- Name: index_chronologies_on_period_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chronologies_on_period_id ON public.chronologies USING btree (period_id);


--
-- Name: index_chronologies_on_skeleton_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chronologies_on_skeleton_id ON public.chronologies USING btree (skeleton_id);


--
-- Name: index_figures_on_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_figures_on_page_id ON public.figures USING btree (page_id);


--
-- Name: index_figures_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_figures_on_site_id ON public.figures USING btree (site_id);


--
-- Name: index_figures_tags_on_figure_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_figures_tags_on_figure_id ON public.figures_tags USING btree (figure_id);


--
-- Name: index_figures_tags_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_figures_tags_on_tag_id ON public.figures_tags USING btree (tag_id);


--
-- Name: index_genetics_on_bone_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_genetics_on_bone_id ON public.genetics USING btree (bone_id);


--
-- Name: index_genetics_on_mt_haplogroup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_genetics_on_mt_haplogroup_id ON public.genetics USING btree (mt_haplogroup_id);


--
-- Name: index_genetics_on_skeleton_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_genetics_on_skeleton_id ON public.genetics USING btree (skeleton_id);


--
-- Name: index_genetics_on_y_haplogroup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_genetics_on_y_haplogroup_id ON public.genetics USING btree (y_haplogroup_id);


--
-- Name: index_key_points_on_figure_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_key_points_on_figure_id ON public.key_points USING btree (figure_id);


--
-- Name: index_kurgans_on_publication_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kurgans_on_publication_id ON public.kurgans USING btree (publication_id);


--
-- Name: index_object_similarities_on_first_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_object_similarities_on_first_id ON public.object_similarities USING btree (first_id);


--
-- Name: index_object_similarities_on_second_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_object_similarities_on_second_id ON public.object_similarities USING btree (second_id);


--
-- Name: index_page_texts_on_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_texts_on_page_id ON public.page_texts USING btree (page_id);


--
-- Name: index_pages_on_image_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pages_on_image_id ON public.pages USING btree (image_id);


--
-- Name: index_pages_on_publication_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pages_on_publication_id ON public.pages USING btree (publication_id);


--
-- Name: index_publications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publications_on_user_id ON public.publications USING btree (user_id);


--
-- Name: index_share_publications_on_publication_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_share_publications_on_publication_id ON public.share_publications USING btree (publication_id);


--
-- Name: index_share_publications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_share_publications_on_user_id ON public.share_publications USING btree (user_id);


--
-- Name: index_skeletons_on_figure_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_skeletons_on_figure_id ON public.skeletons USING btree (figure_id);


--
-- Name: index_skeletons_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_skeletons_on_site_id ON public.skeletons USING btree (site_id);


--
-- Name: index_skeletons_on_skeleton_figure_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_skeletons_on_skeleton_figure_id ON public.skeletons USING btree (skeleton_figure_id);


--
-- Name: index_stable_isotopes_on_bone_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stable_isotopes_on_bone_id ON public.stable_isotopes USING btree (bone_id);


--
-- Name: index_stable_isotopes_on_skeleton_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stable_isotopes_on_skeleton_id ON public.stable_isotopes USING btree (skeleton_id);


--
-- Name: index_taxonomies_on_culture_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taxonomies_on_culture_id ON public.taxonomies USING btree (culture_id);


--
-- Name: index_taxonomies_on_skeleton_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taxonomies_on_skeleton_id ON public.taxonomies USING btree (skeleton_id);


--
-- Name: index_text_items_on_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_text_items_on_page_id ON public.text_items USING btree (page_id);


--
-- Name: page_texts fk_rails_30e2bd5652; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_texts
    ADD CONSTRAINT fk_rails_30e2bd5652 FOREIGN KEY (page_id) REFERENCES public.pages(id);


--
-- Name: skeletons fk_rails_3530f65d41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.skeletons
    ADD CONSTRAINT fk_rails_3530f65d41 FOREIGN KEY (figure_id) REFERENCES public.figures(id);


--
-- Name: stable_isotopes fk_rails_44a721f0e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stable_isotopes
    ADD CONSTRAINT fk_rails_44a721f0e7 FOREIGN KEY (skeleton_id) REFERENCES public.skeletons(id);


--
-- Name: share_publications fk_rails_6b690e58fb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_publications
    ADD CONSTRAINT fk_rails_6b690e58fb FOREIGN KEY (publication_id) REFERENCES public.publications(id);


--
-- Name: pages fk_rails_6e85f0c61d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT fk_rails_6e85f0c61d FOREIGN KEY (publication_id) REFERENCES public.publications(id) ON DELETE CASCADE;


--
-- Name: pages fk_rails_7484eb7907; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT fk_rails_7484eb7907 FOREIGN KEY (image_id) REFERENCES public.images(id) ON DELETE CASCADE;


--
-- Name: share_publications fk_rails_785bc17926; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_publications
    ADD CONSTRAINT fk_rails_785bc17926 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: object_similarities fk_rails_83bef4e20c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_similarities
    ADD CONSTRAINT fk_rails_83bef4e20c FOREIGN KEY (first_id) REFERENCES public.figures(id);


--
-- Name: figures fk_rails_86f3fd6261; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.figures
    ADD CONSTRAINT fk_rails_86f3fd6261 FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: key_points fk_rails_98fbbac85e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_points
    ADD CONSTRAINT fk_rails_98fbbac85e FOREIGN KEY (figure_id) REFERENCES public.figures(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: object_similarities fk_rails_a935212e50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_similarities
    ADD CONSTRAINT fk_rails_a935212e50 FOREIGN KEY (second_id) REFERENCES public.figures(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: genetics fk_rails_ca69f6ded2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genetics
    ADD CONSTRAINT fk_rails_ca69f6ded2 FOREIGN KEY (skeleton_id) REFERENCES public.skeletons(id);


--
-- Name: text_items fk_rails_f8547942a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_items
    ADD CONSTRAINT fk_rails_f8547942a2 FOREIGN KEY (page_id) REFERENCES public.pages(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260124094306'),
('20251217131441'),
('20251216092344'),
('20251216092343'),
('20251216092342'),
('20251025132102'),
('20250715180104'),
('20250617101517'),
('20250604075837'),
('20250320155546'),
('20250320150924'),
('20250320132340'),
('20241002152640'),
('20240813142400'),
('20240530123803'),
('20240525115930'),
('20240522101728'),
('20240318121818'),
('20240310154201'),
('20240309211609'),
('20240117000007'),
('20230907112913'),
('20230903173624'),
('20230827170115'),
('20230817094930'),
('20230815172209'),
('20230604120316'),
('20230604104715'),
('20230306115210'),
('20230306111335'),
('20230305151353'),
('20230305112439'),
('20230215235752'),
('20230205134429'),
('20230204122231'),
('20230203103622'),
('20230128161241'),
('20230128133920'),
('20230128133904'),
('20230128125537'),
('20230127165949'),
('20230127164818'),
('20230127131045'),
('20230123195757'),
('20230122173728'),
('20230122111902'),
('20230120205619'),
('20230120124800'),
('20230120114720'),
('20230118220855'),
('20230118201845'),
('20230117185956'),
('20230117180153'),
('20230117173409'),
('20230117173222'),
('20230117173216'),
('20230117173142'),
('20230117172904'),
('20230117172453'),
('20230117172018'),
('20230117171357'),
('20230117170212'),
('20230117165814'),
('20230117154706'),
('20230115172254'),
('20221218162319'),
('20221211201706'),
('20221211184616'),
('20221209161731'),
('20221204154639'),
('20221204154616'),
('20221129184744'),
('20221126185330'),
('20221125145552'),
('20221112162410'),
('20221112162327'),
('20221112162245'),
('20221112162218'),
('20221112162123'),
('20221112162039'),
('20220930171030'),
('20220928144127'),
('20220928144108'),
('20220927120113');

