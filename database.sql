begin;

DROP SCHEMA IF EXISTS database CASCADE;
create schema database;
set search_path to database;

CREATE TABLE Coupe_Du_Monde (
    edition int4 UNIQUE NOT NULL,
    date_debut date NOT NULL,
    date_fin date NOT NULL,
    CONSTRAINT debut_realiste CHECK (date_debut >= '1930-07-13'),
    CONSTRAINT debut_avant_fin CHECK (date_debut <= date_fin),
    CONSTRAINT edition_positive CHECK (edition >= 1),
    PRIMARY KEY (edition));

CREATE TABLE pays_enum (
    pays varchar(255) NOT NULL,
    PRIMARY KEY (pays));

CREATE TABLE pays_coupe (
    pays varchar(255) NOT NULL,
    edition int4 NOT NULL,
    PRIMARY KEY (pays, edition));

ALTER TABLE pays_coupe
    ADD CONSTRAINT fk_pays_coupe
        FOREIGN KEY (edition)
            REFERENCES Coupe_Du_Monde (edition);

ALTER TABLE pays_coupe
    ADD CONSTRAINT fk_pays_enum
        FOREIGN KEY (pays)
            REFERENCES pays_enum (pays);

CREATE TABLE Stade (
    nom varchar(255) NOT NULL,
    ville varchar(255) NOT NULL,
    capacite int4 NOT NULL,
    pays_stade varchar(255) NOT NULL,
    annee_construction int4 NOT NULL,
    CONSTRAINT capacite_positive CHECK (capacite >= 1),
    PRIMARY KEY (nom, ville));

ALTER TABLE Stade
    ADD CONSTRAINT fk_pays_enum
        FOREIGN KEY (pays_stade)
            REFERENCES pays_enum (pays);

CREATE TABLE Personne (
    personne_id SERIAL NOT NULL,
    nom varchar(255) NOT NULL,
    prenom varchar(255) NOT NULL,
    ddn date NOT NULL,
    pays_natal varchar(255) NOT NULL,
    sexe varchar(1) NOT NULL,
    CONSTRAINT sexe_valide CHECK (sexe IN ('M', 'F', 'X')),
    PRIMARY KEY (personne_id));

ALTER TABLE Personne
    ADD CONSTRAINT fk_pays_enum
        FOREIGN KEY (pays_natal)
            REFERENCES pays_enum (pays);

CREATE TABLE Entraineur (
    personne_id int4 NOT NULL,
    entraineur_depuis date NOT NULL,
    PRIMARY KEY (personne_id));

ALTER TABLE Entraineur
    ADD CONSTRAINT fk_entraineur_personne
        FOREIGN KEY (personne_id)
            REFERENCES Personne (personne_id);

CREATE TABLE Equipe_Foot (
    nation varchar(255) NOT NULL,
    edition_coupe int4 NOT NULL,
    entraineur_id int4 NOT NULL,
    placement int4 NOT NULL,
    CONSTRAINT placement_positive CHECK (placement >= 1),
    PRIMARY KEY (nation, edition_coupe));

ALTER TABLE Equipe_Foot
    ADD CONSTRAINT fk_match_entraineur
        FOREIGN KEY (entraineur_id)
            REFERENCES Entraineur (personne_id);

ALTER TABLE Equipe_Foot
    ADD CONSTRAINT fk_equipe_coupe
        FOREIGN KEY (edition_coupe)
            REFERENCES Coupe_Du_Monde (edition);

ALTER TABLE Equipe_Foot
    ADD CONSTRAINT fk_pays_enum
        FOREIGN KEY (nation)
            REFERENCES pays_enum (pays);

CREATE TABLE Joueur (
    personne_id int4 NOT NULL,
    joueur_depuis date NOT NULL,
    PRIMARY KEY (personne_id));

ALTER TABLE Joueur
    ADD CONSTRAINT fk_joueur_personne
        FOREIGN KEY (personne_id)
            REFERENCES Personne (personne_id);

CREATE TABLE equipes_pro_enum (
    equipe varchar(255) NOT NULL,
    PRIMARY KEY (equipe));

CREATE TABLE Joueur_equipe (
    joueur_id int4 NOT NULL,
    nation varchar(255) NOT NULL,
    edition_coupe int4 NOT NULL,
    position varchar(255) NOT NULL,
    numero_dossard int4 NOT NULL,
    equipe_ligue_professionnelle varchar(255) NOT NULL,
    CONSTRAINT numero_positive CHECK (numero_dossard >= 0),
    CONSTRAINT position_valide CHECK (position IN ('Avant-centre', 'Arriere latéral',
                                                   'Millieu defensif', 'Millieu offensif',
                                                   'Gardien de but', 'Attaquant de pointe')),
    PRIMARY KEY (joueur_id, nation, edition_coupe));

ALTER TABLE Joueur_equipe
    ADD CONSTRAINT fk_joueur_equipe_joueur
        FOREIGN KEY (joueur_id)
            REFERENCES Joueur (personne_id);

ALTER TABLE Joueur_equipe
    ADD CONSTRAINT fk_joueur_equipe_equipe
        FOREIGN KEY (nation, edition_coupe)
            REFERENCES Equipe_Foot (nation, edition_coupe);

ALTER TABLE Joueur_equipe
    ADD CONSTRAINT fk_equipe_pro_enum
        FOREIGN KEY (equipe_ligue_professionnelle)
            REFERENCES equipes_pro_enum (equipe);

CREATE TABLE Collaborateur (
    personne_id int4 NOT NULL,
    expertise varchar(255) NOT NULL,
    collaborateur_depuis varchar(255) NOT NULL,
    CONSTRAINT expertise_valide CHECK (expertise IN ('Medecin', 'Physiotherapeute',
                                                     'Psychologue sportif', 'Assistant entraineur')),
    PRIMARY KEY (personne_id));

ALTER TABLE Collaborateur
    ADD CONSTRAINT fk_collaborateur_personne
        FOREIGN KEY (personne_id)
            REFERENCES Personne (personne_id);

CREATE TABLE collaborateur_equipe (
    collaborateur_id int4 NOT NULL,
    nation varchar(255) NOT NULL,
    edition_coupe int4 NOT NULL,
    PRIMARY KEY (collaborateur_id,
               nation, edition_coupe));

ALTER TABLE collaborateur_equipe
    ADD CONSTRAINT fk_collaborateur_equipe_collaborateur
        FOREIGN KEY (collaborateur_id)
            REFERENCES Collaborateur (personne_id);

ALTER TABLE collaborateur_equipe
    ADD CONSTRAINT fk_collaborateur_equipe_equipe
        FOREIGN KEY (nation, edition_coupe)
            REFERENCES Equipe_Foot (nation, edition_coupe);



CREATE TABLE Match_Foot (
    date date NOT NULL,
    nation1 varchar(255) NOT NULL,
    nation2 varchar(255) NOT NULL,
    rang varchar(255) NOT NULL,
    score_equipe_1 int4 NOT NULL,
    score_equipe_2 int4 NOT NULL,
    edition_coupe int4 NOT NULL,
    stade_nom varchar(255) NOT NULL,
    stade_ville varchar(255) NOT NULL,
    CONSTRAINT date_realiste CHECK (date >= '1930-07-13'),
    CONSTRAINT scores_positives CHECK (score_equipe_1 >= 0 AND score_equipe_2 >= 0),
    CONSTRAINT rang_valide CHECK (rang IN ('Ronde de groupe', 'Ronde de 16',
                                           'Quart de finale', 'Semi-finale', 'Match de 3e place', 'Finale')),
    PRIMARY KEY (date, nation1, nation2));

ALTER TABLE Match_Foot
    ADD CONSTRAINT fk_match_coupe
        FOREIGN KEY (edition_coupe)
            REFERENCES Coupe_Du_Monde (edition);

ALTER TABLE Match_Foot
    ADD CONSTRAINT fk_match_stade
        FOREIGN KEY (stade_nom, stade_ville)
            REFERENCES Stade (nom, ville);

ALTER TABLE Match_Foot
    ADD CONSTRAINT fk_match_equipe_1
        FOREIGN KEY (nation1, edition_coupe)
            REFERENCES Equipe_Foot (nation, edition_coupe);

ALTER TABLE Match_Foot
    ADD CONSTRAINT fk_match_equipe_2
        FOREIGN KEY (nation2, edition_coupe)
            REFERENCES Equipe_Foot (nation, edition_coupe);

CREATE OR REPLACE FUNCTION check_date_edition() RETURNS trigger AS
$BODY$
declare
    actual_edition int4;
BEGIN
    SELECT edition into actual_edition
    FROM coupe_du_monde
    WHERE (date_debut <= NEW.date AND date_fin >= NEW.date );

    IF actual_edition IS NULL THEN
        raise exception 'ERREUR : date du match ne correspond pas a aucune coupe';
    END IF;

    IF actual_edition <> NEW.edition_coupe THEN
        raise exception 'ERREUR : date du match et edition de la coupe ne correspondent pas';
    END IF;

    RETURN NEW;
END;
$BODY$ language plpgsql;

CREATE TRIGGER match_insert BEFORE INSERT ON match_foot
    FOR EACH ROW
EXECUTE PROCEDURE check_date_edition();

CREATE TABLE Arbitre (
    personne_id int4 NOT NULL,
    arbitre_depuis date NOT NULL,
    PRIMARY KEY (personne_id));

ALTER TABLE Arbitre
    ADD CONSTRAINT fk_arbitre_personne
        FOREIGN KEY (personne_id)
            REFERENCES Personne (personne_id);

CREATE TABLE Arbitre_match (
    arbitre_id int4 NOT NULL,
    nation1 varchar(255) NOT NULL,
    nation2 varchar(255) NOT NULL,
    type_arbitre varchar(255) NOT NULL,
    date_match date NOT NULL,
    CONSTRAINT type_valide CHECK (type_arbitre IN ('Principal', 'Assistant')),
    PRIMARY KEY (arbitre_id, nation1, nation2, date_match));

ALTER TABLE Arbitre_match
    ADD CONSTRAINT fk_arbitre_match_arbitre
        FOREIGN KEY (arbitre_id)
            REFERENCES Arbitre (personne_id);

ALTER TABLE Arbitre_match
    ADD CONSTRAINT fk_arbitre_match_match
        FOREIGN KEY (date_match, nation1, nation2)
            REFERENCES Match_Foot (date, nation1, nation2);

CREATE TABLE Sanction (
    sanction_id SERIAL NOT NULL,
    joueur_id int4 NOT NULL,
    arbitre_id int4 NOT NULL,
    nation_equipe_1 varchar(255) NOT NULL,
    nation_equipe_2 varchar(255) NOT NULL,
    match_date date NOT NULL,
    couleur varchar(255) NOT NULL,
    CONSTRAINT couleur_valide CHECK (couleur IN ('Rouge', 'Jaune' )),
    PRIMARY KEY (sanction_id));

ALTER TABLE Sanction
    ADD CONSTRAINT fk_santion_joueur
        FOREIGN KEY (joueur_id)
            REFERENCES Joueur (personne_id);

ALTER TABLE Sanction
    ADD CONSTRAINT fk_sanction_arbitre
        FOREIGN KEY (arbitre_id)
            REFERENCES Arbitre (personne_id);

ALTER TABLE Sanction
    ADD CONSTRAINT fk_sanction_match
        FOREIGN KEY (match_date, nation_equipe_1, nation_equipe_2)
            REFERENCES Match_Foot (date, nation1, nation2);

commit;
