import time
import psycopg2
from psycopg2.extras import execute_values


# chaine pour la connexion à la base de données

DB_CONFIG = {
    "dbname": "star",
    "user": "gestionnaire",
    "password": "1234",
    "host": "localhost",
    "port": "5432"
}



def to_int(val):
    """Convertit une chaîne numérique en entier, ou renvoie None si invalide/vide."""
    if val and val.isdigit():
        return int(val)
    return None


def main():
    debut_total = time.time()

    # Connexion à la base de données
    conn = psycopg2.connect(**DB_CONFIG)
    conn.set_client_encoding("UTF8")    # passer le client en UTF-8 pour gérer les caractères spéciaux (langues étrangères, accents etc)
    cur = conn.cursor()

    valid_oeuvres = {} # liste des films importés pour ignorer les notes ou épisodes de films vides
    valid_personnes = {} # liste des personnes importés pour ignorer les rôles de personnes absentes
    genres_map = {}
    metiers_map = {}

    # importation des données depuis tmp_title_basics (remplit OEUVRE, GENRE et Appartenir_Genre)
    t0 = time.time()

    cur.execute("""
        SELECT tconst, titleType, primaryTitle, originalTitle, 
               isAdult, startYear, endYear, runtimeMinutes, genres 
        FROM tmp_title_basics;
    """)

    rows_oeuvre = []
    pairs_genre = []

    for id_oeuvre, type_oeuvre, titre_principal, titre_original, is_adult_str, start_year_str, end_year_str, runtime_str, genres_str in cur.fetchall():
        if not id_oeuvre or not titre_principal or is_adult_str not in ("0", "1"):
            continue
 
        # Conversion des données pour correspondre aux types des colonnes des tables

        valid_oeuvres[id_oeuvre] = True
        pour_adulte = (is_adult_str == "1")
        annee_sortie = to_int(start_year_str)
        annee_fin = to_int(end_year_str)
        duree_minutes = to_int(runtime_str)

        rows_oeuvre.append((id_oeuvre, type_oeuvre, titre_principal, titre_original, pour_adulte, annee_sortie, annee_fin, duree_minutes))

        if genres_str:
            for genre in genres_str.split(","): # créer un tableau en fonction des virgules
                nom_genre = genre.strip()
                if nom_genre:
                    if nom_genre not in genres_map:
                        genres_map[nom_genre] = len(genres_map) + 1 # si le genre n'a pas été rencontré dans genre_map, on l'ajoute et on incrémente l'index
                    pairs_genre.append((id_oeuvre, genres_map[nom_genre]))

    rows_genre = []
    for nom_genre, id_genre in genres_map.items():
        rows_genre.append((id_genre, nom_genre))

    execute_values(cur, "INSERT INTO OEUVRE VALUES %s ON CONFLICT DO NOTHING", rows_oeuvre, page_size=50000)
    execute_values(cur, "INSERT INTO GENRE (id_genre, nom_genre) VALUES %s ON CONFLICT DO NOTHING", rows_genre, page_size=50000)
    execute_values(cur, "INSERT INTO Appartenir_Genre VALUES %s ON CONFLICT DO NOTHING", pairs_genre, page_size=50000)
    print(f"[1/7] OEUVRE, GENRE et Appartenir_Genre insérés en {time.time() - t0:.2f}s")
    del rows_oeuvre, rows_genre, pairs_genre


    # importation des données depuis tmp_name_basics (remplit PERSONNE, METIER, Exercer_Metier et Oeuvres_Connues)
    t0 = time.time()

    cur.execute("""
        SELECT nconst, primaryName, birthYear, deathYear, 
               primaryProfession, knownForTitles 
        FROM tmp_name_basics;
    """)

    rows_personne = []
    pairs_metier = []  # paires de clés primaires pour chaque table
    pairs_oeuvres_connues = []

    for id_personne, nom_complet, birth_year_str, death_year_str, professions_str, known_titles_str in cur.fetchall():
        if not id_personne or not nom_complet:
            continue

        valid_personnes[id_personne] = True
        annee_naissance = to_int(birth_year_str)
        annee_deces = to_int(death_year_str)

        rows_personne.append((id_personne, nom_complet, annee_naissance, annee_deces))

        if professions_str:
            for profession in professions_str.split(","):  # créer un tableau en fonction des virgules ex : "acteur, scénariste" -> ["acteur", "scenariste"]
                nom_metier = profession.strip()
                if nom_metier:
                    if nom_metier not in metiers_map:
                        metiers_map[nom_metier] = len(metiers_map) + 1 # si le métier n'a pas été rencontré dans metiers_map, on l'ajoute et on incrémente l'index
                    pairs_metier.append((id_personne, metiers_map[nom_metier]))

        if known_titles_str:
            for titre_id in known_titles_str.split(","):
                id_oeuvre = titre_id.strip()
                if id_oeuvre in valid_oeuvres:
                    pairs_oeuvres_connues.append((id_oeuvre, id_personne))

    rows_metier = []
    for nom_metier, id_metier in metiers_map.items():
        rows_metier.append((id_metier, nom_metier))

    execute_values(cur, "INSERT INTO PERSONNE VALUES %s ON CONFLICT DO NOTHING", rows_personne, page_size=50000)
    execute_values(cur, "INSERT INTO METIER (id_metier, nom_metier) VALUES %s ON CONFLICT DO NOTHING", rows_metier, page_size=50000)
    execute_values(cur, "INSERT INTO Exercer_Metier VALUES %s ON CONFLICT DO NOTHING", pairs_metier, page_size=50000)
    execute_values(cur, "INSERT INTO Oeuvres_Connues VALUES %s ON CONFLICT DO NOTHING", pairs_oeuvres_connues, page_size=50000)
    print(f"[2/7] PERSONNE, METIER, Exercer_Metier et Oeuvres_Connues insérés en {time.time() - t0:.2f}s")
    del rows_personne, rows_metier, pairs_metier, pairs_oeuvres_connues


    # importation des données depuis tmp_title_ratings (remplit EVALUATION)
    t0 = time.time()

    cur.execute("SELECT tconst, averageRating, numVotes FROM tmp_title_ratings;")

    rows_evaluation = []

    for id_oeuvre, rating_str, votes_str in cur.fetchall():
        if id_oeuvre not in valid_oeuvres:
            continue

        note_moyenne = float(rating_str) if rating_str else None
        nombre_votes = to_int(votes_str)

        rows_evaluation.append((id_oeuvre, note_moyenne, nombre_votes))

    execute_values(cur, "INSERT INTO EVALUATION VALUES %s ON CONFLICT DO NOTHING", rows_evaluation, page_size=50000)
    print(f"[3/7] EVALUATION insérée en {time.time() - t0:.2f}s")
    del rows_evaluation


    # importation des données depuis tmp_title_akas (remplit TITRE_LOCALISE)
    t0 = time.time()

    cur.execute("""
        SELECT titleId, ordering, title, region, language, 
               types, attributes, isOriginalTitle 
        FROM tmp_title_akas;
    """)

    rows_titre_localise = []

    for id_oeuvre, ordering_str, titre, code_region, code_langue, type_diffusion, attributs, is_original_str in cur.fetchall():
        if id_oeuvre not in valid_oeuvres:
            continue
        if not ordering_str or not ordering_str.isdigit():
            continue
        if not titre:
            continue

        numero_ordre = int(ordering_str)

        if is_original_str == "1":
            est_titre_original = True
        elif is_original_str == "0":
            est_titre_original = False
        else:
            est_titre_original = None

        rows_titre_localise.append((id_oeuvre, numero_ordre, titre, code_region, code_langue, type_diffusion, attributs, est_titre_original))

    execute_values(cur, "INSERT INTO TITRE_LOCALISE VALUES %s ON CONFLICT DO NOTHING", rows_titre_localise, page_size=50000)
    print(f"[4/7] TITRE_LOCALISE insérée en {time.time() - t0:.2f}s")
    del rows_titre_localise


    # importation des données depuis tmp_title_episode (remplit EPISODE)
    t0 = time.time()

    cur.execute("""
        SELECT tconst, episodeNumber, seasonNumber, parentTconst 
        FROM tmp_title_episode;
    """)

    rows_episode = []

    for id_oeuvre_1, episode_str, season_str, id_oeuvre in cur.fetchall():
        if id_oeuvre_1 not in valid_oeuvres or id_oeuvre not in valid_oeuvres:
            continue

        numero_episode = to_int(episode_str)
        numero_saison = to_int(season_str)

        rows_episode.append((id_oeuvre_1, numero_episode, numero_saison, id_oeuvre))

    execute_values(cur, "INSERT INTO EPISODE VALUES %s ON CONFLICT DO NOTHING", rows_episode, page_size=50000)
    print(f"[5/7] EPISODE insérée en {time.time() - t0:.2f}s")
    del rows_episode


    # importation des données depuis tmp_title_principals (remplit DISTRIBUTION)
    t0 = time.time()

    cur.execute("""
        SELECT tconst, ordering, category, job, characters, nconst 
        FROM tmp_title_principals;
    """)

    rows_distribution = []

    for id_oeuvre, ordering_str, categorie_metier, intitule_poste, characters_str, id_personne in cur.fetchall():
        if id_oeuvre not in valid_oeuvres or id_personne not in valid_personnes:
            continue
        if not ordering_str or not ordering_str.isdigit():
            continue

        ordre_generique = int(ordering_str)

        if characters_str:
            noms_personnages = characters_str.strip("[]").replace('"', "")
        else:
            noms_personnages = None

        rows_distribution.append((id_oeuvre, ordre_generique, categorie_metier, intitule_poste, noms_personnages, id_personne))

    execute_values(cur, "INSERT INTO DISTRIBUTION VALUES %s ON CONFLICT DO NOTHING", rows_distribution, page_size=50000)
    print(f"[6/7] DISTRIBUTION insérée en {time.time() - t0:.2f}s")
    del rows_distribution


    # importation des données depuis tmp_title_crew (remplit Realiser et Scenariser)
    t0 = time.time()

    cur.execute("SELECT tconst, directors, writers FROM tmp_title_crew;")

    pairs_realiser = []
    pairs_scenariser = []

    for id_oeuvre, directors_str, writers_str in cur.fetchall():
        if id_oeuvre not in valid_oeuvres:
            continue

        if directors_str:
            for director in directors_str.split(","):
                id_personne = director.strip()
                if id_personne in valid_personnes:
                    pairs_realiser.append((id_oeuvre, id_personne))

        if writers_str:
            for writer in writers_str.split(","):
                id_personne = writer.strip()
                if id_personne in valid_personnes:
                    pairs_scenariser.append((id_oeuvre, id_personne))

    execute_values(cur, "INSERT INTO Realiser VALUES %s ON CONFLICT DO NOTHING", pairs_realiser, page_size=50000)
    execute_values(cur, "INSERT INTO Scenariser VALUES %s ON CONFLICT DO NOTHING", pairs_scenariser, page_size=50000)
    print(f"[7/7] Realiser et Scenariser insérés en {time.time() - t0:.2f}s")
    del pairs_realiser, pairs_scenariser

    t0 = time.time()
    conn.commit()
    print(f"Commit final effectué en {time.time() - t0:.2f}s")

    cur.close()
    conn.close()

    duree_totale = time.time() - debut_total
    print(f"Transfert terminé en {duree_totale:.2f}s ({duree_totale / 60:.2f} min)")


if __name__ == "__main__":
    main()
