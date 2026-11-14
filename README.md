# SAE301-Developpement-Application 

Application web permettant d'explorer, de croiser et d'analyser des données cinématographiques issues des interfaces publiques IMDb.

Projet réalisé dans le cadre du **BUT 2 Informatique (FA)** à l'**IUT de Villetaneuse — Université Sorbonne Paris Nord** (Année 2026-2027).

**Nom de l’équipe :** 404 ( C )

**Notre équipe est composée de quatre membres :**

- Théo PALUGAN
- Karl DIRIL
- Manase SAMUEL DIAKOLO
- Lucas CHEN

**La répartition du rôle de manager va s'effectuer sur ce schéma durant toute la SAE :**

Théo PALUGAN -> Karl DIRIL -> Manase SAMUEL DIAKOLO -> Lucas CHEN -> Théo PALUGAN -> …

Le premier manager sera donc Théo (du 05/10/2026 au 18/10/2026).

## Schéma relationnel de la base de données.  


### 1. Entités principales

**Oeuvres** (<ins>id_oeuvre</ins>, type_oeuvre, titre_principal, titre_original, pour_adulte, annee_sortie, annee_fin, duree_minutes)  
**Personnes** (<ins>id_personne</ins>, nom_complet, annee_naissance, annee_deces)  


### 2. Tables dépendantes

**Evaluations** (<ins>#id_oeuvre</ins>, note_moyenne, nombre_votes)  
**Titres_Localises** (<ins>#id_oeuvre, ordre</ins>, titre, code_region, code_langue, type_diffusion, attributs_supplementaires, est_titre_original)  
**Episodes** (<ins>#id_episode</ins>, #id_serie_parente, numero_saison, numero_episode)  
**Distribution** (<ins>#id_oeuvre, ordre_generique</ins>, #id_personne, categorie_metier, intitule_poste, noms_personnages)  
**Genre** (<ins>id_genre</ins>, nom_genre)  
**Metier** (<ins>id_metier</ins>, nom_metier)  


### 3. Tables d'association

**Oeuvre_Genres** (<ins>#id_oeuvre, #id_genre</ins>)  
**Realisateurs** (<ins>#id_oeuvre, #id_personne</ins>)  
**Scenaristes** (<ins>#id_oeuvre, #id_personne</ins>)  
**Personne_Metiers** (<ins>#id_personne, #id_metier</ins>)  
**Oeuvres_Connues** (<ins>#id_personne, #id_oeuvre</ins>)  

<br>
<br>

![Schéma relationnel](Schéma_relationnel_image/Schema_relationnel.png)
