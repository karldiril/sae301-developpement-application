-- Destruction des tables temporaires s'ils existent

DROP TABLE IF EXISTS 
    tmp_name_basics, 
    tmp_title_akas, 
    tmp_title_basics, 
    tmp_title_crew, 
    tmp_title_episode, 
    tmp_title_principals, 
    tmp_title_ratings;
    
-- Création des tables temporaires

-- Pour la table oeuvre, genre et appartenir_genre

CREATE TABLE tmp_title_basics (
    tconst          TEXT,
    titleType       TEXT,
    primaryTitle    TEXT,
    originalTitle   TEXT,
    isAdult         TEXT,
    startYear       TEXT,
    endYear         TEXT,
    runtimeMinutes  TEXT,
    genres          TEXT
);

-- Pour la table personne, metier, exercer_metier et oeuvres_connues

CREATE TABLE tmp_name_basics (
    nconst              TEXT,
    primaryName         TEXT,
    birthYear           TEXT,
    deathYear           TEXT,
    primaryProfession   TEXT,
    knownForTitles      TEXT
);

-- Pour la table evaluation

CREATE TABLE tmp_title_ratings (
    tconst          TEXT,
    averageRating   TEXT,
    numVotes        TEXT
);

-- Pour la table titre_localise

CREATE TABLE tmp_title_akas (
    titleId         TEXT,
    ordering        TEXT,
    title           TEXT,
    region          TEXT,
    language        TEXT,
    types           TEXT,
    attributes      TEXT,
    isOriginalTitle TEXT
);

-- Pour la table episode

CREATE TABLE tmp_title_episode (
    tconst          TEXT,
    parentTconst    TEXT,
    seasonNumber    TEXT,
    episodeNumber   TEXT
);

-- Pour la table distribution

CREATE TABLE tmp_title_principals (
    tconst      TEXT,
    ordering    TEXT,
    nconst      TEXT,
    category    TEXT,
    job         TEXT,
    characters  TEXT
);

-- Pour la table realiser et scenariser

CREATE TABLE tmp_title_crew (
    tconst      TEXT,
    directors   TEXT,
    writers     TEXT
);


-- Destruction des tables principales si elles existents


DROP TABLE IF EXISTS 
    Exercer_Metier,
    Oeuvres_Connues,
    Scenariser,
    Realiser,
    Appartenir_Genre,
    EVALUATION,
    EPISODE,
    DISTRIBUTION,
    TITRE_LOCALISE,
    METIER,
    GENRE,
    PERSONNE,
    OEUVRE
CASCADE;

-- Création des tables principales

CREATE TABLE OEUVRE(
    id_oeuvre VARCHAR(50),
    type_oeuvre VARCHAR(50) NOT NULL,
    titre_principal VARCHAR(500) NOT NULL,
    titre_original VARCHAR(500),
    pour_adulte BOOLEAN NOT NULL,
    annee_sortie SMALLINT,
    annee_fin INT,
    duree_minutes INT,
    PRIMARY KEY(id_oeuvre)
);

CREATE TABLE PERSONNE(
    id_personne VARCHAR(15),
    nom_complet VARCHAR(255) NOT NULL,
    annee_naissance INT,
    annee_deces INT,
    PRIMARY KEY(id_personne)
);

CREATE TABLE TITRE_LOCALISE(
    id_oeuvre VARCHAR(50),
    numero_ordre INT,
    titre VARCHAR(500) NOT NULL,
    code_region VARCHAR(10),
    code_langue VARCHAR(10),
    type_diffusion VARCHAR(100),
    attributs VARCHAR(500),
    est_titre_original BOOLEAN,
    PRIMARY KEY(id_oeuvre, numero_ordre),
    FOREIGN KEY(id_oeuvre) REFERENCES OEUVRE(id_oeuvre)
);

CREATE TABLE GENRE(
    id_genre SERIAL,
    nom_genre VARCHAR(50) NOT NULL,
    PRIMARY KEY(id_genre),
    UNIQUE(nom_genre)
);

CREATE TABLE METIER(
    id_metier SERIAL,
    nom_metier VARCHAR(50) NOT NULL,
    PRIMARY KEY(id_metier),
    UNIQUE(nom_metier)
);

CREATE TABLE DISTRIBUTION(
    id_oeuvre VARCHAR(50),
    ordre_generique INT,
    categorie_metier VARCHAR(50),
    intitule_poste VARCHAR(500),
    noms_personnages VARCHAR(500),
    id_personne VARCHAR(15) NOT NULL,
    PRIMARY KEY(id_oeuvre, ordre_generique),
    FOREIGN KEY(id_oeuvre) REFERENCES OEUVRE(id_oeuvre),
    FOREIGN KEY(id_personne) REFERENCES PERSONNE(id_personne)
);

CREATE TABLE EPISODE(
    id_oeuvre_1 VARCHAR(50),
    numero_episode INT,
    numero_saison INT,
    id_oeuvre VARCHAR(50) NOT NULL,
    PRIMARY KEY(id_oeuvre_1),
    FOREIGN KEY(id_oeuvre_1) REFERENCES OEUVRE(id_oeuvre),
    FOREIGN KEY(id_oeuvre) REFERENCES OEUVRE(id_oeuvre)
);

CREATE TABLE EVALUATION(
    id_oeuvre VARCHAR(50),
    note_moyenne DECIMAL(3,1),
    nombre_votes INT,
    PRIMARY KEY(id_oeuvre),
    FOREIGN KEY(id_oeuvre) REFERENCES OEUVRE(id_oeuvre)
);

-- Création des tables associatives

CREATE TABLE Appartenir_Genre(
    id_oeuvre VARCHAR(50),
    id_genre INT,
    PRIMARY KEY(id_oeuvre, id_genre),
    FOREIGN KEY(id_oeuvre) REFERENCES OEUVRE(id_oeuvre),
    FOREIGN KEY(id_genre) REFERENCES GENRE(id_genre)
);

CREATE TABLE Realiser(
    id_oeuvre VARCHAR(50),
    id_personne VARCHAR(15),
    PRIMARY KEY(id_oeuvre, id_personne),
    FOREIGN KEY(id_oeuvre) REFERENCES OEUVRE(id_oeuvre),
    FOREIGN KEY(id_personne) REFERENCES PERSONNE(id_personne)
);

CREATE TABLE Scenariser(
    id_oeuvre VARCHAR(50),
    id_personne VARCHAR(15),
    PRIMARY KEY(id_oeuvre, id_personne),
    FOREIGN KEY(id_oeuvre) REFERENCES OEUVRE(id_oeuvre),
    FOREIGN KEY(id_personne) REFERENCES PERSONNE(id_personne)
);

CREATE TABLE Oeuvres_Connues(
    id_oeuvre VARCHAR(50),
    id_personne VARCHAR(15),
    PRIMARY KEY(id_oeuvre, id_personne),
    FOREIGN KEY(id_oeuvre) REFERENCES OEUVRE(id_oeuvre),
    FOREIGN KEY(id_personne) REFERENCES PERSONNE(id_personne)
);

CREATE TABLE Exercer_Metier(
    id_personne VARCHAR(15),
    id_metier INT,
    PRIMARY KEY(id_personne, id_metier),
    FOREIGN KEY(id_personne) REFERENCES PERSONNE(id_personne),
    FOREIGN KEY(id_metier) REFERENCES METIER(id_metier)
);


-- Importation des données contenues dans les fichiers vers les table temporaire


\copy tmp_title_basics FROM '/home/ortoto/Documents/BUT2/SAE/S301/donnees/title.basics.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '\N', ENCODING 'UTF8');

\copy tmp_name_basics FROM '/home/ortoto/Documents/BUT2/SAE/S301/donnees/name.basics.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '\N', ENCODING 'UTF8');

\copy tmp_title_ratings FROM '/home/ortoto/Documents/BUT2/SAE/S301/donnees/title.ratings.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '\N', ENCODING 'UTF8');

\copy tmp_title_akas FROM '/home/ortoto/Documents/BUT2/SAE/S301/donnees/title.akas.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '\N', ENCODING 'UTF8');

\copy tmp_title_episode FROM '/home/ortoto/Documents/BUT2/SAE/S301/donnees/title.episode.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '\N', ENCODING 'UTF8');

\copy tmp_title_principals FROM '/home/ortoto/Documents/BUT2/SAE/S301/donnees/title.principals.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '\N', ENCODING 'UTF8');

\copy tmp_title_crew FROM '/home/ortoto/Documents/BUT2/SAE/S301/donnees/title.crew.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '\N', ENCODING 'UTF8');
