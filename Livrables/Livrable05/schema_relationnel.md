## Schéma relationnel


### 1. Entités principales
- **Oeuvres** (<ins>id_oeuvre</ins>, type_oeuvre, titre_principal, titre_original, pour_adulte, annee_sortie, annee_fin, duree_minutes)
- **Personnes** (<ins>id_personne</ins>, nom_complet, annee_naissance, annee_deces)

### 2. Tables dépendantes
- **Evaluations** (<ins>#id_oeuvre</ins>, note_moyenne, nombre_votes)
- **Titres_Localises** (<ins>#id_oeuvre</ins>, <ins>ordre</ins>, titre, code_region, code_langue, type_diffusion, attributs_supplementaires, est_titre_original)
- **Episodes** (<ins>#id_episode</ins>, #id_serie_parente, numero_saison, numero_episode)
- **Distribution** (<ins>#id_oeuvre</ins>, <ins>ordre_generique</ins>, #id_personne, categorie_metier, intitule_poste, noms_personnages)

### 3. Tables d'association
- **Oeuvre_Genres** (<ins>#id_oeuvre</ins>, <ins>#id_genre</ins>)
- **Realisateurs** (<ins>#id_oeuvre</ins>, <ins>#id_personne</ins>)
- **Scenaristes** (<ins>#id_oeuvre</ins>, <ins>#id_personne</ins>)
- **Personne_Metiers** (<ins>#id_personne</ins>, <ins>#id_metier</ins>)
- **Oeuvres_Connues** (<ins>#id_personne</ins>, <ins>#id_oeuvre</ins>)
