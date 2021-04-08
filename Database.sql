begin;

CREATE TABLE Coupe_Du_Monde (
    edition int4 UNIQUE NOT NULL,
    date_debut date NOT NULL,
    date_fin date NOT NULL,
    PRIMARY KEY (edition));

CREATE TABLE Entraineur (
    personne_id int4 NOT NULL,
    entraineur_depuis date NOT NULL,
    PRIMARY KEY (personne_id));

CREATE TABLE Collaborateur (
    personne_id int4 NOT NULL,
    expertise varchar(255) NOT NULL,
    collaborateur_depuis varchar(255) NOT NULL,
    PRIMARY KEY (personne_id));

CREATE TABLE Sanction (
    sanction_id SERIAL NOT NULL,
    joueur_id int4 NOT NULL,
    arbitre_id int4 NOT NULL,
    nation_equipe_1 varchar(255) NOT NULL,
    nation_equipe_2 varchar(255) NOT NULL,
    match_date date NOT NULL,
    couleur varchar(255) NOT NULL,
    description varchar(255) NOT NULL,
    PRIMARY KEY (sanction_id));

CREATE TABLE Arbitre (
    personne_id int4 NOT NULL,
    arbitre_depuis date NOT NULL,
    PRIMARY KEY (personne_id));

CREATE TABLE Joueur (
    personne_id int4 NOT NULL,
    joueur_depuis date NOT NULL,
    PRIMARY KEY (personne_id));

CREATE TABLE Joueur_equipe (
    joueur_id int4 NOT NULL,
    nation varchar(255) NOT NULL,
    edition_coupe int4 NOT NULL,
    position varchar(255) NOT NULL,
    numero_dossard int4 NOT NULL,
    equipe_ligue_professionnelle varchar(255) NOT NULL,
    PRIMARY KEY (joueur_id, nation, edition_coupe));

CREATE TABLE Stade (
    nom varchar(255) NOT NULL,
    ville varchar(255) NOT NULL,
    capacite int4 NOT NULL,
    pays_stade varchar(255) NOT NULL,
    annee_construction int4 NOT NULL,
    PRIMARY KEY (nom, ville));

CREATE TABLE Arbitre_match (
    arbitre_id int4 NOT NULL,
    nation1 varchar(255) NOT NULL,
    nation2 varchar(255) NOT NULL,
    type_arbitre varchar(255) NOT NULL,
    date_match date NOT NULL,
    PRIMARY KEY (arbitre_id, nation1, nation2, date_match));

CREATE TABLE Personne (
    personne_id SERIAL NOT NULL,
    nom varchar(255) NOT NULL,
    prenom varchar(255) NOT NULL,
    ddn date NOT NULL,
    pays_natal varchar(255) NOT NULL,
    sexe varchar(1) NOT NULL,
    PRIMARY KEY (personne_id));

CREATE TABLE collaborateur_equipe (
    collaborateur_id int4 NOT NULL,
    nation varchar(255) NOT NULL,
    edition_coupe int4 NOT NULL,
    PRIMARY KEY (collaborateur_id,
    nation, edition_coupe));

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
    PRIMARY KEY ("date", nation1, nation2));

CREATE TABLE pays_coupe (
    pays varchar(255) NOT NULL,
    edition int4 NOT NULL,
    PRIMARY KEY (pays, edition));

CREATE TABLE Equipe_Foot (
    nation varchar(255) NOT NULL,
    edition_coupe int4 NOT NULL,
    entraineur_id int4 NOT NULL,
    placement int4 NOT NULL,
    PRIMARY KEY (nation, edition_coupe));

ALTER TABLE Sanction
 ADD CONSTRAINT fk_santion_joueur
 FOREIGN KEY (joueur_id)
 REFERENCES Joueur (personne_id);

ALTER TABLE Joueur
 ADD CONSTRAINT fk_joueur_personne
 FOREIGN KEY (personne_id)
 REFERENCES Personne (personne_id);

ALTER TABLE Entraineur
 ADD CONSTRAINT fk_entraineur_personne
 FOREIGN KEY (personne_id)
 REFERENCES Personne (personne_id);

ALTER TABLE Collaborateur
 ADD CONSTRAINT fk_collaborateur_personne
 FOREIGN KEY (personne_id)
 REFERENCES Personne (personne_id);

ALTER TABLE Arbitre
 ADD CONSTRAINT fk_arbitre_personne
 FOREIGN KEY (personne_id)
 REFERENCES Personne (personne_id);
 
ALTER TABLE collaborateur_equipe
 ADD CONSTRAINT fk_collaborateur_equipe_collaborateur
 FOREIGN KEY (collaborateur_id)
 REFERENCES Collaborateur (personne_id);
 
ALTER TABLE Sanction
 ADD CONSTRAINT fk_sanction_arbitre
 FOREIGN KEY (arbitre_id)
 REFERENCES Arbitre (personne_id);
 
ALTER TABLE Arbitre_match
 ADD CONSTRAINT fk_arbitre_match_arbitre
 FOREIGN KEY (arbitre_id)
 REFERENCES Arbitre (personne_id);
 
ALTER TABLE Joueur_equipe
 ADD CONSTRAINT fk_joueur_equipe_joueur
 FOREIGN KEY (joueur_id)
 REFERENCES Joueur (personne_id);
 
ALTER TABLE Arbitre_match
 ADD CONSTRAINT fk_arbitre_match_match
 FOREIGN KEY (date_match, nation1, nation2)
 REFERENCES Match_Foot (date, nation1, nation2);
 
ALTER TABLE Sanction
 ADD CONSTRAINT fk_sanction_match
 FOREIGN KEY (match_date, nation_equipe_1, nation_equipe_2)
 REFERENCES Match_Foot (date, nation1, nation2);
 
ALTER TABLE Match_Foot
 ADD CONSTRAINT fk_match_coupe
 FOREIGN KEY (edition_coupe)
 REFERENCES Coupe_Du_Monde (edition);
 
ALTER TABLE Match_Foot
 ADD CONSTRAINT fk_match_stade
 FOREIGN KEY (stade_nom, stade_ville)
 REFERENCES Stade (nom, ville);
 
ALTER TABLE pays_coupe
 ADD CONSTRAINT fk_pays_coupe
 FOREIGN KEY (edition)
 REFERENCES Coupe_Du_Monde (edition);
 
ALTER TABLE Joueur_equipe
 ADD CONSTRAINT fk_joueur_equipe_equipe
 FOREIGN KEY (nation, edition_coupe)
 REFERENCES Equipe_Foot (nation, edition_coupe);
 
ALTER TABLE collaborateur_equipe
 ADD CONSTRAINT fk_collaborateur_equipe_equipe
 FOREIGN KEY (nation, edition_coupe)
 REFERENCES Equipe_Foot (nation, edition_coupe);
 
ALTER TABLE Match_Foot
 ADD CONSTRAINT fk_match_equipe_1
 FOREIGN KEY (nation1, edition_coupe)
 REFERENCES Equipe_Foot (nation, edition_coupe);
 
ALTER TABLE Match_Foot
 ADD CONSTRAINT fk_match_equipe_2
 FOREIGN KEY (nation2, edition_coupe)
 REFERENCES Equipe_Foot (nation, edition_coupe);
 
ALTER TABLE Equipe_Foot
 ADD CONSTRAINT fk_match_entraineur
 FOREIGN KEY (entraineur_id)
 REFERENCES Entraineur (personne_id);
 
ALTER TABLE Equipe_Foot
 ADD CONSTRAINT fk_equipe_coupe
 FOREIGN KEY (edition_coupe)
 REFERENCES Coupe_Du_Monde (edition);
 

commit;
