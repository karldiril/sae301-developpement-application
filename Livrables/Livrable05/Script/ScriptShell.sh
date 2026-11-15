#!/bin/bash
set -euo pipefail
# Configuration des répertoires
NEW_DIR="/home/ortoto/Documents/BUT2/SAE/S301/Validation_donnees"
OLD_DIR="/home/ortoto/Documents/BUT2/SAE/S301/donnees"
URL="https://datasets.imdbws.com"

SQL_SCRIPT="/home/ortoto/Documents/BUT2/SAE/S301/ScriptCréationTables.sql"
PYTHON_SCRIPT="/home/ortoto/Documents/BUT2/SAE/S301/ScriptImporationDonnees.py"

LOG_FILE="/home/ortoto/Documents/BUT2/SAE/S301/KPI.txt"

# On affiche la date et l'heure atuelles selon l'heure configurée sur la machine, puis on les enregistre dans le fichier log.
echo " "
echo " "
echo "Date de commencement d'exécution du fichier : $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "Date de commencement d'exécution du fichier : $(date '+%Y-%m-%d %H:%M:%S')"
echo " "
echo " "

FICHIERS=(
    "name.basics.tsv.gz"
    "title.akas.tsv.gz"
    "title.basics.tsv.gz"
    "title.crew.tsv.gz"
    "title.episode.tsv.gz"
    "title.principals.tsv.gz"
    "title.ratings.tsv.gz"
)

#Le temps global de tu script entier
DEBUT_GLOBAL=$(date +%s)

# Vérification des répertoires
if [[ ! -d "$NEW_DIR" || ! -d "$OLD_DIR" ]]; then
    echo "Erreur : un des répertoires n'existe pas"
    exit 1
fi

# Supprimer les téléchargements incomplets à la sortie
trap 'for fichier in "${FICHIERS[@]}"; do
    rm -f -- "$NEW_DIR/$fichier.part"
done' EXIT


#Le temps pour téléchargement et la vérification
DEBUT_DATA=$(date +%s)

# Ici on télécharge les fichier depuis l'URL à l'aide de curl, puis on les décompresse
for fichier in "${FICHIERS[@]}"; do

    echo "Téléchargement : $fichier"

    curl -fL --retry 3 \
        -o "$NEW_DIR/$fichier.part" \
        "$URL/$fichier"

    if ! gzip -t "$NEW_DIR/$fichier.part"; then
        echo "Erreur d'intégrité : $fichier"
        exit 1
    fi

done

# Ici on compare les fichiers téléchargés avec ceux présents dans OLD_DIR avec la cmd "cmp", si un fichier est identique on ne fait rien, si il y a un changement on remplace l'ancien fichier par ça nouvelle version. 

for fichier in "${FICHIERS[@]}"; do

    mv -f "$NEW_DIR/$fichier.part" "$NEW_DIR/$fichier"

    if cmp -s "$NEW_DIR/$fichier" "$OLD_DIR/$fichier"; then

        echo "$fichier : aucun changement"

    else

        echo "$fichier : nouvelle version détectée"

        cp -f "$NEW_DIR/$fichier" "$OLD_DIR/$fichier.tmp"

        mv -f "$OLD_DIR/$fichier.tmp" "$OLD_DIR/$fichier"

        echo "$fichier : mis à jour"

    fi

done

echo "Téléchargement et mise à jour terminés"

#Le temps pour téléchargement et la vérification
FIN_DATA=$(date +%s)

echo " "
echo " "
echo "Duree Mise de ajour des fichiers DATA : $((FIN_DATA - DEBUT_DATA)) secondes" >> "$LOG_FILE"
echo "Duree Mise de ajour des fichiers DATA : $((FIN_DATA - DEBUT_DATA)) secondes"
echo " "
echo " "


# Supprimer la base STAR si elle existe

sudo -u postgres dropdb --if-exists star


# Supprimer le rôle gestionnaire s'il existe

sudo -u postgres psql -c \
    "DROP ROLE IF EXISTS gestionnaire;"


# Créer le rôle gestionnaire

sudo -u postgres psql -c \
    "CREATE ROLE gestionnaire WITH LOGIN PASSWORD '1234';"


# Créer la base STAR

sudo -u postgres createdb -O gestionnaire star


#Le temps pour le script sql
DEBUT_SQL=$(date +%s)

# Exécute le script SQL avec cette configuration
PGPASSWORD="1234" psql \
    -h localhost \
    -U gestionnaire \
    -v ON_ERROR_STOP=1 \
    -d star \
    -f "$SQL_SCRIPT"

#Le temps pour le script sql
FIN_SQL=$(date +%s)

echo " "
echo " "
echo "Duree du script SQL : $((FIN_SQL - DEBUT_SQL)) secondes" >> "$LOG_FILE"
echo "Duree du script SQL : $((FIN_SQL - DEBUT_SQL)) secondes"
echo " "
echo " "


#Le temps pour le script en python
DEBUT_PYTHON=$(date +%s)

# Exécuter le script Python
python3 "$PYTHON_SCRIPT"

#Le temps pour le script en python
FIN_PYTHON=$(date +%s)

echo " "
echo " "
echo "Duree du script Python : $((FIN_PYTHON - DEBUT_PYTHON)) secondes" >> "$LOG_FILE"
echo "Duree du script Python : $((FIN_PYTHON - DEBUT_PYTHON)) secondes"
echo " "
echo " "

echo "Toutes les opérations sont terminées."

#Le temps global de tu script entier
FIN_GLOBAL=$(date +%s)

echo " "
echo "Duree TOTALE : $((FIN_GLOBAL - DEBUT_GLOBAL)) secondes" >> "$LOG_FILE"
echo "Duree TOTALE : $((FIN_GLOBAL - DEBUT_GLOBAL)) secondes"
echo "----------------------------------------" >> "$LOG_FILE"
echo " "
