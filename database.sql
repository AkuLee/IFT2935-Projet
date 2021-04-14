-- Load the full database one shot
CREATE DATABASE projet_foot;
\c projet_foot

begin;
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

begin;

INSERT INTO equipes_pro_enum VALUES ('FC Bayern');
INSERT INTO equipes_pro_enum VALUES ('Olympique Lyonnais');
INSERT INTO equipes_pro_enum VALUES ('France National');
INSERT INTO equipes_pro_enum VALUES ('Real Madrid');
INSERT INTO equipes_pro_enum VALUES ('Manchester United F.C.');
INSERT INTO equipes_pro_enum VALUES ('Arsenal F.C.');
INSERT INTO equipes_pro_enum VALUES ('Chelsea F.C.');
INSERT INTO equipes_pro_enum VALUES ('Brazil nationnal');
INSERT INTO equipes_pro_enum VALUES ('AS Monaco');
INSERT INTO equipes_pro_enum VALUES ('Liverpool F.C.');
INSERT INTO equipes_pro_enum VALUES ('Spain N.F.C.');
INSERT INTO equipes_pro_enum VALUES ('F.C. Barcelona');
INSERT INTO pays_enum VALUES ('Uruguay');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Howard', 'George', '1971-04-04', 'Uruguay', 'M');
INSERT INTO joueur VALUES ('1', '1999-08-17');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Sanders', 'Robert', '1975-03-04', 'Uruguay', 'M');
INSERT INTO joueur VALUES ('2', '1998-11-03');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Cooper', 'Steven', '1981-09-12', 'Uruguay', 'M');
INSERT INTO joueur VALUES ('3', '2001-03-14');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Jones', 'Eugene', '1979-08-04', 'Uruguay', 'M');
INSERT INTO joueur VALUES ('4', '2001-05-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Viviano', 'Mark', '1978-06-22', 'Uruguay', 'M');
INSERT INTO joueur VALUES ('5', '2001-06-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Griffith', 'Alfonso', '1977-08-13', 'Uruguay', 'M');
INSERT INTO joueur VALUES ('6', '2002-06-24');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Palacios', 'John', '1971-12-11', 'Uruguay', 'M');
INSERT INTO entraineur VALUES ('7', '2001-03-27');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Tighe', 'Jason', '1984-05-25', 'Uruguay', 'M');
INSERT INTO collaborateur VALUES ('8', 'Psychologue sportif', '1998-12-03');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Lipson', 'Dusty', '1983-08-05', 'Uruguay', 'M');
INSERT INTO collaborateur VALUES ('9', 'Medecin', '2001-12-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Henry', 'August', '1976-11-22', 'Uruguay', 'M');
INSERT INTO arbitre VALUES ('10', '2003-09-17');

INSERT INTO pays_enum VALUES ('Italie');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Freudenthal', 'Buford', '1975-12-08', 'Italie', 'M');
INSERT INTO joueur VALUES ('11', '2002-04-27');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Hecht', 'Leonard', '1982-04-12', 'Italie', 'M');
INSERT INTO joueur VALUES ('12', '2001-07-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Delisa', 'Thomas', '1978-05-23', 'Italie', 'M');
INSERT INTO joueur VALUES ('13', '2000-10-24');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Huston', 'Gregory', '1977-12-22', 'Italie', 'M');
INSERT INTO joueur VALUES ('14', '1998-08-15');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Carothers', 'James', '1982-09-19', 'Italie', 'M');
INSERT INTO joueur VALUES ('15', '1999-03-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Simmons', 'Brian', '1983-10-18', 'Italie', 'M');
INSERT INTO joueur VALUES ('16', '1999-06-14');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Joslyn', 'Philip', '1972-04-08', 'Italie', 'M');
INSERT INTO entraineur VALUES ('17', '1997-04-09');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Harvey', 'Anthony', '1970-07-05', 'Italie', 'M');
INSERT INTO collaborateur VALUES ('18', 'Medecin', '2000-06-21');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Pocai', 'Kenneth', '1977-12-28', 'Italie', 'M');
INSERT INTO collaborateur VALUES ('19', 'Physiotherapeute', '2001-06-09');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Bishop', 'Richard', '1970-06-25', 'Italie', 'M');
INSERT INTO arbitre VALUES ('20', '2003-08-09');

INSERT INTO pays_enum VALUES ('France');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Jordan', 'Edward', '1973-04-05', 'France', 'M');
INSERT INTO joueur VALUES ('21', '2003-11-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Eagen', 'Robert', '1977-07-10', 'France', 'M');
INSERT INTO joueur VALUES ('22', '2001-04-17');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Morago', 'Carl', '1974-09-20', 'France', 'M');
INSERT INTO joueur VALUES ('23', '2000-07-20');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Daniels', 'Richard', '1974-06-19', 'France', 'M');
INSERT INTO joueur VALUES ('24', '1998-08-12');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Mooney', 'Daniel', '1977-10-05', 'France', 'M');
INSERT INTO joueur VALUES ('25', '1998-10-23');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Taylor', 'Willard', '1977-04-15', 'France', 'M');
INSERT INTO joueur VALUES ('26', '2003-05-15');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Barber', 'Kenneth', '1981-10-14', 'France', 'M');
INSERT INTO entraineur VALUES ('27', '1999-07-23');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Cecilio', 'Dan', '1983-05-26', 'France', 'M');
INSERT INTO collaborateur VALUES ('28', 'Physiotherapeute', '2000-11-03');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Steven', 'Lloyd', '1976-03-14', 'France', 'M');
INSERT INTO collaborateur VALUES ('29', 'Psychologue sportif', '1997-05-13');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Whitton', 'Eric', '1971-11-22', 'France', 'M');
INSERT INTO arbitre VALUES ('30', '2003-10-03');

INSERT INTO pays_enum VALUES ('Canada');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Artis', 'Reinaldo', '1984-06-16', 'Canada', 'M');
INSERT INTO joueur VALUES ('31', '2001-10-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Maciel', 'David', '1984-11-07', 'Canada', 'M');
INSERT INTO joueur VALUES ('32', '1999-10-24');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Rinderer', 'Casey', '1983-09-16', 'Canada', 'M');
INSERT INTO joueur VALUES ('33', '1999-05-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Konecny', 'Gerald', '1970-10-18', 'Canada', 'M');
INSERT INTO joueur VALUES ('34', '1999-08-13');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Williams', 'Wayne', '1983-05-11', 'Canada', 'M');
INSERT INTO joueur VALUES ('35', '1999-11-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Taylor', 'Frank', '1977-11-05', 'Canada', 'M');
INSERT INTO joueur VALUES ('36', '1998-04-06');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Tapia', 'Charles', '1983-06-06', 'Canada', 'M');
INSERT INTO entraineur VALUES ('37', '1997-08-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Bowen', 'Harvey', '1976-05-24', 'Canada', 'M');
INSERT INTO collaborateur VALUES ('38', 'Psychologue sportif', '1998-12-19');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Tucker', 'Robert', '1978-10-03', 'Canada', 'M');
INSERT INTO collaborateur VALUES ('39', 'Medecin', '1997-09-19');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Johnson', 'William', '1976-04-20', 'Canada', 'M');
INSERT INTO arbitre VALUES ('40', '1999-12-27');

INSERT INTO pays_enum VALUES ('Bresil');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Otter', 'Micheal', '1981-09-26', 'Bresil', 'M');
INSERT INTO joueur VALUES ('41', '2003-05-13');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Herbert', 'Derrick', '1981-05-15', 'Bresil', 'M');
INSERT INTO joueur VALUES ('42', '1998-11-18');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Jacquez', 'Allan', '1977-09-23', 'Bresil', 'M');
INSERT INTO joueur VALUES ('43', '2002-06-12');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Nordahl', 'David', '1977-11-27', 'Bresil', 'M');
INSERT INTO joueur VALUES ('44', '2003-05-06');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Danley', 'John', '1972-03-03', 'Bresil', 'M');
INSERT INTO joueur VALUES ('45', '1998-07-17');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Ballintyn', 'Jessie', '1971-04-21', 'Bresil', 'M');
INSERT INTO joueur VALUES ('46', '2001-05-14');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Defibaugh', 'Harvey', '1979-05-19', 'Bresil', 'M');
INSERT INTO entraineur VALUES ('47', '2003-04-18');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Deleon', 'Lester', '1971-04-12', 'Bresil', 'M');
INSERT INTO collaborateur VALUES ('48', 'Medecin', '2001-07-09');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Moore', 'Ernesto', '1982-08-23', 'Bresil', 'M');
INSERT INTO collaborateur VALUES ('49', 'Physiotherapeute', '2000-08-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Huckleberry', 'David', '1972-04-04', 'Bresil', 'M');
INSERT INTO arbitre VALUES ('50', '1997-04-14');

INSERT INTO pays_enum VALUES ('Suisse');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Harris', 'William', '1981-05-21', 'Suisse', 'M');
INSERT INTO joueur VALUES ('51', '1998-10-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Williams', 'Derek', '1972-04-09', 'Suisse', 'M');
INSERT INTO joueur VALUES ('52', '2000-10-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Quinones', 'Alex', '1972-07-15', 'Suisse', 'M');
INSERT INTO joueur VALUES ('53', '2000-09-12');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Furnace', 'James', '1970-12-05', 'Suisse', 'M');
INSERT INTO joueur VALUES ('54', '1999-10-12');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Para', 'Erwin', '1971-07-22', 'Suisse', 'M');
INSERT INTO joueur VALUES ('55', '2001-12-08');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Stovall', 'Ricky', '1977-10-27', 'Suisse', 'M');
INSERT INTO joueur VALUES ('56', '1998-04-18');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Rueluas', 'Jose', '1972-05-04', 'Suisse', 'M');
INSERT INTO entraineur VALUES ('57', '2002-09-26');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Binford', 'Steven', '1984-03-25', 'Suisse', 'M');
INSERT INTO collaborateur VALUES ('58', 'Physiotherapeute', '2002-07-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Shea', 'Vince', '1972-10-25', 'Suisse', 'M');
INSERT INTO collaborateur VALUES ('59', 'Psychologue sportif', '2003-08-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Williams', 'Christopher', '1970-09-10', 'Suisse', 'M');
INSERT INTO arbitre VALUES ('60', '2001-08-15');

INSERT INTO pays_enum VALUES ('Suede');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Hogston', 'Harry', '1970-11-14', 'Suede', 'M');
INSERT INTO joueur VALUES ('61', '1999-03-12');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Reese', 'Ronald', '1984-05-27', 'Suede', 'M');
INSERT INTO joueur VALUES ('62', '2001-11-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Mince', 'Tony', '1979-03-16', 'Suede', 'M');
INSERT INTO joueur VALUES ('63', '2001-09-08');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Haines', 'William', '1979-06-26', 'Suede', 'M');
INSERT INTO joueur VALUES ('64', '1998-06-08');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Cochran', 'John', '1976-10-09', 'Suede', 'M');
INSERT INTO joueur VALUES ('65', '1998-03-14');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Maxwell', 'Randall', '1976-09-05', 'Suede', 'M');
INSERT INTO joueur VALUES ('66', '1998-09-27');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Whitt', 'Robert', '1981-11-25', 'Suede', 'M');
INSERT INTO entraineur VALUES ('67', '2001-03-25');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Jones', 'Hector', '1973-03-09', 'Suede', 'M');
INSERT INTO collaborateur VALUES ('68', 'Psychologue sportif', '2001-03-12');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Jones', 'Anthony', '1977-07-08', 'Suede', 'M');
INSERT INTO collaborateur VALUES ('69', 'Medecin', '2002-07-18');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Arguelles', 'Mark', '1984-10-24', 'Suede', 'M');
INSERT INTO arbitre VALUES ('70', '1998-05-16');

INSERT INTO pays_enum VALUES ('Chili');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Smith', 'Tom', '1979-03-09', 'Chili', 'M');
INSERT INTO joueur VALUES ('71', '2002-08-20');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Fix', 'Edward', '1978-07-09', 'Chili', 'M');
INSERT INTO joueur VALUES ('72', '2003-08-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Argento', 'Robert', '1971-04-11', 'Chili', 'M');
INSERT INTO joueur VALUES ('73', '2000-07-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Dykes', 'Cruz', '1977-10-13', 'Chili', 'M');
INSERT INTO joueur VALUES ('74', '1997-03-08');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Baugh', 'James', '1982-08-27', 'Chili', 'M');
INSERT INTO joueur VALUES ('75', '2001-04-21');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Binder', 'William', '1971-12-14', 'Chili', 'M');
INSERT INTO joueur VALUES ('76', '2003-10-16');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Mills', 'Henry', '1982-11-10', 'Chili', 'M');
INSERT INTO entraineur VALUES ('77', '2003-05-21');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Pettit', 'Christian', '1971-04-28', 'Chili', 'M');
INSERT INTO collaborateur VALUES ('78', 'Medecin', '1998-04-06');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Macnab', 'Brian', '1975-03-25', 'Chili', 'M');
INSERT INTO collaborateur VALUES ('79', 'Physiotherapeute', '2000-11-16');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Charles', 'John', '1976-03-23', 'Chili', 'M');
INSERT INTO arbitre VALUES ('80', '2002-11-07');

INSERT INTO pays_enum VALUES ('Angleterre');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Guillermo', 'Ben', '1984-08-11', 'Angleterre', 'M');
INSERT INTO joueur VALUES ('81', '1999-10-17');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Cokley', 'Jason', '1974-03-22', 'Angleterre', 'M');
INSERT INTO joueur VALUES ('82', '2003-11-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Bustos', 'Donnell', '1979-06-18', 'Angleterre', 'M');
INSERT INTO joueur VALUES ('83', '2001-12-19');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Wyatt', 'Maurice', '1980-08-05', 'Angleterre', 'M');
INSERT INTO joueur VALUES ('84', '1999-12-17');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Chen', 'Michael', '1973-06-17', 'Angleterre', 'M');
INSERT INTO joueur VALUES ('85', '1999-11-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Shine', 'Linwood', '1977-10-19', 'Angleterre', 'M');
INSERT INTO joueur VALUES ('86', '2002-11-18');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Torrey', 'Frank', '1973-04-26', 'Angleterre', 'M');
INSERT INTO entraineur VALUES ('87', '2002-07-21');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Ray', 'Mark', '1982-09-26', 'Angleterre', 'M');
INSERT INTO collaborateur VALUES ('88', 'Physiotherapeute', '1999-06-17');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Rangel', 'David', '1983-07-14', 'Angleterre', 'M');
INSERT INTO collaborateur VALUES ('89', 'Psychologue sportif', '1997-09-25');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Neil', 'Leonard', '1978-12-25', 'Angleterre', 'M');
INSERT INTO arbitre VALUES ('90', '2002-09-12');

INSERT INTO pays_enum VALUES ('Mexique');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Pease', 'Stephen', '1970-09-13', 'Mexique', 'M');
INSERT INTO joueur VALUES ('91', '1998-07-26');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Wickham', 'Joe', '1978-05-16', 'Mexique', 'M');
INSERT INTO joueur VALUES ('92', '1998-07-09');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Barros', 'Donald', '1971-05-22', 'Mexique', 'M');
INSERT INTO joueur VALUES ('93', '2000-04-11');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Bray', 'Jospeh', '1976-03-06', 'Mexique', 'M');
INSERT INTO joueur VALUES ('94', '2002-08-21');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Brown', 'Marvin', '1979-11-20', 'Mexique', 'M');
INSERT INTO joueur VALUES ('95', '2000-12-19');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Delgado', 'Justin', '1972-09-07', 'Mexique', 'M');
INSERT INTO joueur VALUES ('96', '2003-10-25');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Joyner', 'Brain', '1971-12-10', 'Mexique', 'M');
INSERT INTO entraineur VALUES ('97', '2000-08-13');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Todd', 'Dale', '1980-09-23', 'Mexique', 'M');
INSERT INTO collaborateur VALUES ('98', 'Psychologue sportif', '1998-12-19');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Fiore', 'Jose', '1976-06-17', 'Mexique', 'M');
INSERT INTO collaborateur VALUES ('99', 'Medecin', '2001-05-06');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Lucas', 'Roger', '1974-06-13', 'Mexique', 'M');
INSERT INTO arbitre VALUES ('100', '2001-03-19');

INSERT INTO pays_enum VALUES ('Allemagne');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Cantu', 'Hubert', '1971-11-08', 'Allemagne', 'M');
INSERT INTO joueur VALUES ('101', '2002-12-21');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Moody', 'Charles', '1974-08-21', 'Allemagne', 'M');
INSERT INTO joueur VALUES ('102', '1998-12-24');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Hamilton', 'Charles', '1981-12-04', 'Allemagne', 'M');
INSERT INTO joueur VALUES ('103', '1998-09-17');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Cliff', 'Milton', '1981-10-12', 'Allemagne', 'M');
INSERT INTO joueur VALUES ('104', '1998-10-14');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Mcgrew', 'Jesse', '1971-10-27', 'Allemagne', 'M');
INSERT INTO joueur VALUES ('105', '1998-06-07');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Pittman', 'Richard', '1981-10-27', 'Allemagne', 'M');
INSERT INTO joueur VALUES ('106', '1998-05-05');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Rush', 'Vernon', '1982-03-25', 'Allemagne', 'M');
INSERT INTO entraineur VALUES ('107', '1997-12-20');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Owens', 'Billy', '1971-10-20', 'Allemagne', 'M');
INSERT INTO collaborateur VALUES ('108', 'Medecin', '2000-12-16');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Ayala', 'Gary', '1980-05-04', 'Allemagne', 'M');
INSERT INTO collaborateur VALUES ('109', 'Physiotherapeute', '2003-07-13');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Rodarte', 'Horace', '1979-05-16', 'Allemagne', 'M');
INSERT INTO arbitre VALUES ('110', '2003-09-04');

INSERT INTO pays_enum VALUES ('Portugal');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Deloney', 'Leroy', '1971-09-14', 'Portugal', 'M');
INSERT INTO joueur VALUES ('111', '2001-12-23');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Carter', 'David', '1975-07-08', 'Portugal', 'M');
INSERT INTO joueur VALUES ('112', '2001-11-03');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Collins', 'Francis', '1972-06-04', 'Portugal', 'M');
INSERT INTO joueur VALUES ('113', '1998-07-23');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Reeves', 'James', '1970-05-20', 'Portugal', 'M');
INSERT INTO joueur VALUES ('114', '2000-07-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Meyers', 'Mark', '1970-10-21', 'Portugal', 'M');
INSERT INTO joueur VALUES ('115', '1999-07-27');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Dash', 'William', '1983-10-28', 'Portugal', 'M');
INSERT INTO joueur VALUES ('116', '2003-07-11');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Cirino', 'Joseph', '1975-11-14', 'Portugal', 'M');
INSERT INTO entraineur VALUES ('117', '1998-03-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Henderson', 'Gilbert', '1981-03-15', 'Portugal', 'M');
INSERT INTO collaborateur VALUES ('118', 'Physiotherapeute', '2002-07-05');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Holloway', 'Willie', '1977-10-26', 'Portugal', 'M');
INSERT INTO collaborateur VALUES ('119', 'Psychologue sportif', '2002-08-25');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Mccollum', 'James', '1984-07-22', 'Portugal', 'M');
INSERT INTO arbitre VALUES ('120', '2003-08-20');

INSERT INTO pays_enum VALUES ('Autriche');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Baker', 'William', '1979-09-24', 'Autriche', 'M');
INSERT INTO joueur VALUES ('121', '1997-11-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Parker', 'Gregory', '1971-12-17', 'Autriche', 'M');
INSERT INTO joueur VALUES ('122', '1998-06-05');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Simpson', 'Joshua', '1973-07-04', 'Autriche', 'M');
INSERT INTO joueur VALUES ('123', '2001-08-05');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Owen', 'Jeffery', '1977-12-08', 'Autriche', 'M');
INSERT INTO joueur VALUES ('124', '2001-08-03');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Griffin', 'Thomas', '1984-12-24', 'Autriche', 'M');
INSERT INTO joueur VALUES ('125', '2000-12-15');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Amick', 'Thomas', '1972-11-27', 'Autriche', 'M');
INSERT INTO joueur VALUES ('126', '2000-12-09');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('White', 'Jonathan', '1978-04-11', 'Autriche', 'M');
INSERT INTO entraineur VALUES ('127', '2000-06-07');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Hatfield', 'Calvin', '1979-05-23', 'Autriche', 'M');
INSERT INTO collaborateur VALUES ('128', 'Psychologue sportif', '1997-04-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Gonsales', 'Kelly', '1971-09-26', 'Autriche', 'M');
INSERT INTO collaborateur VALUES ('129', 'Medecin', '1998-08-23');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Pacheco', 'Charles', '1975-03-20', 'Autriche', 'M');
INSERT INTO arbitre VALUES ('130', '1997-04-27');

INSERT INTO pays_enum VALUES ('Yougoslavie');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Sessoms', 'Peter', '1984-12-25', 'Yougoslavie', 'M');
INSERT INTO joueur VALUES ('131', '2002-07-12');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Jackson', 'Matthew', '1974-06-24', 'Yougoslavie', 'M');
INSERT INTO joueur VALUES ('132', '2003-10-13');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Bivens', 'Terry', '1970-04-07', 'Yougoslavie', 'M');
INSERT INTO joueur VALUES ('133', '1998-09-05');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Kelly', 'Jordan', '1983-06-08', 'Yougoslavie', 'M');
INSERT INTO joueur VALUES ('134', '1999-09-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Burton', 'Troy', '1973-08-14', 'Yougoslavie', 'M');
INSERT INTO joueur VALUES ('135', '2001-09-08');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Konrad', 'Devin', '1981-10-03', 'Yougoslavie', 'M');
INSERT INTO joueur VALUES ('136', '1998-09-07');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Heath', 'Garry', '1983-10-09', 'Yougoslavie', 'M');
INSERT INTO entraineur VALUES ('137', '1998-11-18');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Fleming', 'Fred', '1971-03-05', 'Yougoslavie', 'M');
INSERT INTO collaborateur VALUES ('138', 'Medecin', '1997-12-19');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Rentfro', 'Travis', '1971-11-12', 'Yougoslavie', 'M');
INSERT INTO collaborateur VALUES ('139', 'Physiotherapeute', '2001-07-26');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Chouteau', 'Ned', '1974-08-13', 'Yougoslavie', 'M');
INSERT INTO arbitre VALUES ('140', '2002-05-26');

INSERT INTO pays_enum VALUES ('Union sovietique');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Somerville', 'Daniel', '1971-09-28', 'Union sovietique', 'M');
INSERT INTO joueur VALUES ('141', '2003-12-17');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Uitz', 'Eli', '1983-03-13', 'Union sovietique', 'M');
INSERT INTO joueur VALUES ('142', '1997-03-07');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Robins', 'Shelby', '1981-04-22', 'Union sovietique', 'M');
INSERT INTO joueur VALUES ('143', '2003-12-21');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Giuliano', 'Elbert', '1973-11-23', 'Union sovietique', 'M');
INSERT INTO joueur VALUES ('144', '1997-03-19');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Sunday', 'Steven', '1972-05-12', 'Union sovietique', 'M');
INSERT INTO joueur VALUES ('145', '2001-09-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Hutton', 'William', '1981-05-04', 'Union sovietique', 'M');
INSERT INTO joueur VALUES ('146', '2001-06-17');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Lozoya', 'Craig', '1978-10-16', 'Union sovietique', 'M');
INSERT INTO entraineur VALUES ('147', '2002-03-14');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Lange', 'Richard', '1975-04-25', 'Union sovietique', 'M');
INSERT INTO collaborateur VALUES ('148', 'Physiotherapeute', '2001-08-15');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Aumick', 'Ronald', '1977-07-03', 'Union sovietique', 'M');
INSERT INTO collaborateur VALUES ('149', 'Psychologue sportif', '2001-04-14');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Valenzuela', 'Isaiah', '1979-05-19', 'Union sovietique', 'M');
INSERT INTO arbitre VALUES ('150', '2001-03-04');

INSERT INTO pays_enum VALUES ('Tchecoslovaquie');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Gaddy', 'Ricky', '1975-07-14', 'Tchecoslovaquie', 'M');
INSERT INTO joueur VALUES ('151', '2002-11-15');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Brown', 'Danny', '1979-04-22', 'Tchecoslovaquie', 'M');
INSERT INTO joueur VALUES ('152', '1999-09-26');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Harris', 'Howard', '1975-12-22', 'Tchecoslovaquie', 'M');
INSERT INTO joueur VALUES ('153', '1998-05-14');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Washington', 'Neil', '1972-07-08', 'Tchecoslovaquie', 'M');
INSERT INTO joueur VALUES ('154', '1999-11-06');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Serrato', 'Bryce', '1977-04-06', 'Tchecoslovaquie', 'M');
INSERT INTO joueur VALUES ('155', '2000-11-03');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Lynch', 'William', '1977-04-11', 'Tchecoslovaquie', 'M');
INSERT INTO joueur VALUES ('156', '2002-06-09');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Huang', 'Marvin', '1971-06-16', 'Tchecoslovaquie', 'M');
INSERT INTO entraineur VALUES ('157', '1997-10-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Feliz', 'Kirby', '1983-06-28', 'Tchecoslovaquie', 'M');
INSERT INTO collaborateur VALUES ('158', 'Psychologue sportif', '1997-03-23');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Young', 'Lester', '1981-04-21', 'Tchecoslovaquie', 'M');
INSERT INTO collaborateur VALUES ('159', 'Medecin', '1999-07-24');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Jeanes', 'Ryan', '1974-07-23', 'Tchecoslovaquie', 'M');
INSERT INTO arbitre VALUES ('160', '2002-09-19');

INSERT INTO pays_enum VALUES ('Pologne');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Davies', 'Philip', '1981-03-09', 'Pologne', 'M');
INSERT INTO joueur VALUES ('161', '2000-05-19');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Brandon', 'Anthony', '1984-05-18', 'Pologne', 'M');
INSERT INTO joueur VALUES ('162', '1997-03-11');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Antonio', 'Jason', '1972-04-20', 'Pologne', 'M');
INSERT INTO joueur VALUES ('163', '1998-04-27');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Mayne', 'James', '1983-07-07', 'Pologne', 'M');
INSERT INTO joueur VALUES ('164', '2000-08-19');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Wilkins', 'James', '1981-05-27', 'Pologne', 'M');
INSERT INTO joueur VALUES ('165', '2002-05-09');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Cashion', 'Sean', '1981-08-08', 'Pologne', 'M');
INSERT INTO joueur VALUES ('166', '2000-07-15');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Reyes', 'David', '1983-04-10', 'Pologne', 'M');
INSERT INTO entraineur VALUES ('167', '1999-10-20');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Carr', 'Lewis', '1974-11-06', 'Pologne', 'M');
INSERT INTO collaborateur VALUES ('168', 'Medecin', '1999-05-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Dennis', 'Bill', '1973-04-06', 'Pologne', 'M');
INSERT INTO collaborateur VALUES ('169', 'Physiotherapeute', '2002-08-26');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Day', 'Dallas', '1970-08-10', 'Pologne', 'M');
INSERT INTO arbitre VALUES ('170', '2003-05-04');

INSERT INTO pays_enum VALUES ('Argentine');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Marin', 'Floyd', '1983-07-14', 'Argentine', 'M');
INSERT INTO joueur VALUES ('171', '1999-06-16');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Davis', 'Eric', '1975-09-21', 'Argentine', 'M');
INSERT INTO joueur VALUES ('172', '2003-12-24');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Mortensen', 'Thomas', '1982-06-20', 'Argentine', 'M');
INSERT INTO joueur VALUES ('173', '2003-09-27');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Lacaze', 'Brian', '1972-07-13', 'Argentine', 'M');
INSERT INTO joueur VALUES ('174', '2001-08-27');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Silver', 'Wade', '1970-06-27', 'Argentine', 'M');
INSERT INTO joueur VALUES ('175', '2003-10-15');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Omalley', 'Andrew', '1984-11-03', 'Argentine', 'M');
INSERT INTO joueur VALUES ('176', '1997-10-21');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Gibbons', 'Henry', '1984-04-19', 'Argentine', 'M');
INSERT INTO entraineur VALUES ('177', '2002-03-07');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Holt', 'Eduardo', '1978-10-13', 'Argentine', 'M');
INSERT INTO collaborateur VALUES ('178', 'Physiotherapeute', '1997-10-16');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Segarra', 'Jeffrey', '1972-03-26', 'Argentine', 'M');
INSERT INTO collaborateur VALUES ('179', 'Psychologue sportif', '1999-09-27');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Gutierrez', 'Charles', '1977-03-21', 'Argentine', 'M');
INSERT INTO arbitre VALUES ('180', '2000-07-23');

INSERT INTO pays_enum VALUES ('Belgique');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Wilson', 'Thomas', '1970-09-28', 'Belgique', 'M');
INSERT INTO joueur VALUES ('181', '2001-04-23');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Brown', 'Norman', '1973-11-07', 'Belgique', 'M');
INSERT INTO joueur VALUES ('182', '1999-07-15');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Martinez', 'Christopher', '1982-03-08', 'Belgique', 'M');
INSERT INTO joueur VALUES ('183', '2001-10-17');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Greaves', 'Herbert', '1983-06-05', 'Belgique', 'M');
INSERT INTO joueur VALUES ('184', '1997-12-09');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Ries', 'Curtis', '1970-08-21', 'Belgique', 'M');
INSERT INTO joueur VALUES ('185', '1999-09-06');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Khan', 'Carlos', '1970-04-15', 'Belgique', 'M');
INSERT INTO joueur VALUES ('186', '1997-05-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Midgett', 'Bo', '1978-12-23', 'Belgique', 'M');
INSERT INTO entraineur VALUES ('187', '1999-12-18');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Marion', 'Warren', '1981-11-20', 'Belgique', 'M');
INSERT INTO collaborateur VALUES ('188', 'Psychologue sportif', '2001-10-17');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Hickey', 'Michael', '1982-06-23', 'Belgique', 'M');
INSERT INTO collaborateur VALUES ('189', 'Medecin', '2000-07-16');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Montgomery', 'Enrique', '1981-10-05', 'Belgique', 'M');
INSERT INTO arbitre VALUES ('190', '2003-11-12');

INSERT INTO pays_enum VALUES ('Croatie');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Jordan', 'Terry', '1973-10-22', 'Croatie', 'M');
INSERT INTO joueur VALUES ('191', '2001-09-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Piner', 'Bryce', '1979-08-23', 'Croatie', 'M');
INSERT INTO joueur VALUES ('192', '1998-03-09');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Kilcoyne', 'Leroy', '1970-03-07', 'Croatie', 'M');
INSERT INTO joueur VALUES ('193', '2000-07-03');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Lowe', 'William', '1983-09-08', 'Croatie', 'M');
INSERT INTO joueur VALUES ('194', '1998-12-25');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Adelson', 'Philip', '1984-07-03', 'Croatie', 'M');
INSERT INTO joueur VALUES ('195', '2001-12-11');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Armijo', 'Robert', '1972-08-22', 'Croatie', 'M');
INSERT INTO joueur VALUES ('196', '1998-09-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Goff', 'Brandon', '1976-04-23', 'Croatie', 'M');
INSERT INTO entraineur VALUES ('197', '2000-05-23');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Proudfoot', 'Wesley', '1975-10-27', 'Croatie', 'M');
INSERT INTO collaborateur VALUES ('198', 'Medecin', '1998-08-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Boucher', 'Kyle', '1974-11-06', 'Croatie', 'M');
INSERT INTO collaborateur VALUES ('199', 'Physiotherapeute', '2003-04-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Murray', 'John', '1980-07-15', 'Croatie', 'M');
INSERT INTO arbitre VALUES ('200', '2001-04-05');

INSERT INTO pays_enum VALUES ('Pays-Bas');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Brackman', 'Harold', '1971-04-22', 'Pays-Bas', 'M');
INSERT INTO joueur VALUES ('201', '2001-12-06');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Dawson', 'Charles', '1982-05-25', 'Pays-Bas', 'M');
INSERT INTO joueur VALUES ('202', '1997-03-07');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Obermiller', 'Stephen', '1979-06-10', 'Pays-Bas', 'M');
INSERT INTO joueur VALUES ('203', '1997-04-23');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Curi', 'Leo', '1977-06-10', 'Pays-Bas', 'M');
INSERT INTO joueur VALUES ('204', '2000-12-26');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Clay', 'Bryan', '1982-11-19', 'Pays-Bas', 'M');
INSERT INTO joueur VALUES ('205', '2000-04-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Cavazos', 'Scottie', '1978-07-13', 'Pays-Bas', 'M');
INSERT INTO joueur VALUES ('206', '2000-08-05');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Dominguez', 'Grady', '1976-12-13', 'Pays-Bas', 'M');
INSERT INTO entraineur VALUES ('207', '2002-10-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Kirkpatrick', 'Ronald', '1983-09-07', 'Pays-Bas', 'M');
INSERT INTO collaborateur VALUES ('208', 'Physiotherapeute', '2003-04-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Rodgers', 'Leslie', '1983-07-25', 'Pays-Bas', 'M');
INSERT INTO collaborateur VALUES ('209', 'Psychologue sportif', '1997-12-07');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Pruett', 'Marc', '1975-09-16', 'Pays-Bas', 'M');
INSERT INTO arbitre VALUES ('210', '2003-05-17');

INSERT INTO pays_enum VALUES ('Coree du Sud');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Dickison', 'Curt', '1978-09-20', 'Coree du Sud', 'M');
INSERT INTO joueur VALUES ('211', '2002-09-03');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Bello', 'Garrett', '1975-06-03', 'Coree du Sud', 'M');
INSERT INTO joueur VALUES ('212', '2001-05-26');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Havard', 'James', '1970-05-14', 'Coree du Sud', 'M');
INSERT INTO joueur VALUES ('213', '1997-05-06');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Tirado', 'Samuel', '1975-09-17', 'Coree du Sud', 'M');
INSERT INTO joueur VALUES ('214', '2003-10-23');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Hanley', 'Randall', '1971-11-26', 'Coree du Sud', 'M');
INSERT INTO joueur VALUES ('215', '2000-05-17');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Hammett', 'Robert', '1976-08-08', 'Coree du Sud', 'M');
INSERT INTO joueur VALUES ('216', '1998-08-24');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Stigall', 'Donald', '1977-11-27', 'Coree du Sud', 'M');
INSERT INTO entraineur VALUES ('217', '1997-11-11');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Pollock', 'Philip', '1971-05-27', 'Coree du Sud', 'M');
INSERT INTO collaborateur VALUES ('218', 'Psychologue sportif', '1999-05-03');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Drum', 'Lee', '1977-11-14', 'Coree du Sud', 'M');
INSERT INTO collaborateur VALUES ('219', 'Medecin', '1999-08-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Jones', 'Cameron', '1981-12-04', 'Coree du Sud', 'M');
INSERT INTO arbitre VALUES ('220', '2002-09-19');

INSERT INTO pays_enum VALUES ('Japon');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Kave', 'Kyle', '1974-03-23', 'Japon', 'M');
INSERT INTO joueur VALUES ('221', '2003-07-11');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Davis', 'Robert', '1979-06-04', 'Japon', 'M');
INSERT INTO joueur VALUES ('222', '2003-05-23');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Farnell', 'Richard', '1975-11-03', 'Japon', 'M');
INSERT INTO joueur VALUES ('223', '2000-05-15');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Deel', 'Joseph', '1981-11-07', 'Japon', 'M');
INSERT INTO joueur VALUES ('224', '2001-09-11');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Joesph', 'John', '1984-03-17', 'Japon', 'M');
INSERT INTO joueur VALUES ('225', '2001-07-25');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Anderson', 'Alan', '1973-09-24', 'Japon', 'M');
INSERT INTO joueur VALUES ('226', '1999-04-27');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Watts', 'Randy', '1970-07-19', 'Japon', 'M');
INSERT INTO entraineur VALUES ('227', '1999-12-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Ho', 'Mark', '1979-09-13', 'Japon', 'M');
INSERT INTO collaborateur VALUES ('228', 'Medecin', '2003-03-20');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Bonanno', 'Johnny', '1971-09-26', 'Japon', 'M');
INSERT INTO collaborateur VALUES ('229', 'Physiotherapeute', '2002-10-06');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Riner', 'Cleveland', '1972-04-25', 'Japon', 'M');
INSERT INTO arbitre VALUES ('230', '2003-07-04');

INSERT INTO pays_enum VALUES ('Russie');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Bradshaw', 'Graham', '1976-08-22', 'Russie', 'M');
INSERT INTO joueur VALUES ('231', '2003-12-24');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Castro', 'Fred', '1971-04-04', 'Russie', 'M');
INSERT INTO joueur VALUES ('232', '1998-09-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Lacasse', 'Long', '1977-08-21', 'Russie', 'M');
INSERT INTO joueur VALUES ('233', '2002-03-20');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Roe', 'Patrick', '1973-09-15', 'Russie', 'M');
INSERT INTO joueur VALUES ('234', '2003-12-18');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Carter', 'Freddy', '1970-09-19', 'Russie', 'M');
INSERT INTO joueur VALUES ('235', '1998-12-03');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Dilley', 'Ernest', '1973-10-03', 'Russie', 'M');
INSERT INTO joueur VALUES ('236', '1998-10-23');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Churchwell', 'Chris', '1978-09-22', 'Russie', 'M');
INSERT INTO entraineur VALUES ('237', '2001-09-24');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Turberville', 'Daniel', '1977-11-11', 'Russie', 'M');
INSERT INTO collaborateur VALUES ('238', 'Physiotherapeute', '2002-07-18');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Edwards', 'Earl', '1979-06-17', 'Russie', 'M');
INSERT INTO collaborateur VALUES ('239', 'Psychologue sportif', '2000-07-13');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Simpson', 'Claude', '1973-08-15', 'Russie', 'M');
INSERT INTO arbitre VALUES ('240', '2003-11-18');

INSERT INTO pays_enum VALUES ('Maroque');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Mendoza', 'William', '1983-11-07', 'Maroque', 'M');
INSERT INTO joueur VALUES ('241', '1997-05-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Gross', 'Steven', '1974-08-08', 'Maroque', 'M');
INSERT INTO joueur VALUES ('242', '1998-09-19');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Green', 'Martin', '1977-11-03', 'Maroque', 'M');
INSERT INTO joueur VALUES ('243', '1997-08-19');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Simmons', 'Zachary', '1981-08-22', 'Maroque', 'M');
INSERT INTO joueur VALUES ('244', '2001-12-18');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Harper', 'Joe', '1973-09-09', 'Maroque', 'M');
INSERT INTO joueur VALUES ('245', '2000-06-05');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Johnson', 'Daniel', '1975-11-12', 'Maroque', 'M');
INSERT INTO joueur VALUES ('246', '2002-10-14');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Cox', 'Charles', '1983-03-04', 'Maroque', 'M');
INSERT INTO entraineur VALUES ('247', '1998-11-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Obleton', 'Joseph', '1978-12-04', 'Maroque', 'M');
INSERT INTO collaborateur VALUES ('248', 'Psychologue sportif', '2000-09-11');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Russell', 'Hector', '1970-08-15', 'Maroque', 'M');
INSERT INTO collaborateur VALUES ('249', 'Medecin', '1998-04-16');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Eusebio', 'James', '1984-12-13', 'Maroque', 'M');
INSERT INTO arbitre VALUES ('250', '2001-05-17');

INSERT INTO pays_enum VALUES ('Egypt');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Bailey', 'Pete', '1970-09-11', 'Egypt', 'M');
INSERT INTO joueur VALUES ('251', '1998-06-11');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Mierzejewski', 'Christopher', '1976-06-26', 'Egypt', 'M');
INSERT INTO joueur VALUES ('252', '2002-04-24');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Young', 'Louis', '1979-06-10', 'Egypt', 'M');
INSERT INTO joueur VALUES ('253', '2003-06-08');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Mccullar', 'Gordon', '1978-05-16', 'Egypt', 'M');
INSERT INTO joueur VALUES ('254', '2001-12-06');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Douglas', 'Jonathan', '1973-06-09', 'Egypt', 'M');
INSERT INTO joueur VALUES ('255', '1997-05-25');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Penley', 'Robert', '1974-05-23', 'Egypt', 'M');
INSERT INTO joueur VALUES ('256', '2001-10-25');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Morgan', 'Saul', '1981-05-28', 'Egypt', 'M');
INSERT INTO entraineur VALUES ('257', '1998-04-15');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Berganza', 'Ralph', '1970-08-20', 'Egypt', 'M');
INSERT INTO collaborateur VALUES ('258', 'Medecin', '2000-06-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Stidham', 'Kevin', '1981-10-18', 'Egypt', 'M');
INSERT INTO collaborateur VALUES ('259', 'Physiotherapeute', '2002-06-12');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Hay', 'Eric', '1975-05-10', 'Egypt', 'M');
INSERT INTO arbitre VALUES ('260', '1999-04-08');

INSERT INTO pays_enum VALUES ('Grece');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Dunlap', 'Aaron', '1979-11-23', 'Grece', 'M');
INSERT INTO joueur VALUES ('261', '2000-09-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Mason', 'Robert', '1973-08-25', 'Grece', 'M');
INSERT INTO joueur VALUES ('262', '1999-11-27');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Patel', 'Richard', '1976-11-09', 'Grece', 'M');
INSERT INTO joueur VALUES ('263', '2000-08-06');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Owens', 'Darrin', '1973-12-19', 'Grece', 'M');
INSERT INTO joueur VALUES ('264', '2003-12-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Sparks', 'Clifford', '1976-09-21', 'Grece', 'M');
INSERT INTO joueur VALUES ('265', '1998-07-08');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Biasi', 'Stanley', '1980-07-23', 'Grece', 'M');
INSERT INTO joueur VALUES ('266', '2001-07-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Winnie', 'Donald', '1984-10-16', 'Grece', 'M');
INSERT INTO entraineur VALUES ('267', '2002-04-27');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Berglund', 'Oliver', '1979-07-13', 'Grece', 'M');
INSERT INTO collaborateur VALUES ('268', 'Physiotherapeute', '2000-12-24');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Steinke', 'Kyle', '1984-11-25', 'Grece', 'M');
INSERT INTO collaborateur VALUES ('269', 'Psychologue sportif', '2001-12-26');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Coughlin', 'Howard', '1978-03-19', 'Grece', 'M');
INSERT INTO arbitre VALUES ('270', '1997-11-12');

INSERT INTO pays_enum VALUES ('Qatar');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Hiser', 'David', '1980-08-14', 'Qatar', 'M');
INSERT INTO joueur VALUES ('271', '2001-11-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Decastro', 'Robert', '1979-03-26', 'Qatar', 'M');
INSERT INTO joueur VALUES ('272', '1998-07-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('West', 'Aaron', '1984-03-21', 'Qatar', 'M');
INSERT INTO joueur VALUES ('273', '1999-08-19');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Pitcherello', 'Martin', '1971-07-09', 'Qatar', 'M');
INSERT INTO joueur VALUES ('274', '1999-11-28');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Smith', 'John', '1977-05-28', 'Qatar', 'M');
INSERT INTO joueur VALUES ('275', '1998-07-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Vanderhorst', 'Richard', '1984-08-26', 'Qatar', 'M');
INSERT INTO joueur VALUES ('276', '1997-03-09');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Taylor', 'Michael', '1978-10-14', 'Qatar', 'M');
INSERT INTO entraineur VALUES ('277', '2002-12-06');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Bullard', 'Joe', '1975-06-06', 'Qatar', 'M');
INSERT INTO collaborateur VALUES ('278', 'Psychologue sportif', '2002-10-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Morales', 'Richard', '1977-05-08', 'Qatar', 'M');
INSERT INTO collaborateur VALUES ('279', 'Medecin', '1998-11-22');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Cendejas', 'Mark', '1972-07-18', 'Qatar', 'M');
INSERT INTO arbitre VALUES ('280', '2001-07-12');

INSERT INTO pays_enum VALUES ('Etats-Unis');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Nelson', 'Caleb', '1972-03-16', 'Etats-Unis', 'M');
INSERT INTO joueur VALUES ('281', '2000-08-19');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Buchanan', 'Leo', '1984-11-05', 'Etats-Unis', 'M');
INSERT INTO joueur VALUES ('282', '1999-09-03');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Lee', 'Robert', '1971-03-25', 'Etats-Unis', 'M');
INSERT INTO joueur VALUES ('283', '2000-07-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Teasley', 'Steven', '1972-11-21', 'Etats-Unis', 'M');
INSERT INTO joueur VALUES ('284', '1999-12-20');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Hernandez', 'Patrick', '1970-06-16', 'Etats-Unis', 'M');
INSERT INTO joueur VALUES ('285', '2002-03-20');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Hoskins', 'David', '1976-09-04', 'Etats-Unis', 'M');
INSERT INTO joueur VALUES ('286', '2003-05-11');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Purifoy', 'Rodney', '1983-08-06', 'Etats-Unis', 'M');
INSERT INTO entraineur VALUES ('287', '1997-04-07');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Shaw', 'William', '1979-07-28', 'Etats-Unis', 'M');
INSERT INTO collaborateur VALUES ('288', 'Medecin', '2003-08-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Stallard', 'Neville', '1971-11-12', 'Etats-Unis', 'M');
INSERT INTO collaborateur VALUES ('289', 'Physiotherapeute', '2003-09-10');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Ayers', 'Victor', '1980-06-11', 'Etats-Unis', 'M');
INSERT INTO arbitre VALUES ('290', '2000-10-20');

INSERT INTO pays_enum VALUES ('Turquie');
INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Schumacher', 'Paul', '1974-10-09', 'Turquie', 'M');
INSERT INTO joueur VALUES ('291', '2001-05-25');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Privett', 'Marc', '1975-07-23', 'Turquie', 'M');
INSERT INTO joueur VALUES ('292', '2001-04-25');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Sisk', 'David', '1981-11-21', 'Turquie', 'M');
INSERT INTO joueur VALUES ('293', '2001-12-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Church', 'Frank', '1974-10-03', 'Turquie', 'M');
INSERT INTO joueur VALUES ('294', '1998-04-04');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Owens', 'Asa', '1983-08-24', 'Turquie', 'M');
INSERT INTO joueur VALUES ('295', '2002-11-21');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Cox', 'Ronald', '1980-11-09', 'Turquie', 'M');
INSERT INTO joueur VALUES ('296', '2002-06-11');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Jones', 'David', '1977-04-12', 'Turquie', 'M');
INSERT INTO entraineur VALUES ('297', '2003-11-08');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Bouldin', 'Raymond', '1971-04-19', 'Turquie', 'M');
INSERT INTO collaborateur VALUES ('298', 'Physiotherapeute', '1997-03-16');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Macias', 'David', '1982-04-27', 'Turquie', 'M');
INSERT INTO collaborateur VALUES ('299', 'Psychologue sportif', '1997-10-07');

INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('Kaylor', 'Tom', '1972-12-20', 'Turquie', 'M');
INSERT INTO arbitre VALUES ('300', '1999-04-13');

commit;

begin; 

  -- Coupe Du Monde  --- 
INSERT INTO coupe_du_monde VALUES ('1', '1998-06-10', '1998-07-12');
INSERT INTO pays_coupe VALUES ('Uruguay', '1');


 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Uruguay', '1', '7', '12');
INSERT INTO collaborateur_equipe VALUES ('8', 'Uruguay', '1');
INSERT INTO collaborateur_equipe VALUES ('9', 'Uruguay', '1');
INSERT INTO joueur_equipe VALUES ('1', 'Uruguay', '1', 'Avant-centre', '0', 'France National');
INSERT INTO joueur_equipe VALUES ('2', 'Uruguay', '1', 'Arriere latéral', '9', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('3', 'Uruguay', '1', 'Millieu defensif', '21', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('4', 'Uruguay', '1', 'Millieu offensif', '27', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('5', 'Uruguay', '1', 'Gardien de but', '28', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('6', 'Uruguay', '1', 'Attaquant de pointe', '38', 'Real Madrid');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Italie', '1', '17', '26');
INSERT INTO collaborateur_equipe VALUES ('18', 'Italie', '1');
INSERT INTO collaborateur_equipe VALUES ('19', 'Italie', '1');
INSERT INTO joueur_equipe VALUES ('11', 'Italie', '1', 'Avant-centre', '0', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('12', 'Italie', '1', 'Arriere latéral', '8', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('13', 'Italie', '1', 'Millieu defensif', '21', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('14', 'Italie', '1', 'Millieu offensif', '27', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('15', 'Italie', '1', 'Gardien de but', '25', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('16', 'Italie', '1', 'Attaquant de pointe', '38', 'Real Madrid');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('France', '1', '27', '10');
INSERT INTO collaborateur_equipe VALUES ('28', 'France', '1');
INSERT INTO collaborateur_equipe VALUES ('29', 'France', '1');
INSERT INTO joueur_equipe VALUES ('21', 'France', '1', 'Avant-centre', '0', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('22', 'France', '1', 'Arriere latéral', '7', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('23', 'France', '1', 'Millieu defensif', '15', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('24', 'France', '1', 'Millieu offensif', '25', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('25', 'France', '1', 'Gardien de but', '34', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('26', 'France', '1', 'Attaquant de pointe', '45', 'Spain N.F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Canada', '1', '37', '5');
INSERT INTO collaborateur_equipe VALUES ('38', 'Canada', '1');
INSERT INTO collaborateur_equipe VALUES ('39', 'Canada', '1');
INSERT INTO joueur_equipe VALUES ('31', 'Canada', '1', 'Avant-centre', '0', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('32', 'Canada', '1', 'Arriere latéral', '6', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('33', 'Canada', '1', 'Millieu defensif', '15', 'France National');
INSERT INTO joueur_equipe VALUES ('34', 'Canada', '1', 'Millieu offensif', '20', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('35', 'Canada', '1', 'Gardien de but', '32', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('36', 'Canada', '1', 'Attaquant de pointe', '36', 'AS Monaco');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Bresil', '1', '47', '21');
INSERT INTO collaborateur_equipe VALUES ('48', 'Bresil', '1');
INSERT INTO collaborateur_equipe VALUES ('49', 'Bresil', '1');
INSERT INTO joueur_equipe VALUES ('41', 'Bresil', '1', 'Avant-centre', '0', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('42', 'Bresil', '1', 'Arriere latéral', '10', 'France National');
INSERT INTO joueur_equipe VALUES ('43', 'Bresil', '1', 'Millieu defensif', '12', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('44', 'Bresil', '1', 'Millieu offensif', '23', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('45', 'Bresil', '1', 'Gardien de but', '25', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('46', 'Bresil', '1', 'Attaquant de pointe', '37', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Suisse', '1', '57', '30');
INSERT INTO collaborateur_equipe VALUES ('58', 'Suisse', '1');
INSERT INTO collaborateur_equipe VALUES ('59', 'Suisse', '1');
INSERT INTO joueur_equipe VALUES ('51', 'Suisse', '1', 'Avant-centre', '0', 'France National');
INSERT INTO joueur_equipe VALUES ('52', 'Suisse', '1', 'Arriere latéral', '11', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('53', 'Suisse', '1', 'Millieu defensif', '13', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('54', 'Suisse', '1', 'Millieu offensif', '27', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('55', 'Suisse', '1', 'Gardien de but', '32', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('56', 'Suisse', '1', 'Attaquant de pointe', '51', 'Liverpool F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Suede', '1', '67', '16');
INSERT INTO collaborateur_equipe VALUES ('68', 'Suede', '1');
INSERT INTO collaborateur_equipe VALUES ('69', 'Suede', '1');
INSERT INTO joueur_equipe VALUES ('61', 'Suede', '1', 'Avant-centre', '1', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('62', 'Suede', '1', 'Arriere latéral', '11', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('63', 'Suede', '1', 'Millieu defensif', '17', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('64', 'Suede', '1', 'Millieu offensif', '28', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('65', 'Suede', '1', 'Gardien de but', '39', 'France National');
INSERT INTO joueur_equipe VALUES ('66', 'Suede', '1', 'Attaquant de pointe', '40', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Chili', '1', '77', '14');
INSERT INTO collaborateur_equipe VALUES ('78', 'Chili', '1');
INSERT INTO collaborateur_equipe VALUES ('79', 'Chili', '1');
INSERT INTO joueur_equipe VALUES ('71', 'Chili', '1', 'Avant-centre', '1', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('72', 'Chili', '1', 'Arriere latéral', '7', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('73', 'Chili', '1', 'Millieu defensif', '13', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('74', 'Chili', '1', 'Millieu offensif', '24', 'France National');
INSERT INTO joueur_equipe VALUES ('75', 'Chili', '1', 'Gardien de but', '40', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('76', 'Chili', '1', 'Attaquant de pointe', '46', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Angleterre', '1', '87', '19');
INSERT INTO collaborateur_equipe VALUES ('88', 'Angleterre', '1');
INSERT INTO collaborateur_equipe VALUES ('89', 'Angleterre', '1');
INSERT INTO joueur_equipe VALUES ('81', 'Angleterre', '1', 'Avant-centre', '1', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('82', 'Angleterre', '1', 'Arriere latéral', '7', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('83', 'Angleterre', '1', 'Millieu defensif', '14', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('84', 'Angleterre', '1', 'Millieu offensif', '23', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('85', 'Angleterre', '1', 'Gardien de but', '29', 'France National');
INSERT INTO joueur_equipe VALUES ('86', 'Angleterre', '1', 'Attaquant de pointe', '39', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Mexique', '1', '97', '20');
INSERT INTO collaborateur_equipe VALUES ('98', 'Mexique', '1');
INSERT INTO collaborateur_equipe VALUES ('99', 'Mexique', '1');
INSERT INTO joueur_equipe VALUES ('91', 'Mexique', '1', 'Avant-centre', '1', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('92', 'Mexique', '1', 'Arriere latéral', '7', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('93', 'Mexique', '1', 'Millieu defensif', '20', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('94', 'Mexique', '1', 'Millieu offensif', '30', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('95', 'Mexique', '1', 'Gardien de but', '41', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('96', 'Mexique', '1', 'Attaquant de pointe', '31', 'Spain N.F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Allemagne', '1', '107', '18');
INSERT INTO collaborateur_equipe VALUES ('108', 'Allemagne', '1');
INSERT INTO collaborateur_equipe VALUES ('109', 'Allemagne', '1');
INSERT INTO joueur_equipe VALUES ('101', 'Allemagne', '1', 'Avant-centre', '0', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('102', 'Allemagne', '1', 'Arriere latéral', '10', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('103', 'Allemagne', '1', 'Millieu defensif', '15', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('104', 'Allemagne', '1', 'Millieu offensif', '25', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('105', 'Allemagne', '1', 'Gardien de but', '41', 'France National');
INSERT INTO joueur_equipe VALUES ('106', 'Allemagne', '1', 'Attaquant de pointe', '46', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Portugal', '1', '117', '11');
INSERT INTO collaborateur_equipe VALUES ('118', 'Portugal', '1');
INSERT INTO collaborateur_equipe VALUES ('119', 'Portugal', '1');
INSERT INTO joueur_equipe VALUES ('111', 'Portugal', '1', 'Avant-centre', '0', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('112', 'Portugal', '1', 'Arriere latéral', '8', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('113', 'Portugal', '1', 'Millieu defensif', '16', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('114', 'Portugal', '1', 'Millieu offensif', '24', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('115', 'Portugal', '1', 'Gardien de but', '25', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('116', 'Portugal', '1', 'Attaquant de pointe', '51', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Autriche', '1', '127', '25');
INSERT INTO collaborateur_equipe VALUES ('128', 'Autriche', '1');
INSERT INTO collaborateur_equipe VALUES ('129', 'Autriche', '1');
INSERT INTO joueur_equipe VALUES ('121', 'Autriche', '1', 'Avant-centre', '0', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('122', 'Autriche', '1', 'Arriere latéral', '8', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('123', 'Autriche', '1', 'Millieu defensif', '18', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('124', 'Autriche', '1', 'Millieu offensif', '21', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('125', 'Autriche', '1', 'Gardien de but', '25', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('126', 'Autriche', '1', 'Attaquant de pointe', '35', 'AS Monaco');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Yougoslavie', '1', '137', '27');
INSERT INTO collaborateur_equipe VALUES ('138', 'Yougoslavie', '1');
INSERT INTO collaborateur_equipe VALUES ('139', 'Yougoslavie', '1');
INSERT INTO joueur_equipe VALUES ('131', 'Yougoslavie', '1', 'Avant-centre', '1', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('132', 'Yougoslavie', '1', 'Arriere latéral', '8', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('133', 'Yougoslavie', '1', 'Millieu defensif', '20', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('134', 'Yougoslavie', '1', 'Millieu offensif', '18', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('135', 'Yougoslavie', '1', 'Gardien de but', '40', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('136', 'Yougoslavie', '1', 'Attaquant de pointe', '35', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Union sovietique', '1', '147', '17');
INSERT INTO collaborateur_equipe VALUES ('148', 'Union sovietique', '1');
INSERT INTO collaborateur_equipe VALUES ('149', 'Union sovietique', '1');
INSERT INTO joueur_equipe VALUES ('141', 'Union sovietique', '1', 'Avant-centre', '1', 'France National');
INSERT INTO joueur_equipe VALUES ('142', 'Union sovietique', '1', 'Arriere latéral', '9', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('143', 'Union sovietique', '1', 'Millieu defensif', '13', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('144', 'Union sovietique', '1', 'Millieu offensif', '29', 'France National');
INSERT INTO joueur_equipe VALUES ('145', 'Union sovietique', '1', 'Gardien de but', '37', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('146', 'Union sovietique', '1', 'Attaquant de pointe', '42', 'Brazil nationnal');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Tchecoslovaquie', '1', '157', '7');
INSERT INTO collaborateur_equipe VALUES ('158', 'Tchecoslovaquie', '1');
INSERT INTO collaborateur_equipe VALUES ('159', 'Tchecoslovaquie', '1');
INSERT INTO joueur_equipe VALUES ('151', 'Tchecoslovaquie', '1', 'Avant-centre', '1', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('152', 'Tchecoslovaquie', '1', 'Arriere latéral', '8', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('153', 'Tchecoslovaquie', '1', 'Millieu defensif', '14', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('154', 'Tchecoslovaquie', '1', 'Millieu offensif', '25', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('155', 'Tchecoslovaquie', '1', 'Gardien de but', '38', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('156', 'Tchecoslovaquie', '1', 'Attaquant de pointe', '42', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Pologne', '1', '167', '13');
INSERT INTO collaborateur_equipe VALUES ('168', 'Pologne', '1');
INSERT INTO collaborateur_equipe VALUES ('169', 'Pologne', '1');
INSERT INTO joueur_equipe VALUES ('161', 'Pologne', '1', 'Avant-centre', '1', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('162', 'Pologne', '1', 'Arriere latéral', '11', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('163', 'Pologne', '1', 'Millieu defensif', '21', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('164', 'Pologne', '1', 'Millieu offensif', '29', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('165', 'Pologne', '1', 'Gardien de but', '25', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('166', 'Pologne', '1', 'Attaquant de pointe', '36', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Argentine', '1', '177', '28');
INSERT INTO collaborateur_equipe VALUES ('178', 'Argentine', '1');
INSERT INTO collaborateur_equipe VALUES ('179', 'Argentine', '1');
INSERT INTO joueur_equipe VALUES ('171', 'Argentine', '1', 'Avant-centre', '0', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('172', 'Argentine', '1', 'Arriere latéral', '9', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('173', 'Argentine', '1', 'Millieu defensif', '21', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('174', 'Argentine', '1', 'Millieu offensif', '25', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('175', 'Argentine', '1', 'Gardien de but', '40', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('176', 'Argentine', '1', 'Attaquant de pointe', '37', 'AS Monaco');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Belgique', '1', '187', '23');
INSERT INTO collaborateur_equipe VALUES ('188', 'Belgique', '1');
INSERT INTO collaborateur_equipe VALUES ('189', 'Belgique', '1');
INSERT INTO joueur_equipe VALUES ('181', 'Belgique', '1', 'Avant-centre', '0', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('182', 'Belgique', '1', 'Arriere latéral', '10', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('183', 'Belgique', '1', 'Millieu defensif', '19', 'France National');
INSERT INTO joueur_equipe VALUES ('184', 'Belgique', '1', 'Millieu offensif', '26', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('185', 'Belgique', '1', 'Gardien de but', '34', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('186', 'Belgique', '1', 'Attaquant de pointe', '39', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Croatie', '1', '197', '3');
INSERT INTO collaborateur_equipe VALUES ('198', 'Croatie', '1');
INSERT INTO collaborateur_equipe VALUES ('199', 'Croatie', '1');
INSERT INTO joueur_equipe VALUES ('191', 'Croatie', '1', 'Avant-centre', '1', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('192', 'Croatie', '1', 'Arriere latéral', '8', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('193', 'Croatie', '1', 'Millieu defensif', '16', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('194', 'Croatie', '1', 'Millieu offensif', '18', 'France National');
INSERT INTO joueur_equipe VALUES ('195', 'Croatie', '1', 'Gardien de but', '34', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('196', 'Croatie', '1', 'Attaquant de pointe', '34', 'AS Monaco');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Pays-Bas', '1', '207', '2');
INSERT INTO collaborateur_equipe VALUES ('208', 'Pays-Bas', '1');
INSERT INTO collaborateur_equipe VALUES ('209', 'Pays-Bas', '1');
INSERT INTO joueur_equipe VALUES ('201', 'Pays-Bas', '1', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('202', 'Pays-Bas', '1', 'Arriere latéral', '11', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('203', 'Pays-Bas', '1', 'Millieu defensif', '15', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('204', 'Pays-Bas', '1', 'Millieu offensif', '30', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('205', 'Pays-Bas', '1', 'Gardien de but', '26', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('206', 'Pays-Bas', '1', 'Attaquant de pointe', '31', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Coree du Sud', '1', '217', '29');
INSERT INTO collaborateur_equipe VALUES ('218', 'Coree du Sud', '1');
INSERT INTO collaborateur_equipe VALUES ('219', 'Coree du Sud', '1');
INSERT INTO joueur_equipe VALUES ('211', 'Coree du Sud', '1', 'Avant-centre', '0', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('212', 'Coree du Sud', '1', 'Arriere latéral', '10', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('213', 'Coree du Sud', '1', 'Millieu defensif', '16', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('214', 'Coree du Sud', '1', 'Millieu offensif', '21', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('215', 'Coree du Sud', '1', 'Gardien de but', '36', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('216', 'Coree du Sud', '1', 'Attaquant de pointe', '32', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Japon', '1', '227', '8');
INSERT INTO collaborateur_equipe VALUES ('228', 'Japon', '1');
INSERT INTO collaborateur_equipe VALUES ('229', 'Japon', '1');
INSERT INTO joueur_equipe VALUES ('221', 'Japon', '1', 'Avant-centre', '0', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('222', 'Japon', '1', 'Arriere latéral', '7', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('223', 'Japon', '1', 'Millieu defensif', '16', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('224', 'Japon', '1', 'Millieu offensif', '23', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('225', 'Japon', '1', 'Gardien de but', '28', 'France National');
INSERT INTO joueur_equipe VALUES ('226', 'Japon', '1', 'Attaquant de pointe', '39', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Russie', '1', '237', '24');
INSERT INTO collaborateur_equipe VALUES ('238', 'Russie', '1');
INSERT INTO collaborateur_equipe VALUES ('239', 'Russie', '1');
INSERT INTO joueur_equipe VALUES ('231', 'Russie', '1', 'Avant-centre', '1', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('232', 'Russie', '1', 'Arriere latéral', '8', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('233', 'Russie', '1', 'Millieu defensif', '17', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('234', 'Russie', '1', 'Millieu offensif', '31', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('235', 'Russie', '1', 'Gardien de but', '31', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('236', 'Russie', '1', 'Attaquant de pointe', '42', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Maroque', '1', '247', '15');
INSERT INTO collaborateur_equipe VALUES ('248', 'Maroque', '1');
INSERT INTO collaborateur_equipe VALUES ('249', 'Maroque', '1');
INSERT INTO joueur_equipe VALUES ('241', 'Maroque', '1', 'Avant-centre', '0', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('242', 'Maroque', '1', 'Arriere latéral', '6', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('243', 'Maroque', '1', 'Millieu defensif', '19', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('244', 'Maroque', '1', 'Millieu offensif', '29', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('245', 'Maroque', '1', 'Gardien de but', '24', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('246', 'Maroque', '1', 'Attaquant de pointe', '34', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Egypt', '1', '257', '4');
INSERT INTO collaborateur_equipe VALUES ('258', 'Egypt', '1');
INSERT INTO collaborateur_equipe VALUES ('259', 'Egypt', '1');
INSERT INTO joueur_equipe VALUES ('251', 'Egypt', '1', 'Avant-centre', '1', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('252', 'Egypt', '1', 'Arriere latéral', '8', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('253', 'Egypt', '1', 'Millieu defensif', '21', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('254', 'Egypt', '1', 'Millieu offensif', '27', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('255', 'Egypt', '1', 'Gardien de but', '30', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('256', 'Egypt', '1', 'Attaquant de pointe', '38', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Grece', '1', '267', '1');
INSERT INTO collaborateur_equipe VALUES ('268', 'Grece', '1');
INSERT INTO collaborateur_equipe VALUES ('269', 'Grece', '1');
INSERT INTO joueur_equipe VALUES ('261', 'Grece', '1', 'Avant-centre', '0', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('262', 'Grece', '1', 'Arriere latéral', '9', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('263', 'Grece', '1', 'Millieu defensif', '15', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('264', 'Grece', '1', 'Millieu offensif', '19', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('265', 'Grece', '1', 'Gardien de but', '27', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('266', 'Grece', '1', 'Attaquant de pointe', '34', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Qatar', '1', '277', '9');
INSERT INTO collaborateur_equipe VALUES ('278', 'Qatar', '1');
INSERT INTO collaborateur_equipe VALUES ('279', 'Qatar', '1');
INSERT INTO joueur_equipe VALUES ('271', 'Qatar', '1', 'Avant-centre', '1', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('272', 'Qatar', '1', 'Arriere latéral', '8', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('273', 'Qatar', '1', 'Millieu defensif', '20', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('274', 'Qatar', '1', 'Millieu offensif', '26', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('275', 'Qatar', '1', 'Gardien de but', '26', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('276', 'Qatar', '1', 'Attaquant de pointe', '48', 'Manchester United F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Etats-Unis', '1', '287', '22');
INSERT INTO collaborateur_equipe VALUES ('288', 'Etats-Unis', '1');
INSERT INTO collaborateur_equipe VALUES ('289', 'Etats-Unis', '1');
INSERT INTO joueur_equipe VALUES ('281', 'Etats-Unis', '1', 'Avant-centre', '0', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('282', 'Etats-Unis', '1', 'Arriere latéral', '10', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('283', 'Etats-Unis', '1', 'Millieu defensif', '15', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('284', 'Etats-Unis', '1', 'Millieu offensif', '23', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('285', 'Etats-Unis', '1', 'Gardien de but', '27', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('286', 'Etats-Unis', '1', 'Attaquant de pointe', '37', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Turquie', '1', '297', '6');
INSERT INTO collaborateur_equipe VALUES ('298', 'Turquie', '1');
INSERT INTO collaborateur_equipe VALUES ('299', 'Turquie', '1');
INSERT INTO joueur_equipe VALUES ('291', 'Turquie', '1', 'Avant-centre', '0', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('292', 'Turquie', '1', 'Arriere latéral', '11', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('293', 'Turquie', '1', 'Millieu defensif', '20', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('294', 'Turquie', '1', 'Millieu offensif', '28', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('295', 'Turquie', '1', 'Gardien de but', '41', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('296', 'Turquie', '1', 'Attaquant de pointe', '46', 'Arsenal F.C.');

 -- Stade -- 
INSERT INTO stade VALUES ('Rocket Center', 'Hillford', '38000', 'Uruguay', '1709');

 -- Match -- 

INSERT INTO match_foot VALUES ('1998-06-10', 'Uruguay', 'Allemagne', 'Quart de finale', '1', '0', '1', 'Rocket Center', 'Hillford');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('100', 'Uruguay', 'Allemagne', 'Principal', '1998-06-10');
INSERT INTO arbitre_match VALUES ('140', 'Uruguay', 'Allemagne', 'Assistant', '1998-06-10');
INSERT INTO arbitre_match VALUES ('170', 'Uruguay', 'Allemagne', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('11', '170', 'Uruguay', 'Allemagne', '1998-06-10', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('13', '170', 'Uruguay', 'Allemagne', '1998-06-10', 'Rouge');
INSERT INTO arbitre_match VALUES ('240', 'Uruguay', 'Allemagne', 'Assistant', '1998-06-10');

 -- Match -- 

INSERT INTO match_foot VALUES ('1998-06-10', 'Italie', 'Portugal', 'Ronde de groupe', '6', '5', '1', 'Rocket Center', 'Hillford');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('60', 'Italie', 'Portugal', 'Principal', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('21', '60', 'Italie', 'Portugal', '1998-06-10', 'Rouge');
INSERT INTO arbitre_match VALUES ('150', 'Italie', 'Portugal', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('25', '150', 'Italie', 'Portugal', '1998-06-10', 'Rouge');
INSERT INTO arbitre_match VALUES ('160', 'Italie', 'Portugal', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('24', '160', 'Italie', 'Portugal', '1998-06-10', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('26', '160', 'Italie', 'Portugal', '1998-06-10', 'Rouge');
INSERT INTO arbitre_match VALUES ('230', 'Italie', 'Portugal', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('21', '230', 'Italie', 'Portugal', '1998-06-10', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('23', '230', 'Italie', 'Portugal', '1998-06-10', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('1998-06-10', 'France', 'Autriche', 'Finale', '1', '0', '1', 'Rocket Center', 'Hillford');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('100', 'France', 'Autriche', 'Principal', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('33', '100', 'France', 'Autriche', '1998-06-10', 'Jaune');
INSERT INTO arbitre_match VALUES ('110', 'France', 'Autriche', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('36', '110', 'France', 'Autriche', '1998-06-10', 'Jaune');
INSERT INTO arbitre_match VALUES ('200', 'France', 'Autriche', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('34', '200', 'France', 'Autriche', '1998-06-10', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('32', '200', 'France', 'Autriche', '1998-06-10', 'Rouge');
INSERT INTO arbitre_match VALUES ('240', 'France', 'Autriche', 'Assistant', '1998-06-10');

 -- Match -- 

INSERT INTO match_foot VALUES ('1998-06-10', 'Canada', 'Yougoslavie', 'Ronde de groupe', '5', '0', '1', 'Rocket Center', 'Hillford');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('70', 'Canada', 'Yougoslavie', 'Principal', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('44', '70', 'Canada', 'Yougoslavie', '1998-06-10', 'Rouge');
INSERT INTO arbitre_match VALUES ('120', 'Canada', 'Yougoslavie', 'Assistant', '1998-06-10');
INSERT INTO arbitre_match VALUES ('160', 'Canada', 'Yougoslavie', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('44', '160', 'Canada', 'Yougoslavie', '1998-06-10', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('41', '160', 'Canada', 'Yougoslavie', '1998-06-10', 'Rouge');
INSERT INTO arbitre_match VALUES ('240', 'Canada', 'Yougoslavie', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('42', '240', 'Canada', 'Yougoslavie', '1998-06-10', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('42', '240', 'Canada', 'Yougoslavie', '1998-06-10', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('1998-06-10', 'Bresil', 'Union sovietique', 'Ronde de groupe', '5', '2', '1', 'Rocket Center', 'Hillford');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('100', 'Bresil', 'Union sovietique', 'Principal', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('54', '100', 'Bresil', 'Union sovietique', '1998-06-10', 'Rouge');
INSERT INTO arbitre_match VALUES ('150', 'Bresil', 'Union sovietique', 'Assistant', '1998-06-10');
INSERT INTO arbitre_match VALUES ('170', 'Bresil', 'Union sovietique', 'Assistant', '1998-06-10');
INSERT INTO arbitre_match VALUES ('210', 'Bresil', 'Union sovietique', 'Assistant', '1998-06-10');

 -- Match -- 

INSERT INTO match_foot VALUES ('1998-06-10', 'Suisse', 'Tchecoslovaquie', 'Ronde de 16', '2', '1', '1', 'Rocket Center', 'Hillford');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Suisse', 'Tchecoslovaquie', 'Principal', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('63', '90', 'Suisse', 'Tchecoslovaquie', '1998-06-10', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('63', '90', 'Suisse', 'Tchecoslovaquie', '1998-06-10', 'Rouge');
INSERT INTO arbitre_match VALUES ('120', 'Suisse', 'Tchecoslovaquie', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('65', '120', 'Suisse', 'Tchecoslovaquie', '1998-06-10', 'Jaune');
INSERT INTO arbitre_match VALUES ('170', 'Suisse', 'Tchecoslovaquie', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('64', '170', 'Suisse', 'Tchecoslovaquie', '1998-06-10', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('66', '170', 'Suisse', 'Tchecoslovaquie', '1998-06-10', 'Rouge');
INSERT INTO arbitre_match VALUES ('220', 'Suisse', 'Tchecoslovaquie', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('66', '220', 'Suisse', 'Tchecoslovaquie', '1998-06-10', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('1998-06-10', 'Suede', 'Pologne', 'Ronde de 16', '1', '3', '1', 'Rocket Center', 'Hillford');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('60', 'Suede', 'Pologne', 'Principal', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('76', '60', 'Suede', 'Pologne', '1998-06-10', 'Jaune');
INSERT INTO arbitre_match VALUES ('120', 'Suede', 'Pologne', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('75', '120', 'Suede', 'Pologne', '1998-06-10', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('75', '120', 'Suede', 'Pologne', '1998-06-10', 'Jaune');
INSERT INTO arbitre_match VALUES ('200', 'Suede', 'Pologne', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('76', '200', 'Suede', 'Pologne', '1998-06-10', 'Jaune');
INSERT INTO arbitre_match VALUES ('210', 'Suede', 'Pologne', 'Assistant', '1998-06-10');

 -- Match -- 

INSERT INTO match_foot VALUES ('1998-06-10', 'Chili', 'Argentine', 'Finale', '5', '4', '1', 'Rocket Center', 'Hillford');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('80', 'Chili', 'Argentine', 'Principal', '1998-06-10');
INSERT INTO arbitre_match VALUES ('140', 'Chili', 'Argentine', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('83', '140', 'Chili', 'Argentine', '1998-06-10', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('85', '140', 'Chili', 'Argentine', '1998-06-10', 'Rouge');
INSERT INTO arbitre_match VALUES ('170', 'Chili', 'Argentine', 'Assistant', '1998-06-10');
INSERT INTO arbitre_match VALUES ('210', 'Chili', 'Argentine', 'Assistant', '1998-06-10');

 -- Match -- 

INSERT INTO match_foot VALUES ('1998-06-10', 'Angleterre', 'Belgique', 'Ronde de 16', '5', '0', '1', 'Rocket Center', 'Hillford');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('100', 'Angleterre', 'Belgique', 'Principal', '1998-06-10');
INSERT INTO arbitre_match VALUES ('150', 'Angleterre', 'Belgique', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('91', '150', 'Angleterre', 'Belgique', '1998-06-10', 'Jaune');
INSERT INTO arbitre_match VALUES ('170', 'Angleterre', 'Belgique', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('95', '170', 'Angleterre', 'Belgique', '1998-06-10', 'Rouge');
INSERT INTO arbitre_match VALUES ('230', 'Angleterre', 'Belgique', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('91', '230', 'Angleterre', 'Belgique', '1998-06-10', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('92', '230', 'Angleterre', 'Belgique', '1998-06-10', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('1998-06-10', 'Mexique', 'Croatie', 'Ronde de 16', '4', '2', '1', 'Rocket Center', 'Hillford');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('100', 'Mexique', 'Croatie', 'Principal', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('102', '100', 'Mexique', 'Croatie', '1998-06-10', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('104', '100', 'Mexique', 'Croatie', '1998-06-10', 'Jaune');
INSERT INTO arbitre_match VALUES ('140', 'Mexique', 'Croatie', 'Assistant', '1998-06-10');
INSERT INTO arbitre_match VALUES ('160', 'Mexique', 'Croatie', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('106', '160', 'Mexique', 'Croatie', '1998-06-10', 'Jaune');
INSERT INTO arbitre_match VALUES ('250', 'Mexique', 'Croatie', 'Assistant', '1998-06-10');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('104', '250', 'Mexique', 'Croatie', '1998-06-10', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('103', '250', 'Mexique', 'Croatie', '1998-06-10', 'Rouge');


  -- Coupe Du Monde  --- 
INSERT INTO coupe_du_monde VALUES ('2', '2002-05-31', '2002-06-30');
INSERT INTO pays_coupe VALUES ('Italie', '2');


 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Uruguay', '2', '7', '3');
INSERT INTO collaborateur_equipe VALUES ('8', 'Uruguay', '2');
INSERT INTO collaborateur_equipe VALUES ('9', 'Uruguay', '2');
INSERT INTO joueur_equipe VALUES ('1', 'Uruguay', '2', 'Avant-centre', '1', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('2', 'Uruguay', '2', 'Arriere latéral', '8', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('3', 'Uruguay', '2', 'Millieu defensif', '19', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('4', 'Uruguay', '2', 'Millieu offensif', '30', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('5', 'Uruguay', '2', 'Gardien de but', '25', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('6', 'Uruguay', '2', 'Attaquant de pointe', '44', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Italie', '2', '17', '25');
INSERT INTO collaborateur_equipe VALUES ('18', 'Italie', '2');
INSERT INTO collaborateur_equipe VALUES ('19', 'Italie', '2');
INSERT INTO joueur_equipe VALUES ('11', 'Italie', '2', 'Avant-centre', '0', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('12', 'Italie', '2', 'Arriere latéral', '10', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('13', 'Italie', '2', 'Millieu defensif', '13', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('14', 'Italie', '2', 'Millieu offensif', '18', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('15', 'Italie', '2', 'Gardien de but', '24', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('16', 'Italie', '2', 'Attaquant de pointe', '43', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('France', '2', '27', '10');
INSERT INTO collaborateur_equipe VALUES ('28', 'France', '2');
INSERT INTO collaborateur_equipe VALUES ('29', 'France', '2');
INSERT INTO joueur_equipe VALUES ('21', 'France', '2', 'Avant-centre', '1', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('22', 'France', '2', 'Arriere latéral', '10', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('23', 'France', '2', 'Millieu defensif', '14', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('24', 'France', '2', 'Millieu offensif', '21', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('25', 'France', '2', 'Gardien de but', '36', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('26', 'France', '2', 'Attaquant de pointe', '33', 'Real Madrid');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Canada', '2', '37', '29');
INSERT INTO collaborateur_equipe VALUES ('38', 'Canada', '2');
INSERT INTO collaborateur_equipe VALUES ('39', 'Canada', '2');
INSERT INTO joueur_equipe VALUES ('31', 'Canada', '2', 'Avant-centre', '1', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('32', 'Canada', '2', 'Arriere latéral', '8', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('33', 'Canada', '2', 'Millieu defensif', '18', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('34', 'Canada', '2', 'Millieu offensif', '22', 'France National');
INSERT INTO joueur_equipe VALUES ('35', 'Canada', '2', 'Gardien de but', '29', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('36', 'Canada', '2', 'Attaquant de pointe', '42', 'Brazil nationnal');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Bresil', '2', '47', '21');
INSERT INTO collaborateur_equipe VALUES ('48', 'Bresil', '2');
INSERT INTO collaborateur_equipe VALUES ('49', 'Bresil', '2');
INSERT INTO joueur_equipe VALUES ('41', 'Bresil', '2', 'Avant-centre', '0', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('42', 'Bresil', '2', 'Arriere latéral', '7', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('43', 'Bresil', '2', 'Millieu defensif', '20', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('44', 'Bresil', '2', 'Millieu offensif', '18', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('45', 'Bresil', '2', 'Gardien de but', '41', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('46', 'Bresil', '2', 'Attaquant de pointe', '45', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Suisse', '2', '57', '14');
INSERT INTO collaborateur_equipe VALUES ('58', 'Suisse', '2');
INSERT INTO collaborateur_equipe VALUES ('59', 'Suisse', '2');
INSERT INTO joueur_equipe VALUES ('51', 'Suisse', '2', 'Avant-centre', '0', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('52', 'Suisse', '2', 'Arriere latéral', '9', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('53', 'Suisse', '2', 'Millieu defensif', '13', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('54', 'Suisse', '2', 'Millieu offensif', '27', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('55', 'Suisse', '2', 'Gardien de but', '28', 'France National');
INSERT INTO joueur_equipe VALUES ('56', 'Suisse', '2', 'Attaquant de pointe', '45', 'Spain N.F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Suede', '2', '67', '4');
INSERT INTO collaborateur_equipe VALUES ('68', 'Suede', '2');
INSERT INTO collaborateur_equipe VALUES ('69', 'Suede', '2');
INSERT INTO joueur_equipe VALUES ('61', 'Suede', '2', 'Avant-centre', '0', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('62', 'Suede', '2', 'Arriere latéral', '8', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('63', 'Suede', '2', 'Millieu defensif', '14', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('64', 'Suede', '2', 'Millieu offensif', '24', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('65', 'Suede', '2', 'Gardien de but', '39', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('66', 'Suede', '2', 'Attaquant de pointe', '48', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Chili', '2', '77', '30');
INSERT INTO collaborateur_equipe VALUES ('78', 'Chili', '2');
INSERT INTO collaborateur_equipe VALUES ('79', 'Chili', '2');
INSERT INTO joueur_equipe VALUES ('71', 'Chili', '2', 'Avant-centre', '1', 'France National');
INSERT INTO joueur_equipe VALUES ('72', 'Chili', '2', 'Arriere latéral', '9', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('73', 'Chili', '2', 'Millieu defensif', '19', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('74', 'Chili', '2', 'Millieu offensif', '30', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('75', 'Chili', '2', 'Gardien de but', '28', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('76', 'Chili', '2', 'Attaquant de pointe', '30', 'Manchester United F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Angleterre', '2', '87', '5');
INSERT INTO collaborateur_equipe VALUES ('88', 'Angleterre', '2');
INSERT INTO collaborateur_equipe VALUES ('89', 'Angleterre', '2');
INSERT INTO joueur_equipe VALUES ('81', 'Angleterre', '2', 'Avant-centre', '1', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('82', 'Angleterre', '2', 'Arriere latéral', '9', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('83', 'Angleterre', '2', 'Millieu defensif', '18', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('84', 'Angleterre', '2', 'Millieu offensif', '22', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('85', 'Angleterre', '2', 'Gardien de but', '39', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('86', 'Angleterre', '2', 'Attaquant de pointe', '31', 'Manchester United F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Mexique', '2', '97', '20');
INSERT INTO collaborateur_equipe VALUES ('98', 'Mexique', '2');
INSERT INTO collaborateur_equipe VALUES ('99', 'Mexique', '2');
INSERT INTO joueur_equipe VALUES ('91', 'Mexique', '2', 'Avant-centre', '0', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('92', 'Mexique', '2', 'Arriere latéral', '10', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('93', 'Mexique', '2', 'Millieu defensif', '21', 'France National');
INSERT INTO joueur_equipe VALUES ('94', 'Mexique', '2', 'Millieu offensif', '23', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('95', 'Mexique', '2', 'Gardien de but', '37', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('96', 'Mexique', '2', 'Attaquant de pointe', '43', 'Liverpool F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Allemagne', '2', '107', '28');
INSERT INTO collaborateur_equipe VALUES ('108', 'Allemagne', '2');
INSERT INTO collaborateur_equipe VALUES ('109', 'Allemagne', '2');
INSERT INTO joueur_equipe VALUES ('101', 'Allemagne', '2', 'Avant-centre', '1', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('102', 'Allemagne', '2', 'Arriere latéral', '8', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('103', 'Allemagne', '2', 'Millieu defensif', '19', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('104', 'Allemagne', '2', 'Millieu offensif', '30', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('105', 'Allemagne', '2', 'Gardien de but', '27', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('106', 'Allemagne', '2', 'Attaquant de pointe', '42', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Portugal', '2', '117', '19');
INSERT INTO collaborateur_equipe VALUES ('118', 'Portugal', '2');
INSERT INTO collaborateur_equipe VALUES ('119', 'Portugal', '2');
INSERT INTO joueur_equipe VALUES ('111', 'Portugal', '2', 'Avant-centre', '1', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('112', 'Portugal', '2', 'Arriere latéral', '10', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('113', 'Portugal', '2', 'Millieu defensif', '15', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('114', 'Portugal', '2', 'Millieu offensif', '29', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('115', 'Portugal', '2', 'Gardien de but', '29', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('116', 'Portugal', '2', 'Attaquant de pointe', '38', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Autriche', '2', '127', '6');
INSERT INTO collaborateur_equipe VALUES ('128', 'Autriche', '2');
INSERT INTO collaborateur_equipe VALUES ('129', 'Autriche', '2');
INSERT INTO joueur_equipe VALUES ('121', 'Autriche', '2', 'Avant-centre', '1', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('122', 'Autriche', '2', 'Arriere latéral', '7', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('123', 'Autriche', '2', 'Millieu defensif', '16', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('124', 'Autriche', '2', 'Millieu offensif', '23', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('125', 'Autriche', '2', 'Gardien de but', '40', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('126', 'Autriche', '2', 'Attaquant de pointe', '32', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Yougoslavie', '2', '137', '27');
INSERT INTO collaborateur_equipe VALUES ('138', 'Yougoslavie', '2');
INSERT INTO collaborateur_equipe VALUES ('139', 'Yougoslavie', '2');
INSERT INTO joueur_equipe VALUES ('131', 'Yougoslavie', '2', 'Avant-centre', '0', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('132', 'Yougoslavie', '2', 'Arriere latéral', '9', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('133', 'Yougoslavie', '2', 'Millieu defensif', '19', 'France National');
INSERT INTO joueur_equipe VALUES ('134', 'Yougoslavie', '2', 'Millieu offensif', '31', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('135', 'Yougoslavie', '2', 'Gardien de but', '34', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('136', 'Yougoslavie', '2', 'Attaquant de pointe', '34', 'Spain N.F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Union sovietique', '2', '147', '11');
INSERT INTO collaborateur_equipe VALUES ('148', 'Union sovietique', '2');
INSERT INTO collaborateur_equipe VALUES ('149', 'Union sovietique', '2');
INSERT INTO joueur_equipe VALUES ('141', 'Union sovietique', '2', 'Avant-centre', '1', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('142', 'Union sovietique', '2', 'Arriere latéral', '6', 'France National');
INSERT INTO joueur_equipe VALUES ('143', 'Union sovietique', '2', 'Millieu defensif', '21', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('144', 'Union sovietique', '2', 'Millieu offensif', '28', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('145', 'Union sovietique', '2', 'Gardien de but', '24', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('146', 'Union sovietique', '2', 'Attaquant de pointe', '46', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Tchecoslovaquie', '2', '157', '16');
INSERT INTO collaborateur_equipe VALUES ('158', 'Tchecoslovaquie', '2');
INSERT INTO collaborateur_equipe VALUES ('159', 'Tchecoslovaquie', '2');
INSERT INTO joueur_equipe VALUES ('151', 'Tchecoslovaquie', '2', 'Avant-centre', '1', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('152', 'Tchecoslovaquie', '2', 'Arriere latéral', '7', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('153', 'Tchecoslovaquie', '2', 'Millieu defensif', '18', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('154', 'Tchecoslovaquie', '2', 'Millieu offensif', '27', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('155', 'Tchecoslovaquie', '2', 'Gardien de but', '35', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('156', 'Tchecoslovaquie', '2', 'Attaquant de pointe', '37', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Pologne', '2', '167', '18');
INSERT INTO collaborateur_equipe VALUES ('168', 'Pologne', '2');
INSERT INTO collaborateur_equipe VALUES ('169', 'Pologne', '2');
INSERT INTO joueur_equipe VALUES ('161', 'Pologne', '2', 'Avant-centre', '1', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('162', 'Pologne', '2', 'Arriere latéral', '6', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('163', 'Pologne', '2', 'Millieu defensif', '15', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('164', 'Pologne', '2', 'Millieu offensif', '23', 'France National');
INSERT INTO joueur_equipe VALUES ('165', 'Pologne', '2', 'Gardien de but', '24', 'France National');
INSERT INTO joueur_equipe VALUES ('166', 'Pologne', '2', 'Attaquant de pointe', '49', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Argentine', '2', '177', '24');
INSERT INTO collaborateur_equipe VALUES ('178', 'Argentine', '2');
INSERT INTO collaborateur_equipe VALUES ('179', 'Argentine', '2');
INSERT INTO joueur_equipe VALUES ('171', 'Argentine', '2', 'Avant-centre', '1', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('172', 'Argentine', '2', 'Arriere latéral', '10', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('173', 'Argentine', '2', 'Millieu defensif', '12', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('174', 'Argentine', '2', 'Millieu offensif', '31', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('175', 'Argentine', '2', 'Gardien de but', '30', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('176', 'Argentine', '2', 'Attaquant de pointe', '48', 'Liverpool F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Belgique', '2', '187', '22');
INSERT INTO collaborateur_equipe VALUES ('188', 'Belgique', '2');
INSERT INTO collaborateur_equipe VALUES ('189', 'Belgique', '2');
INSERT INTO joueur_equipe VALUES ('181', 'Belgique', '2', 'Avant-centre', '0', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('182', 'Belgique', '2', 'Arriere latéral', '8', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('183', 'Belgique', '2', 'Millieu defensif', '15', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('184', 'Belgique', '2', 'Millieu offensif', '18', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('185', 'Belgique', '2', 'Gardien de but', '27', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('186', 'Belgique', '2', 'Attaquant de pointe', '47', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Croatie', '2', '197', '13');
INSERT INTO collaborateur_equipe VALUES ('198', 'Croatie', '2');
INSERT INTO collaborateur_equipe VALUES ('199', 'Croatie', '2');
INSERT INTO joueur_equipe VALUES ('191', 'Croatie', '2', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('192', 'Croatie', '2', 'Arriere latéral', '9', 'France National');
INSERT INTO joueur_equipe VALUES ('193', 'Croatie', '2', 'Millieu defensif', '18', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('194', 'Croatie', '2', 'Millieu offensif', '29', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('195', 'Croatie', '2', 'Gardien de but', '32', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('196', 'Croatie', '2', 'Attaquant de pointe', '47', 'Real Madrid');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Pays-Bas', '2', '207', '15');
INSERT INTO collaborateur_equipe VALUES ('208', 'Pays-Bas', '2');
INSERT INTO collaborateur_equipe VALUES ('209', 'Pays-Bas', '2');
INSERT INTO joueur_equipe VALUES ('201', 'Pays-Bas', '2', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('202', 'Pays-Bas', '2', 'Arriere latéral', '7', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('203', 'Pays-Bas', '2', 'Millieu defensif', '13', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('204', 'Pays-Bas', '2', 'Millieu offensif', '29', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('205', 'Pays-Bas', '2', 'Gardien de but', '26', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('206', 'Pays-Bas', '2', 'Attaquant de pointe', '31', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Coree du Sud', '2', '217', '26');
INSERT INTO collaborateur_equipe VALUES ('218', 'Coree du Sud', '2');
INSERT INTO collaborateur_equipe VALUES ('219', 'Coree du Sud', '2');
INSERT INTO joueur_equipe VALUES ('211', 'Coree du Sud', '2', 'Avant-centre', '0', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('212', 'Coree du Sud', '2', 'Arriere latéral', '8', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('213', 'Coree du Sud', '2', 'Millieu defensif', '16', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('214', 'Coree du Sud', '2', 'Millieu offensif', '31', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('215', 'Coree du Sud', '2', 'Gardien de but', '36', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('216', 'Coree du Sud', '2', 'Attaquant de pointe', '41', 'Manchester United F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Japon', '2', '227', '1');
INSERT INTO collaborateur_equipe VALUES ('228', 'Japon', '2');
INSERT INTO collaborateur_equipe VALUES ('229', 'Japon', '2');
INSERT INTO joueur_equipe VALUES ('221', 'Japon', '2', 'Avant-centre', '1', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('222', 'Japon', '2', 'Arriere latéral', '9', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('223', 'Japon', '2', 'Millieu defensif', '20', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('224', 'Japon', '2', 'Millieu offensif', '23', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('225', 'Japon', '2', 'Gardien de but', '34', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('226', 'Japon', '2', 'Attaquant de pointe', '34', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Russie', '2', '237', '7');
INSERT INTO collaborateur_equipe VALUES ('238', 'Russie', '2');
INSERT INTO collaborateur_equipe VALUES ('239', 'Russie', '2');
INSERT INTO joueur_equipe VALUES ('231', 'Russie', '2', 'Avant-centre', '1', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('232', 'Russie', '2', 'Arriere latéral', '10', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('233', 'Russie', '2', 'Millieu defensif', '20', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('234', 'Russie', '2', 'Millieu offensif', '26', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('235', 'Russie', '2', 'Gardien de but', '24', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('236', 'Russie', '2', 'Attaquant de pointe', '32', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Maroque', '2', '247', '17');
INSERT INTO collaborateur_equipe VALUES ('248', 'Maroque', '2');
INSERT INTO collaborateur_equipe VALUES ('249', 'Maroque', '2');
INSERT INTO joueur_equipe VALUES ('241', 'Maroque', '2', 'Avant-centre', '0', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('242', 'Maroque', '2', 'Arriere latéral', '10', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('243', 'Maroque', '2', 'Millieu defensif', '19', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('244', 'Maroque', '2', 'Millieu offensif', '29', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('245', 'Maroque', '2', 'Gardien de but', '29', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('246', 'Maroque', '2', 'Attaquant de pointe', '45', 'Brazil nationnal');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Egypt', '2', '257', '23');
INSERT INTO collaborateur_equipe VALUES ('258', 'Egypt', '2');
INSERT INTO collaborateur_equipe VALUES ('259', 'Egypt', '2');
INSERT INTO joueur_equipe VALUES ('251', 'Egypt', '2', 'Avant-centre', '0', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('252', 'Egypt', '2', 'Arriere latéral', '10', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('253', 'Egypt', '2', 'Millieu defensif', '18', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('254', 'Egypt', '2', 'Millieu offensif', '24', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('255', 'Egypt', '2', 'Gardien de but', '32', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('256', 'Egypt', '2', 'Attaquant de pointe', '43', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Grece', '2', '267', '12');
INSERT INTO collaborateur_equipe VALUES ('268', 'Grece', '2');
INSERT INTO collaborateur_equipe VALUES ('269', 'Grece', '2');
INSERT INTO joueur_equipe VALUES ('261', 'Grece', '2', 'Avant-centre', '1', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('262', 'Grece', '2', 'Arriere latéral', '11', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('263', 'Grece', '2', 'Millieu defensif', '14', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('264', 'Grece', '2', 'Millieu offensif', '22', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('265', 'Grece', '2', 'Gardien de but', '24', 'France National');
INSERT INTO joueur_equipe VALUES ('266', 'Grece', '2', 'Attaquant de pointe', '42', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Qatar', '2', '277', '8');
INSERT INTO collaborateur_equipe VALUES ('278', 'Qatar', '2');
INSERT INTO collaborateur_equipe VALUES ('279', 'Qatar', '2');
INSERT INTO joueur_equipe VALUES ('271', 'Qatar', '2', 'Avant-centre', '1', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('272', 'Qatar', '2', 'Arriere latéral', '10', 'France National');
INSERT INTO joueur_equipe VALUES ('273', 'Qatar', '2', 'Millieu defensif', '20', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('274', 'Qatar', '2', 'Millieu offensif', '18', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('275', 'Qatar', '2', 'Gardien de but', '40', 'France National');
INSERT INTO joueur_equipe VALUES ('276', 'Qatar', '2', 'Attaquant de pointe', '34', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Etats-Unis', '2', '287', '2');
INSERT INTO collaborateur_equipe VALUES ('288', 'Etats-Unis', '2');
INSERT INTO collaborateur_equipe VALUES ('289', 'Etats-Unis', '2');
INSERT INTO joueur_equipe VALUES ('281', 'Etats-Unis', '2', 'Avant-centre', '1', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('282', 'Etats-Unis', '2', 'Arriere latéral', '7', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('283', 'Etats-Unis', '2', 'Millieu defensif', '12', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('284', 'Etats-Unis', '2', 'Millieu offensif', '30', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('285', 'Etats-Unis', '2', 'Gardien de but', '30', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('286', 'Etats-Unis', '2', 'Attaquant de pointe', '41', 'Real Madrid');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Turquie', '2', '297', '9');
INSERT INTO collaborateur_equipe VALUES ('298', 'Turquie', '2');
INSERT INTO collaborateur_equipe VALUES ('299', 'Turquie', '2');
INSERT INTO joueur_equipe VALUES ('291', 'Turquie', '2', 'Avant-centre', '1', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('292', 'Turquie', '2', 'Arriere latéral', '7', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('293', 'Turquie', '2', 'Millieu defensif', '20', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('294', 'Turquie', '2', 'Millieu offensif', '25', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('295', 'Turquie', '2', 'Gardien de but', '39', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('296', 'Turquie', '2', 'Attaquant de pointe', '42', 'Liverpool F.C.');

 -- Stade -- 
INSERT INTO stade VALUES ('Bob Center', 'Harmsby', '32000', 'Italie', '1883');

 -- Match -- 

INSERT INTO match_foot VALUES ('2002-05-31', 'Italie', 'Autriche', 'Ronde de 16', '3', '0', '2', 'Bob Center', 'Harmsby');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Italie', 'Autriche', 'Principal', '2002-05-31');
INSERT INTO arbitre_match VALUES ('130', 'Italie', 'Autriche', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('11', '130', 'Italie', 'Autriche', '2002-05-31', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('12', '130', 'Italie', 'Autriche', '2002-05-31', 'Rouge');
INSERT INTO arbitre_match VALUES ('170', 'Italie', 'Autriche', 'Assistant', '2002-05-31');
INSERT INTO arbitre_match VALUES ('210', 'Italie', 'Autriche', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('12', '210', 'Italie', 'Autriche', '2002-05-31', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2002-05-31', 'France', 'Yougoslavie', 'Match de 3e place', '3', '5', '2', 'Bob Center', 'Harmsby');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('80', 'France', 'Yougoslavie', 'Principal', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('24', '80', 'France', 'Yougoslavie', '2002-05-31', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('22', '80', 'France', 'Yougoslavie', '2002-05-31', 'Rouge');
INSERT INTO arbitre_match VALUES ('110', 'France', 'Yougoslavie', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('26', '110', 'France', 'Yougoslavie', '2002-05-31', 'Rouge');
INSERT INTO arbitre_match VALUES ('170', 'France', 'Yougoslavie', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('24', '170', 'France', 'Yougoslavie', '2002-05-31', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('21', '170', 'France', 'Yougoslavie', '2002-05-31', 'Rouge');
INSERT INTO arbitre_match VALUES ('230', 'France', 'Yougoslavie', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('23', '230', 'France', 'Yougoslavie', '2002-05-31', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('23', '230', 'France', 'Yougoslavie', '2002-05-31', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2002-05-31', 'Canada', 'Union sovietique', 'Match de 3e place', '3', '0', '2', 'Bob Center', 'Harmsby');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('70', 'Canada', 'Union sovietique', 'Principal', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('36', '70', 'Canada', 'Union sovietique', '2002-05-31', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('35', '70', 'Canada', 'Union sovietique', '2002-05-31', 'Jaune');
INSERT INTO arbitre_match VALUES ('150', 'Canada', 'Union sovietique', 'Assistant', '2002-05-31');
INSERT INTO arbitre_match VALUES ('170', 'Canada', 'Union sovietique', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('34', '170', 'Canada', 'Union sovietique', '2002-05-31', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('35', '170', 'Canada', 'Union sovietique', '2002-05-31', 'Rouge');
INSERT INTO arbitre_match VALUES ('250', 'Canada', 'Union sovietique', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('32', '250', 'Canada', 'Union sovietique', '2002-05-31', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2002-05-31', 'Bresil', 'Tchecoslovaquie', 'Finale', '1', '5', '2', 'Bob Center', 'Harmsby');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Bresil', 'Tchecoslovaquie', 'Principal', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('43', '90', 'Bresil', 'Tchecoslovaquie', '2002-05-31', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('45', '90', 'Bresil', 'Tchecoslovaquie', '2002-05-31', 'Jaune');
INSERT INTO arbitre_match VALUES ('110', 'Bresil', 'Tchecoslovaquie', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('43', '110', 'Bresil', 'Tchecoslovaquie', '2002-05-31', 'Jaune');
INSERT INTO arbitre_match VALUES ('170', 'Bresil', 'Tchecoslovaquie', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('42', '170', 'Bresil', 'Tchecoslovaquie', '2002-05-31', 'Rouge');
INSERT INTO arbitre_match VALUES ('220', 'Bresil', 'Tchecoslovaquie', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('44', '220', 'Bresil', 'Tchecoslovaquie', '2002-05-31', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('41', '220', 'Bresil', 'Tchecoslovaquie', '2002-05-31', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('2002-05-31', 'Suisse', 'Pologne', 'Ronde de groupe', '4', '0', '2', 'Bob Center', 'Harmsby');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Suisse', 'Pologne', 'Principal', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('52', '90', 'Suisse', 'Pologne', '2002-05-31', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('51', '90', 'Suisse', 'Pologne', '2002-05-31', 'Jaune');
INSERT INTO arbitre_match VALUES ('140', 'Suisse', 'Pologne', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('55', '140', 'Suisse', 'Pologne', '2002-05-31', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('53', '140', 'Suisse', 'Pologne', '2002-05-31', 'Rouge');
INSERT INTO arbitre_match VALUES ('170', 'Suisse', 'Pologne', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('53', '170', 'Suisse', 'Pologne', '2002-05-31', 'Jaune');
INSERT INTO arbitre_match VALUES ('210', 'Suisse', 'Pologne', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('52', '210', 'Suisse', 'Pologne', '2002-05-31', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('53', '210', 'Suisse', 'Pologne', '2002-05-31', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2002-05-31', 'Suede', 'Argentine', 'Semi-finale', '0', '3', '2', 'Bob Center', 'Harmsby');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('100', 'Suede', 'Argentine', 'Principal', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('63', '100', 'Suede', 'Argentine', '2002-05-31', 'Rouge');
INSERT INTO arbitre_match VALUES ('120', 'Suede', 'Argentine', 'Assistant', '2002-05-31');
INSERT INTO arbitre_match VALUES ('190', 'Suede', 'Argentine', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('66', '190', 'Suede', 'Argentine', '2002-05-31', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('64', '190', 'Suede', 'Argentine', '2002-05-31', 'Jaune');
INSERT INTO arbitre_match VALUES ('210', 'Suede', 'Argentine', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('62', '210', 'Suede', 'Argentine', '2002-05-31', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('64', '210', 'Suede', 'Argentine', '2002-05-31', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('2002-05-31', 'Chili', 'Belgique', 'Ronde de 16', '0', '4', '2', 'Bob Center', 'Harmsby');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('60', 'Chili', 'Belgique', 'Principal', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('76', '60', 'Chili', 'Belgique', '2002-05-31', 'Rouge');
INSERT INTO arbitre_match VALUES ('110', 'Chili', 'Belgique', 'Assistant', '2002-05-31');
INSERT INTO arbitre_match VALUES ('190', 'Chili', 'Belgique', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('74', '190', 'Chili', 'Belgique', '2002-05-31', 'Jaune');
INSERT INTO arbitre_match VALUES ('250', 'Chili', 'Belgique', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('74', '250', 'Chili', 'Belgique', '2002-05-31', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('2002-05-31', 'Angleterre', 'Croatie', 'Ronde de 16', '0', '4', '2', 'Bob Center', 'Harmsby');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('70', 'Angleterre', 'Croatie', 'Principal', '2002-05-31');
INSERT INTO arbitre_match VALUES ('130', 'Angleterre', 'Croatie', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('85', '130', 'Angleterre', 'Croatie', '2002-05-31', 'Jaune');
INSERT INTO arbitre_match VALUES ('190', 'Angleterre', 'Croatie', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('86', '190', 'Angleterre', 'Croatie', '2002-05-31', 'Jaune');
INSERT INTO arbitre_match VALUES ('230', 'Angleterre', 'Croatie', 'Assistant', '2002-05-31');

 -- Match -- 

INSERT INTO match_foot VALUES ('2002-05-31', 'Mexique', 'Pays-Bas', 'Finale', '5', '4', '2', 'Bob Center', 'Harmsby');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Mexique', 'Pays-Bas', 'Principal', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('91', '90', 'Mexique', 'Pays-Bas', '2002-05-31', 'Rouge');
INSERT INTO arbitre_match VALUES ('120', 'Mexique', 'Pays-Bas', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('91', '120', 'Mexique', 'Pays-Bas', '2002-05-31', 'Jaune');
INSERT INTO arbitre_match VALUES ('180', 'Mexique', 'Pays-Bas', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('91', '180', 'Mexique', 'Pays-Bas', '2002-05-31', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('93', '180', 'Mexique', 'Pays-Bas', '2002-05-31', 'Rouge');
INSERT INTO arbitre_match VALUES ('240', 'Mexique', 'Pays-Bas', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('96', '240', 'Mexique', 'Pays-Bas', '2002-05-31', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('95', '240', 'Mexique', 'Pays-Bas', '2002-05-31', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('2002-05-31', 'Allemagne', 'Coree du Sud', 'Finale', '3', '4', '2', 'Bob Center', 'Harmsby');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('70', 'Allemagne', 'Coree du Sud', 'Principal', '2002-05-31');
INSERT INTO arbitre_match VALUES ('140', 'Allemagne', 'Coree du Sud', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('101', '140', 'Allemagne', 'Coree du Sud', '2002-05-31', 'Rouge');
INSERT INTO arbitre_match VALUES ('200', 'Allemagne', 'Coree du Sud', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('105', '200', 'Allemagne', 'Coree du Sud', '2002-05-31', 'Rouge');
INSERT INTO arbitre_match VALUES ('240', 'Allemagne', 'Coree du Sud', 'Assistant', '2002-05-31');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('103', '240', 'Allemagne', 'Coree du Sud', '2002-05-31', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('102', '240', 'Allemagne', 'Coree du Sud', '2002-05-31', 'Jaune');


  -- Coupe Du Monde  --- 
INSERT INTO coupe_du_monde VALUES ('3', '2006-06-09', '2006-07-9');
INSERT INTO pays_coupe VALUES ('France', '3');


 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Uruguay', '3', '7', '8');
INSERT INTO collaborateur_equipe VALUES ('8', 'Uruguay', '3');
INSERT INTO collaborateur_equipe VALUES ('9', 'Uruguay', '3');
INSERT INTO joueur_equipe VALUES ('1', 'Uruguay', '3', 'Avant-centre', '0', 'France National');
INSERT INTO joueur_equipe VALUES ('2', 'Uruguay', '3', 'Arriere latéral', '9', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('3', 'Uruguay', '3', 'Millieu defensif', '21', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('4', 'Uruguay', '3', 'Millieu offensif', '21', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('5', 'Uruguay', '3', 'Gardien de but', '25', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('6', 'Uruguay', '3', 'Attaquant de pointe', '35', 'AS Monaco');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Italie', '3', '17', '16');
INSERT INTO collaborateur_equipe VALUES ('18', 'Italie', '3');
INSERT INTO collaborateur_equipe VALUES ('19', 'Italie', '3');
INSERT INTO joueur_equipe VALUES ('11', 'Italie', '3', 'Avant-centre', '1', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('12', 'Italie', '3', 'Arriere latéral', '8', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('13', 'Italie', '3', 'Millieu defensif', '19', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('14', 'Italie', '3', 'Millieu offensif', '28', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('15', 'Italie', '3', 'Gardien de but', '31', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('16', 'Italie', '3', 'Attaquant de pointe', '39', 'AS Monaco');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('France', '3', '27', '9');
INSERT INTO collaborateur_equipe VALUES ('28', 'France', '3');
INSERT INTO collaborateur_equipe VALUES ('29', 'France', '3');
INSERT INTO joueur_equipe VALUES ('21', 'France', '3', 'Avant-centre', '1', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('22', 'France', '3', 'Arriere latéral', '9', 'France National');
INSERT INTO joueur_equipe VALUES ('23', 'France', '3', 'Millieu defensif', '14', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('24', 'France', '3', 'Millieu offensif', '28', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('25', 'France', '3', 'Gardien de but', '37', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('26', 'France', '3', 'Attaquant de pointe', '36', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Canada', '3', '37', '13');
INSERT INTO collaborateur_equipe VALUES ('38', 'Canada', '3');
INSERT INTO collaborateur_equipe VALUES ('39', 'Canada', '3');
INSERT INTO joueur_equipe VALUES ('31', 'Canada', '3', 'Avant-centre', '1', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('32', 'Canada', '3', 'Arriere latéral', '8', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('33', 'Canada', '3', 'Millieu defensif', '12', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('34', 'Canada', '3', 'Millieu offensif', '19', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('35', 'Canada', '3', 'Gardien de but', '32', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('36', 'Canada', '3', 'Attaquant de pointe', '31', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Bresil', '3', '47', '1');
INSERT INTO collaborateur_equipe VALUES ('48', 'Bresil', '3');
INSERT INTO collaborateur_equipe VALUES ('49', 'Bresil', '3');
INSERT INTO joueur_equipe VALUES ('41', 'Bresil', '3', 'Avant-centre', '0', 'France National');
INSERT INTO joueur_equipe VALUES ('42', 'Bresil', '3', 'Arriere latéral', '6', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('43', 'Bresil', '3', 'Millieu defensif', '15', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('44', 'Bresil', '3', 'Millieu offensif', '21', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('45', 'Bresil', '3', 'Gardien de but', '40', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('46', 'Bresil', '3', 'Attaquant de pointe', '37', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Suisse', '3', '57', '3');
INSERT INTO collaborateur_equipe VALUES ('58', 'Suisse', '3');
INSERT INTO collaborateur_equipe VALUES ('59', 'Suisse', '3');
INSERT INTO joueur_equipe VALUES ('51', 'Suisse', '3', 'Avant-centre', '0', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('52', 'Suisse', '3', 'Arriere latéral', '6', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('53', 'Suisse', '3', 'Millieu defensif', '18', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('54', 'Suisse', '3', 'Millieu offensif', '25', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('55', 'Suisse', '3', 'Gardien de but', '38', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('56', 'Suisse', '3', 'Attaquant de pointe', '51', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Suede', '3', '67', '19');
INSERT INTO collaborateur_equipe VALUES ('68', 'Suede', '3');
INSERT INTO collaborateur_equipe VALUES ('69', 'Suede', '3');
INSERT INTO joueur_equipe VALUES ('61', 'Suede', '3', 'Avant-centre', '1', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('62', 'Suede', '3', 'Arriere latéral', '8', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('63', 'Suede', '3', 'Millieu defensif', '14', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('64', 'Suede', '3', 'Millieu offensif', '26', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('65', 'Suede', '3', 'Gardien de but', '38', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('66', 'Suede', '3', 'Attaquant de pointe', '33', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Chili', '3', '77', '4');
INSERT INTO collaborateur_equipe VALUES ('78', 'Chili', '3');
INSERT INTO collaborateur_equipe VALUES ('79', 'Chili', '3');
INSERT INTO joueur_equipe VALUES ('71', 'Chili', '3', 'Avant-centre', '0', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('72', 'Chili', '3', 'Arriere latéral', '8', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('73', 'Chili', '3', 'Millieu defensif', '21', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('74', 'Chili', '3', 'Millieu offensif', '23', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('75', 'Chili', '3', 'Gardien de but', '36', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('76', 'Chili', '3', 'Attaquant de pointe', '35', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Angleterre', '3', '87', '15');
INSERT INTO collaborateur_equipe VALUES ('88', 'Angleterre', '3');
INSERT INTO collaborateur_equipe VALUES ('89', 'Angleterre', '3');
INSERT INTO joueur_equipe VALUES ('81', 'Angleterre', '3', 'Avant-centre', '0', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('82', 'Angleterre', '3', 'Arriere latéral', '10', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('83', 'Angleterre', '3', 'Millieu defensif', '18', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('84', 'Angleterre', '3', 'Millieu offensif', '20', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('85', 'Angleterre', '3', 'Gardien de but', '37', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('86', 'Angleterre', '3', 'Attaquant de pointe', '31', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Mexique', '3', '97', '23');
INSERT INTO collaborateur_equipe VALUES ('98', 'Mexique', '3');
INSERT INTO collaborateur_equipe VALUES ('99', 'Mexique', '3');
INSERT INTO joueur_equipe VALUES ('91', 'Mexique', '3', 'Avant-centre', '0', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('92', 'Mexique', '3', 'Arriere latéral', '11', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('93', 'Mexique', '3', 'Millieu defensif', '15', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('94', 'Mexique', '3', 'Millieu offensif', '23', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('95', 'Mexique', '3', 'Gardien de but', '40', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('96', 'Mexique', '3', 'Attaquant de pointe', '33', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Allemagne', '3', '107', '6');
INSERT INTO collaborateur_equipe VALUES ('108', 'Allemagne', '3');
INSERT INTO collaborateur_equipe VALUES ('109', 'Allemagne', '3');
INSERT INTO joueur_equipe VALUES ('101', 'Allemagne', '3', 'Avant-centre', '0', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('102', 'Allemagne', '3', 'Arriere latéral', '7', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('103', 'Allemagne', '3', 'Millieu defensif', '19', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('104', 'Allemagne', '3', 'Millieu offensif', '31', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('105', 'Allemagne', '3', 'Gardien de but', '38', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('106', 'Allemagne', '3', 'Attaquant de pointe', '34', 'Spain N.F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Portugal', '3', '117', '30');
INSERT INTO collaborateur_equipe VALUES ('118', 'Portugal', '3');
INSERT INTO collaborateur_equipe VALUES ('119', 'Portugal', '3');
INSERT INTO joueur_equipe VALUES ('111', 'Portugal', '3', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('112', 'Portugal', '3', 'Arriere latéral', '11', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('113', 'Portugal', '3', 'Millieu defensif', '15', 'France National');
INSERT INTO joueur_equipe VALUES ('114', 'Portugal', '3', 'Millieu offensif', '23', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('115', 'Portugal', '3', 'Gardien de but', '38', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('116', 'Portugal', '3', 'Attaquant de pointe', '43', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Autriche', '3', '127', '27');
INSERT INTO collaborateur_equipe VALUES ('128', 'Autriche', '3');
INSERT INTO collaborateur_equipe VALUES ('129', 'Autriche', '3');
INSERT INTO joueur_equipe VALUES ('121', 'Autriche', '3', 'Avant-centre', '0', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('122', 'Autriche', '3', 'Arriere latéral', '10', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('123', 'Autriche', '3', 'Millieu defensif', '12', 'France National');
INSERT INTO joueur_equipe VALUES ('124', 'Autriche', '3', 'Millieu offensif', '31', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('125', 'Autriche', '3', 'Gardien de but', '27', 'France National');
INSERT INTO joueur_equipe VALUES ('126', 'Autriche', '3', 'Attaquant de pointe', '49', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Yougoslavie', '3', '137', '22');
INSERT INTO collaborateur_equipe VALUES ('138', 'Yougoslavie', '3');
INSERT INTO collaborateur_equipe VALUES ('139', 'Yougoslavie', '3');
INSERT INTO joueur_equipe VALUES ('131', 'Yougoslavie', '3', 'Avant-centre', '0', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('132', 'Yougoslavie', '3', 'Arriere latéral', '10', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('133', 'Yougoslavie', '3', 'Millieu defensif', '20', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('134', 'Yougoslavie', '3', 'Millieu offensif', '30', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('135', 'Yougoslavie', '3', 'Gardien de but', '28', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('136', 'Yougoslavie', '3', 'Attaquant de pointe', '51', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Union sovietique', '3', '147', '17');
INSERT INTO collaborateur_equipe VALUES ('148', 'Union sovietique', '3');
INSERT INTO collaborateur_equipe VALUES ('149', 'Union sovietique', '3');
INSERT INTO joueur_equipe VALUES ('141', 'Union sovietique', '3', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('142', 'Union sovietique', '3', 'Arriere latéral', '7', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('143', 'Union sovietique', '3', 'Millieu defensif', '17', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('144', 'Union sovietique', '3', 'Millieu offensif', '26', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('145', 'Union sovietique', '3', 'Gardien de but', '32', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('146', 'Union sovietique', '3', 'Attaquant de pointe', '51', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Tchecoslovaquie', '3', '157', '25');
INSERT INTO collaborateur_equipe VALUES ('158', 'Tchecoslovaquie', '3');
INSERT INTO collaborateur_equipe VALUES ('159', 'Tchecoslovaquie', '3');
INSERT INTO joueur_equipe VALUES ('151', 'Tchecoslovaquie', '3', 'Avant-centre', '1', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('152', 'Tchecoslovaquie', '3', 'Arriere latéral', '10', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('153', 'Tchecoslovaquie', '3', 'Millieu defensif', '12', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('154', 'Tchecoslovaquie', '3', 'Millieu offensif', '25', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('155', 'Tchecoslovaquie', '3', 'Gardien de but', '39', 'France National');
INSERT INTO joueur_equipe VALUES ('156', 'Tchecoslovaquie', '3', 'Attaquant de pointe', '47', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Pologne', '3', '167', '5');
INSERT INTO collaborateur_equipe VALUES ('168', 'Pologne', '3');
INSERT INTO collaborateur_equipe VALUES ('169', 'Pologne', '3');
INSERT INTO joueur_equipe VALUES ('161', 'Pologne', '3', 'Avant-centre', '0', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('162', 'Pologne', '3', 'Arriere latéral', '10', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('163', 'Pologne', '3', 'Millieu defensif', '21', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('164', 'Pologne', '3', 'Millieu offensif', '21', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('165', 'Pologne', '3', 'Gardien de but', '31', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('166', 'Pologne', '3', 'Attaquant de pointe', '33', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Argentine', '3', '177', '12');
INSERT INTO collaborateur_equipe VALUES ('178', 'Argentine', '3');
INSERT INTO collaborateur_equipe VALUES ('179', 'Argentine', '3');
INSERT INTO joueur_equipe VALUES ('171', 'Argentine', '3', 'Avant-centre', '1', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('172', 'Argentine', '3', 'Arriere latéral', '9', 'France National');
INSERT INTO joueur_equipe VALUES ('173', 'Argentine', '3', 'Millieu defensif', '12', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('174', 'Argentine', '3', 'Millieu offensif', '24', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('175', 'Argentine', '3', 'Gardien de but', '40', 'France National');
INSERT INTO joueur_equipe VALUES ('176', 'Argentine', '3', 'Attaquant de pointe', '32', 'AS Monaco');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Belgique', '3', '187', '14');
INSERT INTO collaborateur_equipe VALUES ('188', 'Belgique', '3');
INSERT INTO collaborateur_equipe VALUES ('189', 'Belgique', '3');
INSERT INTO joueur_equipe VALUES ('181', 'Belgique', '3', 'Avant-centre', '0', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('182', 'Belgique', '3', 'Arriere latéral', '7', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('183', 'Belgique', '3', 'Millieu defensif', '21', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('184', 'Belgique', '3', 'Millieu offensif', '26', 'France National');
INSERT INTO joueur_equipe VALUES ('185', 'Belgique', '3', 'Gardien de but', '38', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('186', 'Belgique', '3', 'Attaquant de pointe', '49', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Croatie', '3', '197', '24');
INSERT INTO collaborateur_equipe VALUES ('198', 'Croatie', '3');
INSERT INTO collaborateur_equipe VALUES ('199', 'Croatie', '3');
INSERT INTO joueur_equipe VALUES ('191', 'Croatie', '3', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('192', 'Croatie', '3', 'Arriere latéral', '6', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('193', 'Croatie', '3', 'Millieu defensif', '16', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('194', 'Croatie', '3', 'Millieu offensif', '25', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('195', 'Croatie', '3', 'Gardien de but', '34', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('196', 'Croatie', '3', 'Attaquant de pointe', '33', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Pays-Bas', '3', '207', '10');
INSERT INTO collaborateur_equipe VALUES ('208', 'Pays-Bas', '3');
INSERT INTO collaborateur_equipe VALUES ('209', 'Pays-Bas', '3');
INSERT INTO joueur_equipe VALUES ('201', 'Pays-Bas', '3', 'Avant-centre', '0', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('202', 'Pays-Bas', '3', 'Arriere latéral', '11', 'France National');
INSERT INTO joueur_equipe VALUES ('203', 'Pays-Bas', '3', 'Millieu defensif', '16', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('204', 'Pays-Bas', '3', 'Millieu offensif', '25', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('205', 'Pays-Bas', '3', 'Gardien de but', '29', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('206', 'Pays-Bas', '3', 'Attaquant de pointe', '50', 'Liverpool F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Coree du Sud', '3', '217', '7');
INSERT INTO collaborateur_equipe VALUES ('218', 'Coree du Sud', '3');
INSERT INTO collaborateur_equipe VALUES ('219', 'Coree du Sud', '3');
INSERT INTO joueur_equipe VALUES ('211', 'Coree du Sud', '3', 'Avant-centre', '0', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('212', 'Coree du Sud', '3', 'Arriere latéral', '6', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('213', 'Coree du Sud', '3', 'Millieu defensif', '12', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('214', 'Coree du Sud', '3', 'Millieu offensif', '20', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('215', 'Coree du Sud', '3', 'Gardien de but', '37', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('216', 'Coree du Sud', '3', 'Attaquant de pointe', '44', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Japon', '3', '227', '21');
INSERT INTO collaborateur_equipe VALUES ('228', 'Japon', '3');
INSERT INTO collaborateur_equipe VALUES ('229', 'Japon', '3');
INSERT INTO joueur_equipe VALUES ('221', 'Japon', '3', 'Avant-centre', '1', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('222', 'Japon', '3', 'Arriere latéral', '7', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('223', 'Japon', '3', 'Millieu defensif', '13', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('224', 'Japon', '3', 'Millieu offensif', '23', 'France National');
INSERT INTO joueur_equipe VALUES ('225', 'Japon', '3', 'Gardien de but', '24', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('226', 'Japon', '3', 'Attaquant de pointe', '49', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Russie', '3', '237', '2');
INSERT INTO collaborateur_equipe VALUES ('238', 'Russie', '3');
INSERT INTO collaborateur_equipe VALUES ('239', 'Russie', '3');
INSERT INTO joueur_equipe VALUES ('231', 'Russie', '3', 'Avant-centre', '0', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('232', 'Russie', '3', 'Arriere latéral', '11', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('233', 'Russie', '3', 'Millieu defensif', '16', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('234', 'Russie', '3', 'Millieu offensif', '20', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('235', 'Russie', '3', 'Gardien de but', '33', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('236', 'Russie', '3', 'Attaquant de pointe', '42', 'Manchester United F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Maroque', '3', '247', '28');
INSERT INTO collaborateur_equipe VALUES ('248', 'Maroque', '3');
INSERT INTO collaborateur_equipe VALUES ('249', 'Maroque', '3');
INSERT INTO joueur_equipe VALUES ('241', 'Maroque', '3', 'Avant-centre', '0', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('242', 'Maroque', '3', 'Arriere latéral', '9', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('243', 'Maroque', '3', 'Millieu defensif', '19', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('244', 'Maroque', '3', 'Millieu offensif', '20', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('245', 'Maroque', '3', 'Gardien de but', '25', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('246', 'Maroque', '3', 'Attaquant de pointe', '37', 'AS Monaco');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Egypt', '3', '257', '18');
INSERT INTO collaborateur_equipe VALUES ('258', 'Egypt', '3');
INSERT INTO collaborateur_equipe VALUES ('259', 'Egypt', '3');
INSERT INTO joueur_equipe VALUES ('251', 'Egypt', '3', 'Avant-centre', '0', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('252', 'Egypt', '3', 'Arriere latéral', '6', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('253', 'Egypt', '3', 'Millieu defensif', '12', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('254', 'Egypt', '3', 'Millieu offensif', '21', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('255', 'Egypt', '3', 'Gardien de but', '29', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('256', 'Egypt', '3', 'Attaquant de pointe', '44', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Grece', '3', '267', '20');
INSERT INTO collaborateur_equipe VALUES ('268', 'Grece', '3');
INSERT INTO collaborateur_equipe VALUES ('269', 'Grece', '3');
INSERT INTO joueur_equipe VALUES ('261', 'Grece', '3', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('262', 'Grece', '3', 'Arriere latéral', '8', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('263', 'Grece', '3', 'Millieu defensif', '18', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('264', 'Grece', '3', 'Millieu offensif', '31', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('265', 'Grece', '3', 'Gardien de but', '38', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('266', 'Grece', '3', 'Attaquant de pointe', '32', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Qatar', '3', '277', '29');
INSERT INTO collaborateur_equipe VALUES ('278', 'Qatar', '3');
INSERT INTO collaborateur_equipe VALUES ('279', 'Qatar', '3');
INSERT INTO joueur_equipe VALUES ('271', 'Qatar', '3', 'Avant-centre', '1', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('272', 'Qatar', '3', 'Arriere latéral', '6', 'France National');
INSERT INTO joueur_equipe VALUES ('273', 'Qatar', '3', 'Millieu defensif', '15', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('274', 'Qatar', '3', 'Millieu offensif', '21', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('275', 'Qatar', '3', 'Gardien de but', '26', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('276', 'Qatar', '3', 'Attaquant de pointe', '31', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Etats-Unis', '3', '287', '26');
INSERT INTO collaborateur_equipe VALUES ('288', 'Etats-Unis', '3');
INSERT INTO collaborateur_equipe VALUES ('289', 'Etats-Unis', '3');
INSERT INTO joueur_equipe VALUES ('281', 'Etats-Unis', '3', 'Avant-centre', '0', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('282', 'Etats-Unis', '3', 'Arriere latéral', '11', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('283', 'Etats-Unis', '3', 'Millieu defensif', '17', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('284', 'Etats-Unis', '3', 'Millieu offensif', '20', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('285', 'Etats-Unis', '3', 'Gardien de but', '24', 'France National');
INSERT INTO joueur_equipe VALUES ('286', 'Etats-Unis', '3', 'Attaquant de pointe', '37', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Turquie', '3', '297', '11');
INSERT INTO collaborateur_equipe VALUES ('298', 'Turquie', '3');
INSERT INTO collaborateur_equipe VALUES ('299', 'Turquie', '3');
INSERT INTO joueur_equipe VALUES ('291', 'Turquie', '3', 'Avant-centre', '0', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('292', 'Turquie', '3', 'Arriere latéral', '11', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('293', 'Turquie', '3', 'Millieu defensif', '16', 'France National');
INSERT INTO joueur_equipe VALUES ('294', 'Turquie', '3', 'Millieu offensif', '19', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('295', 'Turquie', '3', 'Gardien de but', '39', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('296', 'Turquie', '3', 'Attaquant de pointe', '41', 'Arsenal F.C.');

 -- Stade -- 
INSERT INTO stade VALUES ('Super Field', 'Croma', '36000', 'France', '1810');

 -- Match -- 

INSERT INTO match_foot VALUES ('2006-06-09', 'France', 'Union sovietique', 'Quart de finale', '2', '3', '3', 'Super Field', 'Croma');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('70', 'France', 'Union sovietique', 'Principal', '2006-06-09');
INSERT INTO arbitre_match VALUES ('130', 'France', 'Union sovietique', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('11', '130', 'France', 'Union sovietique', '2006-06-09', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('16', '130', 'France', 'Union sovietique', '2006-06-09', 'Jaune');
INSERT INTO arbitre_match VALUES ('200', 'France', 'Union sovietique', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('16', '200', 'France', 'Union sovietique', '2006-06-09', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('12', '200', 'France', 'Union sovietique', '2006-06-09', 'Rouge');
INSERT INTO arbitre_match VALUES ('230', 'France', 'Union sovietique', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('13', '230', 'France', 'Union sovietique', '2006-06-09', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('16', '230', 'France', 'Union sovietique', '2006-06-09', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2006-06-09', 'Canada', 'Tchecoslovaquie', 'Finale', '3', '5', '3', 'Super Field', 'Croma');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('60', 'Canada', 'Tchecoslovaquie', 'Principal', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('24', '60', 'Canada', 'Tchecoslovaquie', '2006-06-09', 'Rouge');
INSERT INTO arbitre_match VALUES ('110', 'Canada', 'Tchecoslovaquie', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('22', '110', 'Canada', 'Tchecoslovaquie', '2006-06-09', 'Jaune');
INSERT INTO arbitre_match VALUES ('190', 'Canada', 'Tchecoslovaquie', 'Assistant', '2006-06-09');
INSERT INTO arbitre_match VALUES ('240', 'Canada', 'Tchecoslovaquie', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('23', '240', 'Canada', 'Tchecoslovaquie', '2006-06-09', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('24', '240', 'Canada', 'Tchecoslovaquie', '2006-06-09', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2006-06-09', 'Bresil', 'Pologne', 'Ronde de groupe', '0', '1', '3', 'Super Field', 'Croma');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('80', 'Bresil', 'Pologne', 'Principal', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('31', '80', 'Bresil', 'Pologne', '2006-06-09', 'Rouge');
INSERT INTO arbitre_match VALUES ('120', 'Bresil', 'Pologne', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('36', '120', 'Bresil', 'Pologne', '2006-06-09', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('31', '120', 'Bresil', 'Pologne', '2006-06-09', 'Rouge');
INSERT INTO arbitre_match VALUES ('160', 'Bresil', 'Pologne', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('36', '160', 'Bresil', 'Pologne', '2006-06-09', 'Jaune');
INSERT INTO arbitre_match VALUES ('210', 'Bresil', 'Pologne', 'Assistant', '2006-06-09');

 -- Match -- 

INSERT INTO match_foot VALUES ('2006-06-09', 'Suisse', 'Argentine', 'Ronde de groupe', '0', '2', '3', 'Super Field', 'Croma');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('70', 'Suisse', 'Argentine', 'Principal', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('42', '70', 'Suisse', 'Argentine', '2006-06-09', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('42', '70', 'Suisse', 'Argentine', '2006-06-09', 'Jaune');
INSERT INTO arbitre_match VALUES ('140', 'Suisse', 'Argentine', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('45', '140', 'Suisse', 'Argentine', '2006-06-09', 'Rouge');
INSERT INTO arbitre_match VALUES ('190', 'Suisse', 'Argentine', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('42', '190', 'Suisse', 'Argentine', '2006-06-09', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('46', '190', 'Suisse', 'Argentine', '2006-06-09', 'Jaune');
INSERT INTO arbitre_match VALUES ('210', 'Suisse', 'Argentine', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('41', '210', 'Suisse', 'Argentine', '2006-06-09', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('2006-06-09', 'Suede', 'Belgique', 'Match de 3e place', '3', '5', '3', 'Super Field', 'Croma');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('80', 'Suede', 'Belgique', 'Principal', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('51', '80', 'Suede', 'Belgique', '2006-06-09', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('56', '80', 'Suede', 'Belgique', '2006-06-09', 'Rouge');
INSERT INTO arbitre_match VALUES ('140', 'Suede', 'Belgique', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('53', '140', 'Suede', 'Belgique', '2006-06-09', 'Rouge');
INSERT INTO arbitre_match VALUES ('190', 'Suede', 'Belgique', 'Assistant', '2006-06-09');
INSERT INTO arbitre_match VALUES ('230', 'Suede', 'Belgique', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('51', '230', 'Suede', 'Belgique', '2006-06-09', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2006-06-09', 'Chili', 'Croatie', 'Finale', '4', '1', '3', 'Super Field', 'Croma');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('60', 'Chili', 'Croatie', 'Principal', '2006-06-09');
INSERT INTO arbitre_match VALUES ('110', 'Chili', 'Croatie', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('61', '110', 'Chili', 'Croatie', '2006-06-09', 'Rouge');
INSERT INTO arbitre_match VALUES ('190', 'Chili', 'Croatie', 'Assistant', '2006-06-09');
INSERT INTO arbitre_match VALUES ('220', 'Chili', 'Croatie', 'Assistant', '2006-06-09');

 -- Match -- 

INSERT INTO match_foot VALUES ('2006-06-09', 'Angleterre', 'Pays-Bas', 'Semi-finale', '1', '4', '3', 'Super Field', 'Croma');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Angleterre', 'Pays-Bas', 'Principal', '2006-06-09');
INSERT INTO arbitre_match VALUES ('120', 'Angleterre', 'Pays-Bas', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('72', '120', 'Angleterre', 'Pays-Bas', '2006-06-09', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('76', '120', 'Angleterre', 'Pays-Bas', '2006-06-09', 'Rouge');
INSERT INTO arbitre_match VALUES ('170', 'Angleterre', 'Pays-Bas', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('74', '170', 'Angleterre', 'Pays-Bas', '2006-06-09', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('76', '170', 'Angleterre', 'Pays-Bas', '2006-06-09', 'Rouge');
INSERT INTO arbitre_match VALUES ('240', 'Angleterre', 'Pays-Bas', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('73', '240', 'Angleterre', 'Pays-Bas', '2006-06-09', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2006-06-09', 'Mexique', 'Coree du Sud', 'Semi-finale', '3', '4', '3', 'Super Field', 'Croma');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('60', 'Mexique', 'Coree du Sud', 'Principal', '2006-06-09');
INSERT INTO arbitre_match VALUES ('130', 'Mexique', 'Coree du Sud', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('83', '130', 'Mexique', 'Coree du Sud', '2006-06-09', 'Rouge');
INSERT INTO arbitre_match VALUES ('200', 'Mexique', 'Coree du Sud', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('86', '200', 'Mexique', 'Coree du Sud', '2006-06-09', 'Jaune');
INSERT INTO arbitre_match VALUES ('240', 'Mexique', 'Coree du Sud', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('85', '240', 'Mexique', 'Coree du Sud', '2006-06-09', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('2006-06-09', 'Allemagne', 'Japon', 'Match de 3e place', '2', '3', '3', 'Super Field', 'Croma');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Allemagne', 'Japon', 'Principal', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('93', '90', 'Allemagne', 'Japon', '2006-06-09', 'Jaune');
INSERT INTO arbitre_match VALUES ('130', 'Allemagne', 'Japon', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('95', '130', 'Allemagne', 'Japon', '2006-06-09', 'Rouge');
INSERT INTO arbitre_match VALUES ('170', 'Allemagne', 'Japon', 'Assistant', '2006-06-09');
INSERT INTO arbitre_match VALUES ('230', 'Allemagne', 'Japon', 'Assistant', '2006-06-09');

 -- Match -- 

INSERT INTO match_foot VALUES ('2006-06-09', 'Portugal', 'Russie', 'Ronde de groupe', '1', '0', '3', 'Super Field', 'Croma');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Portugal', 'Russie', 'Principal', '2006-06-09');
INSERT INTO arbitre_match VALUES ('140', 'Portugal', 'Russie', 'Assistant', '2006-06-09');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('103', '140', 'Portugal', 'Russie', '2006-06-09', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('105', '140', 'Portugal', 'Russie', '2006-06-09', 'Jaune');
INSERT INTO arbitre_match VALUES ('180', 'Portugal', 'Russie', 'Assistant', '2006-06-09');
INSERT INTO arbitre_match VALUES ('240', 'Portugal', 'Russie', 'Assistant', '2006-06-09');


  -- Coupe Du Monde  --- 
INSERT INTO coupe_du_monde VALUES ('4', '2010-06-11', '2010-07-11');
INSERT INTO pays_coupe VALUES ('Canada', '4');


 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Uruguay', '4', '7', '9');
INSERT INTO collaborateur_equipe VALUES ('8', 'Uruguay', '4');
INSERT INTO collaborateur_equipe VALUES ('9', 'Uruguay', '4');
INSERT INTO joueur_equipe VALUES ('1', 'Uruguay', '4', 'Avant-centre', '0', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('2', 'Uruguay', '4', 'Arriere latéral', '6', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('3', 'Uruguay', '4', 'Millieu defensif', '19', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('4', 'Uruguay', '4', 'Millieu offensif', '19', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('5', 'Uruguay', '4', 'Gardien de but', '32', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('6', 'Uruguay', '4', 'Attaquant de pointe', '44', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Italie', '4', '17', '4');
INSERT INTO collaborateur_equipe VALUES ('18', 'Italie', '4');
INSERT INTO collaborateur_equipe VALUES ('19', 'Italie', '4');
INSERT INTO joueur_equipe VALUES ('11', 'Italie', '4', 'Avant-centre', '1', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('12', 'Italie', '4', 'Arriere latéral', '9', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('13', 'Italie', '4', 'Millieu defensif', '14', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('14', 'Italie', '4', 'Millieu offensif', '22', 'France National');
INSERT INTO joueur_equipe VALUES ('15', 'Italie', '4', 'Gardien de but', '37', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('16', 'Italie', '4', 'Attaquant de pointe', '30', 'Real Madrid');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('France', '4', '27', '26');
INSERT INTO collaborateur_equipe VALUES ('28', 'France', '4');
INSERT INTO collaborateur_equipe VALUES ('29', 'France', '4');
INSERT INTO joueur_equipe VALUES ('21', 'France', '4', 'Avant-centre', '1', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('22', 'France', '4', 'Arriere latéral', '6', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('23', 'France', '4', 'Millieu defensif', '14', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('24', 'France', '4', 'Millieu offensif', '29', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('25', 'France', '4', 'Gardien de but', '24', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('26', 'France', '4', 'Attaquant de pointe', '50', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Canada', '4', '37', '21');
INSERT INTO collaborateur_equipe VALUES ('38', 'Canada', '4');
INSERT INTO collaborateur_equipe VALUES ('39', 'Canada', '4');
INSERT INTO joueur_equipe VALUES ('31', 'Canada', '4', 'Avant-centre', '1', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('32', 'Canada', '4', 'Arriere latéral', '8', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('33', 'Canada', '4', 'Millieu defensif', '15', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('34', 'Canada', '4', 'Millieu offensif', '29', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('35', 'Canada', '4', 'Gardien de but', '33', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('36', 'Canada', '4', 'Attaquant de pointe', '30', 'Real Madrid');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Bresil', '4', '47', '20');
INSERT INTO collaborateur_equipe VALUES ('48', 'Bresil', '4');
INSERT INTO collaborateur_equipe VALUES ('49', 'Bresil', '4');
INSERT INTO joueur_equipe VALUES ('41', 'Bresil', '4', 'Avant-centre', '0', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('42', 'Bresil', '4', 'Arriere latéral', '10', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('43', 'Bresil', '4', 'Millieu defensif', '14', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('44', 'Bresil', '4', 'Millieu offensif', '29', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('45', 'Bresil', '4', 'Gardien de but', '27', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('46', 'Bresil', '4', 'Attaquant de pointe', '38', 'Brazil nationnal');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Suisse', '4', '57', '13');
INSERT INTO collaborateur_equipe VALUES ('58', 'Suisse', '4');
INSERT INTO collaborateur_equipe VALUES ('59', 'Suisse', '4');
INSERT INTO joueur_equipe VALUES ('51', 'Suisse', '4', 'Avant-centre', '1', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('52', 'Suisse', '4', 'Arriere latéral', '7', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('53', 'Suisse', '4', 'Millieu defensif', '19', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('54', 'Suisse', '4', 'Millieu offensif', '24', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('55', 'Suisse', '4', 'Gardien de but', '37', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('56', 'Suisse', '4', 'Attaquant de pointe', '43', 'Brazil nationnal');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Suede', '4', '67', '6');
INSERT INTO collaborateur_equipe VALUES ('68', 'Suede', '4');
INSERT INTO collaborateur_equipe VALUES ('69', 'Suede', '4');
INSERT INTO joueur_equipe VALUES ('61', 'Suede', '4', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('62', 'Suede', '4', 'Arriere latéral', '6', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('63', 'Suede', '4', 'Millieu defensif', '18', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('64', 'Suede', '4', 'Millieu offensif', '28', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('65', 'Suede', '4', 'Gardien de but', '33', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('66', 'Suede', '4', 'Attaquant de pointe', '44', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Chili', '4', '77', '23');
INSERT INTO collaborateur_equipe VALUES ('78', 'Chili', '4');
INSERT INTO collaborateur_equipe VALUES ('79', 'Chili', '4');
INSERT INTO joueur_equipe VALUES ('71', 'Chili', '4', 'Avant-centre', '1', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('72', 'Chili', '4', 'Arriere latéral', '9', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('73', 'Chili', '4', 'Millieu defensif', '16', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('74', 'Chili', '4', 'Millieu offensif', '23', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('75', 'Chili', '4', 'Gardien de but', '34', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('76', 'Chili', '4', 'Attaquant de pointe', '37', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Angleterre', '4', '87', '12');
INSERT INTO collaborateur_equipe VALUES ('88', 'Angleterre', '4');
INSERT INTO collaborateur_equipe VALUES ('89', 'Angleterre', '4');
INSERT INTO joueur_equipe VALUES ('81', 'Angleterre', '4', 'Avant-centre', '0', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('82', 'Angleterre', '4', 'Arriere latéral', '7', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('83', 'Angleterre', '4', 'Millieu defensif', '15', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('84', 'Angleterre', '4', 'Millieu offensif', '23', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('85', 'Angleterre', '4', 'Gardien de but', '33', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('86', 'Angleterre', '4', 'Attaquant de pointe', '45', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Mexique', '4', '97', '25');
INSERT INTO collaborateur_equipe VALUES ('98', 'Mexique', '4');
INSERT INTO collaborateur_equipe VALUES ('99', 'Mexique', '4');
INSERT INTO joueur_equipe VALUES ('91', 'Mexique', '4', 'Avant-centre', '0', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('92', 'Mexique', '4', 'Arriere latéral', '10', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('93', 'Mexique', '4', 'Millieu defensif', '13', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('94', 'Mexique', '4', 'Millieu offensif', '30', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('95', 'Mexique', '4', 'Gardien de but', '37', 'France National');
INSERT INTO joueur_equipe VALUES ('96', 'Mexique', '4', 'Attaquant de pointe', '38', 'AS Monaco');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Allemagne', '4', '107', '29');
INSERT INTO collaborateur_equipe VALUES ('108', 'Allemagne', '4');
INSERT INTO collaborateur_equipe VALUES ('109', 'Allemagne', '4');
INSERT INTO joueur_equipe VALUES ('101', 'Allemagne', '4', 'Avant-centre', '1', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('102', 'Allemagne', '4', 'Arriere latéral', '10', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('103', 'Allemagne', '4', 'Millieu defensif', '15', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('104', 'Allemagne', '4', 'Millieu offensif', '18', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('105', 'Allemagne', '4', 'Gardien de but', '33', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('106', 'Allemagne', '4', 'Attaquant de pointe', '48', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Portugal', '4', '117', '27');
INSERT INTO collaborateur_equipe VALUES ('118', 'Portugal', '4');
INSERT INTO collaborateur_equipe VALUES ('119', 'Portugal', '4');
INSERT INTO joueur_equipe VALUES ('111', 'Portugal', '4', 'Avant-centre', '1', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('112', 'Portugal', '4', 'Arriere latéral', '8', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('113', 'Portugal', '4', 'Millieu defensif', '19', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('114', 'Portugal', '4', 'Millieu offensif', '19', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('115', 'Portugal', '4', 'Gardien de but', '38', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('116', 'Portugal', '4', 'Attaquant de pointe', '39', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Autriche', '4', '127', '14');
INSERT INTO collaborateur_equipe VALUES ('128', 'Autriche', '4');
INSERT INTO collaborateur_equipe VALUES ('129', 'Autriche', '4');
INSERT INTO joueur_equipe VALUES ('121', 'Autriche', '4', 'Avant-centre', '0', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('122', 'Autriche', '4', 'Arriere latéral', '8', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('123', 'Autriche', '4', 'Millieu defensif', '18', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('124', 'Autriche', '4', 'Millieu offensif', '29', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('125', 'Autriche', '4', 'Gardien de but', '24', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('126', 'Autriche', '4', 'Attaquant de pointe', '48', 'Real Madrid');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Yougoslavie', '4', '137', '2');
INSERT INTO collaborateur_equipe VALUES ('138', 'Yougoslavie', '4');
INSERT INTO collaborateur_equipe VALUES ('139', 'Yougoslavie', '4');
INSERT INTO joueur_equipe VALUES ('131', 'Yougoslavie', '4', 'Avant-centre', '1', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('132', 'Yougoslavie', '4', 'Arriere latéral', '7', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('133', 'Yougoslavie', '4', 'Millieu defensif', '19', 'France National');
INSERT INTO joueur_equipe VALUES ('134', 'Yougoslavie', '4', 'Millieu offensif', '29', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('135', 'Yougoslavie', '4', 'Gardien de but', '26', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('136', 'Yougoslavie', '4', 'Attaquant de pointe', '33', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Union sovietique', '4', '147', '5');
INSERT INTO collaborateur_equipe VALUES ('148', 'Union sovietique', '4');
INSERT INTO collaborateur_equipe VALUES ('149', 'Union sovietique', '4');
INSERT INTO joueur_equipe VALUES ('141', 'Union sovietique', '4', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('142', 'Union sovietique', '4', 'Arriere latéral', '7', 'France National');
INSERT INTO joueur_equipe VALUES ('143', 'Union sovietique', '4', 'Millieu defensif', '20', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('144', 'Union sovietique', '4', 'Millieu offensif', '18', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('145', 'Union sovietique', '4', 'Gardien de but', '36', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('146', 'Union sovietique', '4', 'Attaquant de pointe', '36', 'Spain N.F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Tchecoslovaquie', '4', '157', '17');
INSERT INTO collaborateur_equipe VALUES ('158', 'Tchecoslovaquie', '4');
INSERT INTO collaborateur_equipe VALUES ('159', 'Tchecoslovaquie', '4');
INSERT INTO joueur_equipe VALUES ('151', 'Tchecoslovaquie', '4', 'Avant-centre', '0', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('152', 'Tchecoslovaquie', '4', 'Arriere latéral', '8', 'France National');
INSERT INTO joueur_equipe VALUES ('153', 'Tchecoslovaquie', '4', 'Millieu defensif', '19', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('154', 'Tchecoslovaquie', '4', 'Millieu offensif', '28', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('155', 'Tchecoslovaquie', '4', 'Gardien de but', '30', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('156', 'Tchecoslovaquie', '4', 'Attaquant de pointe', '40', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Pologne', '4', '167', '18');
INSERT INTO collaborateur_equipe VALUES ('168', 'Pologne', '4');
INSERT INTO collaborateur_equipe VALUES ('169', 'Pologne', '4');
INSERT INTO joueur_equipe VALUES ('161', 'Pologne', '4', 'Avant-centre', '1', 'France National');
INSERT INTO joueur_equipe VALUES ('162', 'Pologne', '4', 'Arriere latéral', '7', 'France National');
INSERT INTO joueur_equipe VALUES ('163', 'Pologne', '4', 'Millieu defensif', '17', 'France National');
INSERT INTO joueur_equipe VALUES ('164', 'Pologne', '4', 'Millieu offensif', '28', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('165', 'Pologne', '4', 'Gardien de but', '35', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('166', 'Pologne', '4', 'Attaquant de pointe', '39', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Argentine', '4', '177', '22');
INSERT INTO collaborateur_equipe VALUES ('178', 'Argentine', '4');
INSERT INTO collaborateur_equipe VALUES ('179', 'Argentine', '4');
INSERT INTO joueur_equipe VALUES ('171', 'Argentine', '4', 'Avant-centre', '0', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('172', 'Argentine', '4', 'Arriere latéral', '11', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('173', 'Argentine', '4', 'Millieu defensif', '19', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('174', 'Argentine', '4', 'Millieu offensif', '28', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('175', 'Argentine', '4', 'Gardien de but', '26', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('176', 'Argentine', '4', 'Attaquant de pointe', '47', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Belgique', '4', '187', '8');
INSERT INTO collaborateur_equipe VALUES ('188', 'Belgique', '4');
INSERT INTO collaborateur_equipe VALUES ('189', 'Belgique', '4');
INSERT INTO joueur_equipe VALUES ('181', 'Belgique', '4', 'Avant-centre', '1', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('182', 'Belgique', '4', 'Arriere latéral', '6', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('183', 'Belgique', '4', 'Millieu defensif', '12', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('184', 'Belgique', '4', 'Millieu offensif', '29', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('185', 'Belgique', '4', 'Gardien de but', '40', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('186', 'Belgique', '4', 'Attaquant de pointe', '31', 'Real Madrid');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Croatie', '4', '197', '30');
INSERT INTO collaborateur_equipe VALUES ('198', 'Croatie', '4');
INSERT INTO collaborateur_equipe VALUES ('199', 'Croatie', '4');
INSERT INTO joueur_equipe VALUES ('191', 'Croatie', '4', 'Avant-centre', '0', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('192', 'Croatie', '4', 'Arriere latéral', '9', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('193', 'Croatie', '4', 'Millieu defensif', '18', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('194', 'Croatie', '4', 'Millieu offensif', '24', 'France National');
INSERT INTO joueur_equipe VALUES ('195', 'Croatie', '4', 'Gardien de but', '35', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('196', 'Croatie', '4', 'Attaquant de pointe', '32', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Pays-Bas', '4', '207', '16');
INSERT INTO collaborateur_equipe VALUES ('208', 'Pays-Bas', '4');
INSERT INTO collaborateur_equipe VALUES ('209', 'Pays-Bas', '4');
INSERT INTO joueur_equipe VALUES ('201', 'Pays-Bas', '4', 'Avant-centre', '1', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('202', 'Pays-Bas', '4', 'Arriere latéral', '10', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('203', 'Pays-Bas', '4', 'Millieu defensif', '15', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('204', 'Pays-Bas', '4', 'Millieu offensif', '31', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('205', 'Pays-Bas', '4', 'Gardien de but', '35', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('206', 'Pays-Bas', '4', 'Attaquant de pointe', '50', 'Spain N.F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Coree du Sud', '4', '217', '19');
INSERT INTO collaborateur_equipe VALUES ('218', 'Coree du Sud', '4');
INSERT INTO collaborateur_equipe VALUES ('219', 'Coree du Sud', '4');
INSERT INTO joueur_equipe VALUES ('211', 'Coree du Sud', '4', 'Avant-centre', '1', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('212', 'Coree du Sud', '4', 'Arriere latéral', '11', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('213', 'Coree du Sud', '4', 'Millieu defensif', '15', 'France National');
INSERT INTO joueur_equipe VALUES ('214', 'Coree du Sud', '4', 'Millieu offensif', '27', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('215', 'Coree du Sud', '4', 'Gardien de but', '41', 'France National');
INSERT INTO joueur_equipe VALUES ('216', 'Coree du Sud', '4', 'Attaquant de pointe', '30', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Japon', '4', '227', '24');
INSERT INTO collaborateur_equipe VALUES ('228', 'Japon', '4');
INSERT INTO collaborateur_equipe VALUES ('229', 'Japon', '4');
INSERT INTO joueur_equipe VALUES ('221', 'Japon', '4', 'Avant-centre', '1', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('222', 'Japon', '4', 'Arriere latéral', '11', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('223', 'Japon', '4', 'Millieu defensif', '18', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('224', 'Japon', '4', 'Millieu offensif', '24', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('225', 'Japon', '4', 'Gardien de but', '26', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('226', 'Japon', '4', 'Attaquant de pointe', '44', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Russie', '4', '237', '1');
INSERT INTO collaborateur_equipe VALUES ('238', 'Russie', '4');
INSERT INTO collaborateur_equipe VALUES ('239', 'Russie', '4');
INSERT INTO joueur_equipe VALUES ('231', 'Russie', '4', 'Avant-centre', '1', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('232', 'Russie', '4', 'Arriere latéral', '7', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('233', 'Russie', '4', 'Millieu defensif', '15', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('234', 'Russie', '4', 'Millieu offensif', '24', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('235', 'Russie', '4', 'Gardien de but', '28', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('236', 'Russie', '4', 'Attaquant de pointe', '34', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Maroque', '4', '247', '7');
INSERT INTO collaborateur_equipe VALUES ('248', 'Maroque', '4');
INSERT INTO collaborateur_equipe VALUES ('249', 'Maroque', '4');
INSERT INTO joueur_equipe VALUES ('241', 'Maroque', '4', 'Avant-centre', '1', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('242', 'Maroque', '4', 'Arriere latéral', '8', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('243', 'Maroque', '4', 'Millieu defensif', '14', 'France National');
INSERT INTO joueur_equipe VALUES ('244', 'Maroque', '4', 'Millieu offensif', '28', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('245', 'Maroque', '4', 'Gardien de but', '38', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('246', 'Maroque', '4', 'Attaquant de pointe', '47', 'Spain N.F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Egypt', '4', '257', '10');
INSERT INTO collaborateur_equipe VALUES ('258', 'Egypt', '4');
INSERT INTO collaborateur_equipe VALUES ('259', 'Egypt', '4');
INSERT INTO joueur_equipe VALUES ('251', 'Egypt', '4', 'Avant-centre', '0', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('252', 'Egypt', '4', 'Arriere latéral', '8', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('253', 'Egypt', '4', 'Millieu defensif', '15', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('254', 'Egypt', '4', 'Millieu offensif', '31', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('255', 'Egypt', '4', 'Gardien de but', '39', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('256', 'Egypt', '4', 'Attaquant de pointe', '33', 'Manchester United F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Grece', '4', '267', '28');
INSERT INTO collaborateur_equipe VALUES ('268', 'Grece', '4');
INSERT INTO collaborateur_equipe VALUES ('269', 'Grece', '4');
INSERT INTO joueur_equipe VALUES ('261', 'Grece', '4', 'Avant-centre', '0', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('262', 'Grece', '4', 'Arriere latéral', '11', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('263', 'Grece', '4', 'Millieu defensif', '15', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('264', 'Grece', '4', 'Millieu offensif', '22', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('265', 'Grece', '4', 'Gardien de but', '37', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('266', 'Grece', '4', 'Attaquant de pointe', '49', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Qatar', '4', '277', '15');
INSERT INTO collaborateur_equipe VALUES ('278', 'Qatar', '4');
INSERT INTO collaborateur_equipe VALUES ('279', 'Qatar', '4');
INSERT INTO joueur_equipe VALUES ('271', 'Qatar', '4', 'Avant-centre', '0', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('272', 'Qatar', '4', 'Arriere latéral', '6', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('273', 'Qatar', '4', 'Millieu defensif', '17', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('274', 'Qatar', '4', 'Millieu offensif', '22', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('275', 'Qatar', '4', 'Gardien de but', '28', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('276', 'Qatar', '4', 'Attaquant de pointe', '49', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Etats-Unis', '4', '287', '3');
INSERT INTO collaborateur_equipe VALUES ('288', 'Etats-Unis', '4');
INSERT INTO collaborateur_equipe VALUES ('289', 'Etats-Unis', '4');
INSERT INTO joueur_equipe VALUES ('281', 'Etats-Unis', '4', 'Avant-centre', '1', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('282', 'Etats-Unis', '4', 'Arriere latéral', '11', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('283', 'Etats-Unis', '4', 'Millieu defensif', '12', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('284', 'Etats-Unis', '4', 'Millieu offensif', '25', 'France National');
INSERT INTO joueur_equipe VALUES ('285', 'Etats-Unis', '4', 'Gardien de but', '31', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('286', 'Etats-Unis', '4', 'Attaquant de pointe', '49', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Turquie', '4', '297', '11');
INSERT INTO collaborateur_equipe VALUES ('298', 'Turquie', '4');
INSERT INTO collaborateur_equipe VALUES ('299', 'Turquie', '4');
INSERT INTO joueur_equipe VALUES ('291', 'Turquie', '4', 'Avant-centre', '0', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('292', 'Turquie', '4', 'Arriere latéral', '9', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('293', 'Turquie', '4', 'Millieu defensif', '19', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('294', 'Turquie', '4', 'Millieu offensif', '20', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('295', 'Turquie', '4', 'Gardien de but', '32', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('296', 'Turquie', '4', 'Attaquant de pointe', '47', 'FC Bayern');

 -- Stade -- 
INSERT INTO stade VALUES ('Fern field', 'Bobski', '44000', 'Canada', '1514');

 -- Match -- 

INSERT INTO match_foot VALUES ('2010-06-11', 'Canada', 'Pologne', 'Match de 3e place', '0', '1', '4', 'Fern field', 'Bobski');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('70', 'Canada', 'Pologne', 'Principal', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('12', '70', 'Canada', 'Pologne', '2010-06-11', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('11', '70', 'Canada', 'Pologne', '2010-06-11', 'Rouge');
INSERT INTO arbitre_match VALUES ('150', 'Canada', 'Pologne', 'Assistant', '2010-06-11');
INSERT INTO arbitre_match VALUES ('180', 'Canada', 'Pologne', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('11', '180', 'Canada', 'Pologne', '2010-06-11', 'Jaune');
INSERT INTO arbitre_match VALUES ('250', 'Canada', 'Pologne', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('12', '250', 'Canada', 'Pologne', '2010-06-11', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2010-06-11', 'Bresil', 'Argentine', 'Ronde de groupe', '4', '3', '4', 'Fern field', 'Bobski');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('100', 'Bresil', 'Argentine', 'Principal', '2010-06-11');
INSERT INTO arbitre_match VALUES ('130', 'Bresil', 'Argentine', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('23', '130', 'Bresil', 'Argentine', '2010-06-11', 'Rouge');
INSERT INTO arbitre_match VALUES ('190', 'Bresil', 'Argentine', 'Assistant', '2010-06-11');
INSERT INTO arbitre_match VALUES ('230', 'Bresil', 'Argentine', 'Assistant', '2010-06-11');

 -- Match -- 

INSERT INTO match_foot VALUES ('2010-06-11', 'Suisse', 'Belgique', 'Ronde de 16', '2', '0', '4', 'Fern field', 'Bobski');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('70', 'Suisse', 'Belgique', 'Principal', '2010-06-11');
INSERT INTO arbitre_match VALUES ('150', 'Suisse', 'Belgique', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('35', '150', 'Suisse', 'Belgique', '2010-06-11', 'Jaune');
INSERT INTO arbitre_match VALUES ('180', 'Suisse', 'Belgique', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('31', '180', 'Suisse', 'Belgique', '2010-06-11', 'Rouge');
INSERT INTO arbitre_match VALUES ('210', 'Suisse', 'Belgique', 'Assistant', '2010-06-11');

 -- Match -- 

INSERT INTO match_foot VALUES ('2010-06-11', 'Suede', 'Croatie', 'Semi-finale', '5', '2', '4', 'Fern field', 'Bobski');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('80', 'Suede', 'Croatie', 'Principal', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('46', '80', 'Suede', 'Croatie', '2010-06-11', 'Jaune');
INSERT INTO arbitre_match VALUES ('140', 'Suede', 'Croatie', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('46', '140', 'Suede', 'Croatie', '2010-06-11', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('45', '140', 'Suede', 'Croatie', '2010-06-11', 'Rouge');
INSERT INTO arbitre_match VALUES ('200', 'Suede', 'Croatie', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('46', '200', 'Suede', 'Croatie', '2010-06-11', 'Jaune');
INSERT INTO arbitre_match VALUES ('230', 'Suede', 'Croatie', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('43', '230', 'Suede', 'Croatie', '2010-06-11', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('42', '230', 'Suede', 'Croatie', '2010-06-11', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('2010-06-11', 'Chili', 'Pays-Bas', 'Ronde de 16', '2', '0', '4', 'Fern field', 'Bobski');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('80', 'Chili', 'Pays-Bas', 'Principal', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('56', '80', 'Chili', 'Pays-Bas', '2010-06-11', 'Rouge');
INSERT INTO arbitre_match VALUES ('120', 'Chili', 'Pays-Bas', 'Assistant', '2010-06-11');
INSERT INTO arbitre_match VALUES ('180', 'Chili', 'Pays-Bas', 'Assistant', '2010-06-11');
INSERT INTO arbitre_match VALUES ('210', 'Chili', 'Pays-Bas', 'Assistant', '2010-06-11');

 -- Match -- 

INSERT INTO match_foot VALUES ('2010-06-11', 'Angleterre', 'Coree du Sud', 'Ronde de 16', '5', '3', '4', 'Fern field', 'Bobski');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('70', 'Angleterre', 'Coree du Sud', 'Principal', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('66', '70', 'Angleterre', 'Coree du Sud', '2010-06-11', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('66', '70', 'Angleterre', 'Coree du Sud', '2010-06-11', 'Rouge');
INSERT INTO arbitre_match VALUES ('150', 'Angleterre', 'Coree du Sud', 'Assistant', '2010-06-11');
INSERT INTO arbitre_match VALUES ('190', 'Angleterre', 'Coree du Sud', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('63', '190', 'Angleterre', 'Coree du Sud', '2010-06-11', 'Jaune');
INSERT INTO arbitre_match VALUES ('230', 'Angleterre', 'Coree du Sud', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('62', '230', 'Angleterre', 'Coree du Sud', '2010-06-11', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('64', '230', 'Angleterre', 'Coree du Sud', '2010-06-11', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2010-06-11', 'Mexique', 'Japon', 'Ronde de groupe', '1', '0', '4', 'Fern field', 'Bobski');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Mexique', 'Japon', 'Principal', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('75', '90', 'Mexique', 'Japon', '2010-06-11', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('75', '90', 'Mexique', 'Japon', '2010-06-11', 'Rouge');
INSERT INTO arbitre_match VALUES ('150', 'Mexique', 'Japon', 'Assistant', '2010-06-11');
INSERT INTO arbitre_match VALUES ('160', 'Mexique', 'Japon', 'Assistant', '2010-06-11');
INSERT INTO arbitre_match VALUES ('220', 'Mexique', 'Japon', 'Assistant', '2010-06-11');

 -- Match -- 

INSERT INTO match_foot VALUES ('2010-06-11', 'Allemagne', 'Russie', 'Ronde de 16', '0', '1', '4', 'Fern field', 'Bobski');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('80', 'Allemagne', 'Russie', 'Principal', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('82', '80', 'Allemagne', 'Russie', '2010-06-11', 'Jaune');
INSERT INTO arbitre_match VALUES ('120', 'Allemagne', 'Russie', 'Assistant', '2010-06-11');
INSERT INTO arbitre_match VALUES ('190', 'Allemagne', 'Russie', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('83', '190', 'Allemagne', 'Russie', '2010-06-11', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('84', '190', 'Allemagne', 'Russie', '2010-06-11', 'Rouge');
INSERT INTO arbitre_match VALUES ('250', 'Allemagne', 'Russie', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('81', '250', 'Allemagne', 'Russie', '2010-06-11', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('84', '250', 'Allemagne', 'Russie', '2010-06-11', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2010-06-11', 'Portugal', 'Maroque', 'Semi-finale', '0', '3', '4', 'Fern field', 'Bobski');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('60', 'Portugal', 'Maroque', 'Principal', '2010-06-11');
INSERT INTO arbitre_match VALUES ('130', 'Portugal', 'Maroque', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('94', '130', 'Portugal', 'Maroque', '2010-06-11', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('95', '130', 'Portugal', 'Maroque', '2010-06-11', 'Rouge');
INSERT INTO arbitre_match VALUES ('180', 'Portugal', 'Maroque', 'Assistant', '2010-06-11');
INSERT INTO arbitre_match VALUES ('240', 'Portugal', 'Maroque', 'Assistant', '2010-06-11');

 -- Match -- 

INSERT INTO match_foot VALUES ('2010-06-11', 'Autriche', 'Egypt', 'Finale', '5', '4', '4', 'Fern field', 'Bobski');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('70', 'Autriche', 'Egypt', 'Principal', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('104', '70', 'Autriche', 'Egypt', '2010-06-11', 'Rouge');
INSERT INTO arbitre_match VALUES ('150', 'Autriche', 'Egypt', 'Assistant', '2010-06-11');
INSERT INTO arbitre_match VALUES ('170', 'Autriche', 'Egypt', 'Assistant', '2010-06-11');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('101', '170', 'Autriche', 'Egypt', '2010-06-11', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('104', '170', 'Autriche', 'Egypt', '2010-06-11', 'Jaune');
INSERT INTO arbitre_match VALUES ('240', 'Autriche', 'Egypt', 'Assistant', '2010-06-11');


  -- Coupe Du Monde  --- 
INSERT INTO coupe_du_monde VALUES ('5', '2014-06-12', '2014-07-13');
INSERT INTO pays_coupe VALUES ('Bresil', '5');


 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Uruguay', '5', '7', '4');
INSERT INTO collaborateur_equipe VALUES ('8', 'Uruguay', '5');
INSERT INTO collaborateur_equipe VALUES ('9', 'Uruguay', '5');
INSERT INTO joueur_equipe VALUES ('1', 'Uruguay', '5', 'Avant-centre', '0', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('2', 'Uruguay', '5', 'Arriere latéral', '9', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('3', 'Uruguay', '5', 'Millieu defensif', '16', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('4', 'Uruguay', '5', 'Millieu offensif', '31', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('5', 'Uruguay', '5', 'Gardien de but', '27', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('6', 'Uruguay', '5', 'Attaquant de pointe', '32', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Italie', '5', '17', '7');
INSERT INTO collaborateur_equipe VALUES ('18', 'Italie', '5');
INSERT INTO collaborateur_equipe VALUES ('19', 'Italie', '5');
INSERT INTO joueur_equipe VALUES ('11', 'Italie', '5', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('12', 'Italie', '5', 'Arriere latéral', '9', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('13', 'Italie', '5', 'Millieu defensif', '18', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('14', 'Italie', '5', 'Millieu offensif', '21', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('15', 'Italie', '5', 'Gardien de but', '32', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('16', 'Italie', '5', 'Attaquant de pointe', '44', 'Manchester United F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('France', '5', '27', '10');
INSERT INTO collaborateur_equipe VALUES ('28', 'France', '5');
INSERT INTO collaborateur_equipe VALUES ('29', 'France', '5');
INSERT INTO joueur_equipe VALUES ('21', 'France', '5', 'Avant-centre', '0', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('22', 'France', '5', 'Arriere latéral', '8', 'France National');
INSERT INTO joueur_equipe VALUES ('23', 'France', '5', 'Millieu defensif', '12', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('24', 'France', '5', 'Millieu offensif', '22', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('25', 'France', '5', 'Gardien de but', '25', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('26', 'France', '5', 'Attaquant de pointe', '46', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Canada', '5', '37', '12');
INSERT INTO collaborateur_equipe VALUES ('38', 'Canada', '5');
INSERT INTO collaborateur_equipe VALUES ('39', 'Canada', '5');
INSERT INTO joueur_equipe VALUES ('31', 'Canada', '5', 'Avant-centre', '1', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('32', 'Canada', '5', 'Arriere latéral', '10', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('33', 'Canada', '5', 'Millieu defensif', '19', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('34', 'Canada', '5', 'Millieu offensif', '29', 'France National');
INSERT INTO joueur_equipe VALUES ('35', 'Canada', '5', 'Gardien de but', '30', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('36', 'Canada', '5', 'Attaquant de pointe', '35', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Bresil', '5', '47', '14');
INSERT INTO collaborateur_equipe VALUES ('48', 'Bresil', '5');
INSERT INTO collaborateur_equipe VALUES ('49', 'Bresil', '5');
INSERT INTO joueur_equipe VALUES ('41', 'Bresil', '5', 'Avant-centre', '1', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('42', 'Bresil', '5', 'Arriere latéral', '6', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('43', 'Bresil', '5', 'Millieu defensif', '20', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('44', 'Bresil', '5', 'Millieu offensif', '30', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('45', 'Bresil', '5', 'Gardien de but', '41', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('46', 'Bresil', '5', 'Attaquant de pointe', '38', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Suisse', '5', '57', '16');
INSERT INTO collaborateur_equipe VALUES ('58', 'Suisse', '5');
INSERT INTO collaborateur_equipe VALUES ('59', 'Suisse', '5');
INSERT INTO joueur_equipe VALUES ('51', 'Suisse', '5', 'Avant-centre', '0', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('52', 'Suisse', '5', 'Arriere latéral', '10', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('53', 'Suisse', '5', 'Millieu defensif', '18', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('54', 'Suisse', '5', 'Millieu offensif', '22', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('55', 'Suisse', '5', 'Gardien de but', '29', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('56', 'Suisse', '5', 'Attaquant de pointe', '40', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Suede', '5', '67', '11');
INSERT INTO collaborateur_equipe VALUES ('68', 'Suede', '5');
INSERT INTO collaborateur_equipe VALUES ('69', 'Suede', '5');
INSERT INTO joueur_equipe VALUES ('61', 'Suede', '5', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('62', 'Suede', '5', 'Arriere latéral', '9', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('63', 'Suede', '5', 'Millieu defensif', '14', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('64', 'Suede', '5', 'Millieu offensif', '19', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('65', 'Suede', '5', 'Gardien de but', '25', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('66', 'Suede', '5', 'Attaquant de pointe', '33', 'Brazil nationnal');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Chili', '5', '77', '26');
INSERT INTO collaborateur_equipe VALUES ('78', 'Chili', '5');
INSERT INTO collaborateur_equipe VALUES ('79', 'Chili', '5');
INSERT INTO joueur_equipe VALUES ('71', 'Chili', '5', 'Avant-centre', '1', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('72', 'Chili', '5', 'Arriere latéral', '10', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('73', 'Chili', '5', 'Millieu defensif', '15', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('74', 'Chili', '5', 'Millieu offensif', '23', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('75', 'Chili', '5', 'Gardien de but', '31', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('76', 'Chili', '5', 'Attaquant de pointe', '36', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Angleterre', '5', '87', '18');
INSERT INTO collaborateur_equipe VALUES ('88', 'Angleterre', '5');
INSERT INTO collaborateur_equipe VALUES ('89', 'Angleterre', '5');
INSERT INTO joueur_equipe VALUES ('81', 'Angleterre', '5', 'Avant-centre', '0', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('82', 'Angleterre', '5', 'Arriere latéral', '7', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('83', 'Angleterre', '5', 'Millieu defensif', '13', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('84', 'Angleterre', '5', 'Millieu offensif', '27', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('85', 'Angleterre', '5', 'Gardien de but', '32', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('86', 'Angleterre', '5', 'Attaquant de pointe', '30', 'Brazil nationnal');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Mexique', '5', '97', '29');
INSERT INTO collaborateur_equipe VALUES ('98', 'Mexique', '5');
INSERT INTO collaborateur_equipe VALUES ('99', 'Mexique', '5');
INSERT INTO joueur_equipe VALUES ('91', 'Mexique', '5', 'Avant-centre', '1', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('92', 'Mexique', '5', 'Arriere latéral', '11', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('93', 'Mexique', '5', 'Millieu defensif', '13', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('94', 'Mexique', '5', 'Millieu offensif', '24', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('95', 'Mexique', '5', 'Gardien de but', '36', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('96', 'Mexique', '5', 'Attaquant de pointe', '48', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Allemagne', '5', '107', '28');
INSERT INTO collaborateur_equipe VALUES ('108', 'Allemagne', '5');
INSERT INTO collaborateur_equipe VALUES ('109', 'Allemagne', '5');
INSERT INTO joueur_equipe VALUES ('101', 'Allemagne', '5', 'Avant-centre', '0', 'France National');
INSERT INTO joueur_equipe VALUES ('102', 'Allemagne', '5', 'Arriere latéral', '6', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('103', 'Allemagne', '5', 'Millieu defensif', '15', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('104', 'Allemagne', '5', 'Millieu offensif', '19', 'France National');
INSERT INTO joueur_equipe VALUES ('105', 'Allemagne', '5', 'Gardien de but', '37', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('106', 'Allemagne', '5', 'Attaquant de pointe', '42', 'Liverpool F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Portugal', '5', '117', '6');
INSERT INTO collaborateur_equipe VALUES ('118', 'Portugal', '5');
INSERT INTO collaborateur_equipe VALUES ('119', 'Portugal', '5');
INSERT INTO joueur_equipe VALUES ('111', 'Portugal', '5', 'Avant-centre', '1', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('112', 'Portugal', '5', 'Arriere latéral', '8', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('113', 'Portugal', '5', 'Millieu defensif', '21', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('114', 'Portugal', '5', 'Millieu offensif', '28', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('115', 'Portugal', '5', 'Gardien de but', '35', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('116', 'Portugal', '5', 'Attaquant de pointe', '32', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Autriche', '5', '127', '21');
INSERT INTO collaborateur_equipe VALUES ('128', 'Autriche', '5');
INSERT INTO collaborateur_equipe VALUES ('129', 'Autriche', '5');
INSERT INTO joueur_equipe VALUES ('121', 'Autriche', '5', 'Avant-centre', '1', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('122', 'Autriche', '5', 'Arriere latéral', '10', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('123', 'Autriche', '5', 'Millieu defensif', '20', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('124', 'Autriche', '5', 'Millieu offensif', '18', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('125', 'Autriche', '5', 'Gardien de but', '25', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('126', 'Autriche', '5', 'Attaquant de pointe', '32', 'Liverpool F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Yougoslavie', '5', '137', '22');
INSERT INTO collaborateur_equipe VALUES ('138', 'Yougoslavie', '5');
INSERT INTO collaborateur_equipe VALUES ('139', 'Yougoslavie', '5');
INSERT INTO joueur_equipe VALUES ('131', 'Yougoslavie', '5', 'Avant-centre', '1', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('132', 'Yougoslavie', '5', 'Arriere latéral', '6', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('133', 'Yougoslavie', '5', 'Millieu defensif', '18', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('134', 'Yougoslavie', '5', 'Millieu offensif', '29', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('135', 'Yougoslavie', '5', 'Gardien de but', '41', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('136', 'Yougoslavie', '5', 'Attaquant de pointe', '30', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Union sovietique', '5', '147', '23');
INSERT INTO collaborateur_equipe VALUES ('148', 'Union sovietique', '5');
INSERT INTO collaborateur_equipe VALUES ('149', 'Union sovietique', '5');
INSERT INTO joueur_equipe VALUES ('141', 'Union sovietique', '5', 'Avant-centre', '1', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('142', 'Union sovietique', '5', 'Arriere latéral', '11', 'France National');
INSERT INTO joueur_equipe VALUES ('143', 'Union sovietique', '5', 'Millieu defensif', '19', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('144', 'Union sovietique', '5', 'Millieu offensif', '29', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('145', 'Union sovietique', '5', 'Gardien de but', '40', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('146', 'Union sovietique', '5', 'Attaquant de pointe', '44', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Tchecoslovaquie', '5', '157', '20');
INSERT INTO collaborateur_equipe VALUES ('158', 'Tchecoslovaquie', '5');
INSERT INTO collaborateur_equipe VALUES ('159', 'Tchecoslovaquie', '5');
INSERT INTO joueur_equipe VALUES ('151', 'Tchecoslovaquie', '5', 'Avant-centre', '0', 'France National');
INSERT INTO joueur_equipe VALUES ('152', 'Tchecoslovaquie', '5', 'Arriere latéral', '10', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('153', 'Tchecoslovaquie', '5', 'Millieu defensif', '18', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('154', 'Tchecoslovaquie', '5', 'Millieu offensif', '25', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('155', 'Tchecoslovaquie', '5', 'Gardien de but', '24', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('156', 'Tchecoslovaquie', '5', 'Attaquant de pointe', '38', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Pologne', '5', '167', '17');
INSERT INTO collaborateur_equipe VALUES ('168', 'Pologne', '5');
INSERT INTO collaborateur_equipe VALUES ('169', 'Pologne', '5');
INSERT INTO joueur_equipe VALUES ('161', 'Pologne', '5', 'Avant-centre', '1', 'France National');
INSERT INTO joueur_equipe VALUES ('162', 'Pologne', '5', 'Arriere latéral', '8', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('163', 'Pologne', '5', 'Millieu defensif', '14', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('164', 'Pologne', '5', 'Millieu offensif', '26', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('165', 'Pologne', '5', 'Gardien de but', '28', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('166', 'Pologne', '5', 'Attaquant de pointe', '31', 'Liverpool F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Argentine', '5', '177', '25');
INSERT INTO collaborateur_equipe VALUES ('178', 'Argentine', '5');
INSERT INTO collaborateur_equipe VALUES ('179', 'Argentine', '5');
INSERT INTO joueur_equipe VALUES ('171', 'Argentine', '5', 'Avant-centre', '1', 'France National');
INSERT INTO joueur_equipe VALUES ('172', 'Argentine', '5', 'Arriere latéral', '9', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('173', 'Argentine', '5', 'Millieu defensif', '14', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('174', 'Argentine', '5', 'Millieu offensif', '27', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('175', 'Argentine', '5', 'Gardien de but', '32', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('176', 'Argentine', '5', 'Attaquant de pointe', '48', 'Brazil nationnal');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Belgique', '5', '187', '2');
INSERT INTO collaborateur_equipe VALUES ('188', 'Belgique', '5');
INSERT INTO collaborateur_equipe VALUES ('189', 'Belgique', '5');
INSERT INTO joueur_equipe VALUES ('181', 'Belgique', '5', 'Avant-centre', '0', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('182', 'Belgique', '5', 'Arriere latéral', '8', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('183', 'Belgique', '5', 'Millieu defensif', '12', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('184', 'Belgique', '5', 'Millieu offensif', '22', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('185', 'Belgique', '5', 'Gardien de but', '37', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('186', 'Belgique', '5', 'Attaquant de pointe', '49', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Croatie', '5', '197', '1');
INSERT INTO collaborateur_equipe VALUES ('198', 'Croatie', '5');
INSERT INTO collaborateur_equipe VALUES ('199', 'Croatie', '5');
INSERT INTO joueur_equipe VALUES ('191', 'Croatie', '5', 'Avant-centre', '0', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('192', 'Croatie', '5', 'Arriere latéral', '9', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('193', 'Croatie', '5', 'Millieu defensif', '13', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('194', 'Croatie', '5', 'Millieu offensif', '26', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('195', 'Croatie', '5', 'Gardien de but', '32', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('196', 'Croatie', '5', 'Attaquant de pointe', '51', 'AS Monaco');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Pays-Bas', '5', '207', '5');
INSERT INTO collaborateur_equipe VALUES ('208', 'Pays-Bas', '5');
INSERT INTO collaborateur_equipe VALUES ('209', 'Pays-Bas', '5');
INSERT INTO joueur_equipe VALUES ('201', 'Pays-Bas', '5', 'Avant-centre', '1', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('202', 'Pays-Bas', '5', 'Arriere latéral', '6', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('203', 'Pays-Bas', '5', 'Millieu defensif', '20', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('204', 'Pays-Bas', '5', 'Millieu offensif', '20', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('205', 'Pays-Bas', '5', 'Gardien de but', '39', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('206', 'Pays-Bas', '5', 'Attaquant de pointe', '33', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Coree du Sud', '5', '217', '9');
INSERT INTO collaborateur_equipe VALUES ('218', 'Coree du Sud', '5');
INSERT INTO collaborateur_equipe VALUES ('219', 'Coree du Sud', '5');
INSERT INTO joueur_equipe VALUES ('211', 'Coree du Sud', '5', 'Avant-centre', '1', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('212', 'Coree du Sud', '5', 'Arriere latéral', '6', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('213', 'Coree du Sud', '5', 'Millieu defensif', '19', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('214', 'Coree du Sud', '5', 'Millieu offensif', '20', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('215', 'Coree du Sud', '5', 'Gardien de but', '41', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('216', 'Coree du Sud', '5', 'Attaquant de pointe', '38', 'Liverpool F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Japon', '5', '227', '30');
INSERT INTO collaborateur_equipe VALUES ('228', 'Japon', '5');
INSERT INTO collaborateur_equipe VALUES ('229', 'Japon', '5');
INSERT INTO joueur_equipe VALUES ('221', 'Japon', '5', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('222', 'Japon', '5', 'Arriere latéral', '10', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('223', 'Japon', '5', 'Millieu defensif', '12', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('224', 'Japon', '5', 'Millieu offensif', '26', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('225', 'Japon', '5', 'Gardien de but', '34', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('226', 'Japon', '5', 'Attaquant de pointe', '36', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Russie', '5', '237', '24');
INSERT INTO collaborateur_equipe VALUES ('238', 'Russie', '5');
INSERT INTO collaborateur_equipe VALUES ('239', 'Russie', '5');
INSERT INTO joueur_equipe VALUES ('231', 'Russie', '5', 'Avant-centre', '1', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('232', 'Russie', '5', 'Arriere latéral', '7', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('233', 'Russie', '5', 'Millieu defensif', '12', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('234', 'Russie', '5', 'Millieu offensif', '22', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('235', 'Russie', '5', 'Gardien de but', '35', 'France National');
INSERT INTO joueur_equipe VALUES ('236', 'Russie', '5', 'Attaquant de pointe', '42', 'Liverpool F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Maroque', '5', '247', '3');
INSERT INTO collaborateur_equipe VALUES ('248', 'Maroque', '5');
INSERT INTO collaborateur_equipe VALUES ('249', 'Maroque', '5');
INSERT INTO joueur_equipe VALUES ('241', 'Maroque', '5', 'Avant-centre', '1', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('242', 'Maroque', '5', 'Arriere latéral', '10', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('243', 'Maroque', '5', 'Millieu defensif', '19', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('244', 'Maroque', '5', 'Millieu offensif', '23', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('245', 'Maroque', '5', 'Gardien de but', '26', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('246', 'Maroque', '5', 'Attaquant de pointe', '36', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Egypt', '5', '257', '13');
INSERT INTO collaborateur_equipe VALUES ('258', 'Egypt', '5');
INSERT INTO collaborateur_equipe VALUES ('259', 'Egypt', '5');
INSERT INTO joueur_equipe VALUES ('251', 'Egypt', '5', 'Avant-centre', '1', 'France National');
INSERT INTO joueur_equipe VALUES ('252', 'Egypt', '5', 'Arriere latéral', '8', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('253', 'Egypt', '5', 'Millieu defensif', '21', 'France National');
INSERT INTO joueur_equipe VALUES ('254', 'Egypt', '5', 'Millieu offensif', '24', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('255', 'Egypt', '5', 'Gardien de but', '30', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('256', 'Egypt', '5', 'Attaquant de pointe', '38', 'Olympique Lyonnais');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Grece', '5', '267', '27');
INSERT INTO collaborateur_equipe VALUES ('268', 'Grece', '5');
INSERT INTO collaborateur_equipe VALUES ('269', 'Grece', '5');
INSERT INTO joueur_equipe VALUES ('261', 'Grece', '5', 'Avant-centre', '1', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('262', 'Grece', '5', 'Arriere latéral', '6', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('263', 'Grece', '5', 'Millieu defensif', '19', 'France National');
INSERT INTO joueur_equipe VALUES ('264', 'Grece', '5', 'Millieu offensif', '28', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('265', 'Grece', '5', 'Gardien de but', '26', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('266', 'Grece', '5', 'Attaquant de pointe', '30', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Qatar', '5', '277', '15');
INSERT INTO collaborateur_equipe VALUES ('278', 'Qatar', '5');
INSERT INTO collaborateur_equipe VALUES ('279', 'Qatar', '5');
INSERT INTO joueur_equipe VALUES ('271', 'Qatar', '5', 'Avant-centre', '0', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('272', 'Qatar', '5', 'Arriere latéral', '7', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('273', 'Qatar', '5', 'Millieu defensif', '21', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('274', 'Qatar', '5', 'Millieu offensif', '24', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('275', 'Qatar', '5', 'Gardien de but', '39', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('276', 'Qatar', '5', 'Attaquant de pointe', '35', 'AS Monaco');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Etats-Unis', '5', '287', '8');
INSERT INTO collaborateur_equipe VALUES ('288', 'Etats-Unis', '5');
INSERT INTO collaborateur_equipe VALUES ('289', 'Etats-Unis', '5');
INSERT INTO joueur_equipe VALUES ('281', 'Etats-Unis', '5', 'Avant-centre', '0', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('282', 'Etats-Unis', '5', 'Arriere latéral', '10', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('283', 'Etats-Unis', '5', 'Millieu defensif', '19', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('284', 'Etats-Unis', '5', 'Millieu offensif', '22', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('285', 'Etats-Unis', '5', 'Gardien de but', '25', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('286', 'Etats-Unis', '5', 'Attaquant de pointe', '43', 'AS Monaco');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Turquie', '5', '297', '19');
INSERT INTO collaborateur_equipe VALUES ('298', 'Turquie', '5');
INSERT INTO collaborateur_equipe VALUES ('299', 'Turquie', '5');
INSERT INTO joueur_equipe VALUES ('291', 'Turquie', '5', 'Avant-centre', '0', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('292', 'Turquie', '5', 'Arriere latéral', '11', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('293', 'Turquie', '5', 'Millieu defensif', '15', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('294', 'Turquie', '5', 'Millieu offensif', '26', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('295', 'Turquie', '5', 'Gardien de but', '26', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('296', 'Turquie', '5', 'Attaquant de pointe', '34', 'Spain N.F.C.');

 -- Stade -- 
INSERT INTO stade VALUES ('Grandios Stadium', 'Hadderfoo', '30000', 'Bresil', '1879');

 -- Match -- 

INSERT INTO match_foot VALUES ('2014-06-12', 'Bresil', 'Belgique', 'Ronde de groupe', '5', '0', '5', 'Grandios Stadium', 'Hadderfoo');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('100', 'Bresil', 'Belgique', 'Principal', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('12', '100', 'Bresil', 'Belgique', '2014-06-12', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('15', '100', 'Bresil', 'Belgique', '2014-06-12', 'Jaune');
INSERT INTO arbitre_match VALUES ('150', 'Bresil', 'Belgique', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('12', '150', 'Bresil', 'Belgique', '2014-06-12', 'Jaune');
INSERT INTO arbitre_match VALUES ('170', 'Bresil', 'Belgique', 'Assistant', '2014-06-12');
INSERT INTO arbitre_match VALUES ('220', 'Bresil', 'Belgique', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('16', '220', 'Bresil', 'Belgique', '2014-06-12', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('13', '220', 'Bresil', 'Belgique', '2014-06-12', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('2014-06-12', 'Suisse', 'Croatie', 'Ronde de 16', '2', '3', '5', 'Grandios Stadium', 'Hadderfoo');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('60', 'Suisse', 'Croatie', 'Principal', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('21', '60', 'Suisse', 'Croatie', '2014-06-12', 'Rouge');
INSERT INTO arbitre_match VALUES ('140', 'Suisse', 'Croatie', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('26', '140', 'Suisse', 'Croatie', '2014-06-12', 'Jaune');
INSERT INTO arbitre_match VALUES ('180', 'Suisse', 'Croatie', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('25', '180', 'Suisse', 'Croatie', '2014-06-12', 'Jaune');
INSERT INTO arbitre_match VALUES ('220', 'Suisse', 'Croatie', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('24', '220', 'Suisse', 'Croatie', '2014-06-12', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('24', '220', 'Suisse', 'Croatie', '2014-06-12', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2014-06-12', 'Suede', 'Pays-Bas', 'Quart de finale', '5', '2', '5', 'Grandios Stadium', 'Hadderfoo');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('70', 'Suede', 'Pays-Bas', 'Principal', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('31', '70', 'Suede', 'Pays-Bas', '2014-06-12', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('34', '70', 'Suede', 'Pays-Bas', '2014-06-12', 'Jaune');
INSERT INTO arbitre_match VALUES ('140', 'Suede', 'Pays-Bas', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('33', '140', 'Suede', 'Pays-Bas', '2014-06-12', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('31', '140', 'Suede', 'Pays-Bas', '2014-06-12', 'Rouge');
INSERT INTO arbitre_match VALUES ('170', 'Suede', 'Pays-Bas', 'Assistant', '2014-06-12');
INSERT INTO arbitre_match VALUES ('210', 'Suede', 'Pays-Bas', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('34', '210', 'Suede', 'Pays-Bas', '2014-06-12', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2014-06-12', 'Chili', 'Coree du Sud', 'Finale', '3', '4', '5', 'Grandios Stadium', 'Hadderfoo');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('80', 'Chili', 'Coree du Sud', 'Principal', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('43', '80', 'Chili', 'Coree du Sud', '2014-06-12', 'Jaune');
INSERT INTO arbitre_match VALUES ('110', 'Chili', 'Coree du Sud', 'Assistant', '2014-06-12');
INSERT INTO arbitre_match VALUES ('160', 'Chili', 'Coree du Sud', 'Assistant', '2014-06-12');
INSERT INTO arbitre_match VALUES ('210', 'Chili', 'Coree du Sud', 'Assistant', '2014-06-12');

 -- Match -- 

INSERT INTO match_foot VALUES ('2014-06-12', 'Angleterre', 'Japon', 'Quart de finale', '1', '5', '5', 'Grandios Stadium', 'Hadderfoo');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('60', 'Angleterre', 'Japon', 'Principal', '2014-06-12');
INSERT INTO arbitre_match VALUES ('110', 'Angleterre', 'Japon', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('54', '110', 'Angleterre', 'Japon', '2014-06-12', 'Rouge');
INSERT INTO arbitre_match VALUES ('190', 'Angleterre', 'Japon', 'Assistant', '2014-06-12');
INSERT INTO arbitre_match VALUES ('250', 'Angleterre', 'Japon', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('54', '250', 'Angleterre', 'Japon', '2014-06-12', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('54', '250', 'Angleterre', 'Japon', '2014-06-12', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2014-06-12', 'Mexique', 'Russie', 'Quart de finale', '4', '3', '5', 'Grandios Stadium', 'Hadderfoo');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('60', 'Mexique', 'Russie', 'Principal', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('62', '60', 'Mexique', 'Russie', '2014-06-12', 'Jaune');
INSERT INTO arbitre_match VALUES ('140', 'Mexique', 'Russie', 'Assistant', '2014-06-12');
INSERT INTO arbitre_match VALUES ('160', 'Mexique', 'Russie', 'Assistant', '2014-06-12');
INSERT INTO arbitre_match VALUES ('220', 'Mexique', 'Russie', 'Assistant', '2014-06-12');

 -- Match -- 

INSERT INTO match_foot VALUES ('2014-06-12', 'Allemagne', 'Maroque', 'Ronde de groupe', '1', '2', '5', 'Grandios Stadium', 'Hadderfoo');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Allemagne', 'Maroque', 'Principal', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('71', '90', 'Allemagne', 'Maroque', '2014-06-12', 'Rouge');
INSERT INTO arbitre_match VALUES ('140', 'Allemagne', 'Maroque', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('72', '140', 'Allemagne', 'Maroque', '2014-06-12', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('73', '140', 'Allemagne', 'Maroque', '2014-06-12', 'Rouge');
INSERT INTO arbitre_match VALUES ('160', 'Allemagne', 'Maroque', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('75', '160', 'Allemagne', 'Maroque', '2014-06-12', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('73', '160', 'Allemagne', 'Maroque', '2014-06-12', 'Jaune');
INSERT INTO arbitre_match VALUES ('230', 'Allemagne', 'Maroque', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('72', '230', 'Allemagne', 'Maroque', '2014-06-12', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('2014-06-12', 'Portugal', 'Egypt', 'Semi-finale', '1', '4', '5', 'Grandios Stadium', 'Hadderfoo');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('80', 'Portugal', 'Egypt', 'Principal', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('84', '80', 'Portugal', 'Egypt', '2014-06-12', 'Jaune');
INSERT INTO arbitre_match VALUES ('150', 'Portugal', 'Egypt', 'Assistant', '2014-06-12');
INSERT INTO arbitre_match VALUES ('190', 'Portugal', 'Egypt', 'Assistant', '2014-06-12');
INSERT INTO arbitre_match VALUES ('220', 'Portugal', 'Egypt', 'Assistant', '2014-06-12');

 -- Match -- 

INSERT INTO match_foot VALUES ('2014-06-12', 'Autriche', 'Grece', 'Semi-finale', '3', '0', '5', 'Grandios Stadium', 'Hadderfoo');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('70', 'Autriche', 'Grece', 'Principal', '2014-06-12');
INSERT INTO arbitre_match VALUES ('140', 'Autriche', 'Grece', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('93', '140', 'Autriche', 'Grece', '2014-06-12', 'Rouge');
INSERT INTO arbitre_match VALUES ('160', 'Autriche', 'Grece', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('92', '160', 'Autriche', 'Grece', '2014-06-12', 'Jaune');
INSERT INTO arbitre_match VALUES ('230', 'Autriche', 'Grece', 'Assistant', '2014-06-12');

 -- Match -- 

INSERT INTO match_foot VALUES ('2014-06-12', 'Yougoslavie', 'Qatar', 'Ronde de 16', '2', '3', '5', 'Grandios Stadium', 'Hadderfoo');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('80', 'Yougoslavie', 'Qatar', 'Principal', '2014-06-12');
INSERT INTO arbitre_match VALUES ('120', 'Yougoslavie', 'Qatar', 'Assistant', '2014-06-12');
INSERT INTO arbitre_match VALUES ('160', 'Yougoslavie', 'Qatar', 'Assistant', '2014-06-12');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('104', '160', 'Yougoslavie', 'Qatar', '2014-06-12', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('106', '160', 'Yougoslavie', 'Qatar', '2014-06-12', 'Rouge');
INSERT INTO arbitre_match VALUES ('230', 'Yougoslavie', 'Qatar', 'Assistant', '2014-06-12');


  -- Coupe Du Monde  --- 
INSERT INTO coupe_du_monde VALUES ('6', '2018-06-14', '2018-07-15');
INSERT INTO pays_coupe VALUES ('Suisse', '6');


 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Uruguay', '6', '7', '29');
INSERT INTO collaborateur_equipe VALUES ('8', 'Uruguay', '6');
INSERT INTO collaborateur_equipe VALUES ('9', 'Uruguay', '6');
INSERT INTO joueur_equipe VALUES ('1', 'Uruguay', '6', 'Avant-centre', '1', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('2', 'Uruguay', '6', 'Arriere latéral', '8', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('3', 'Uruguay', '6', 'Millieu defensif', '18', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('4', 'Uruguay', '6', 'Millieu offensif', '29', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('5', 'Uruguay', '6', 'Gardien de but', '29', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('6', 'Uruguay', '6', 'Attaquant de pointe', '33', 'F.C. Barcelona');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Italie', '6', '17', '30');
INSERT INTO collaborateur_equipe VALUES ('18', 'Italie', '6');
INSERT INTO collaborateur_equipe VALUES ('19', 'Italie', '6');
INSERT INTO joueur_equipe VALUES ('11', 'Italie', '6', 'Avant-centre', '1', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('12', 'Italie', '6', 'Arriere latéral', '10', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('13', 'Italie', '6', 'Millieu defensif', '20', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('14', 'Italie', '6', 'Millieu offensif', '21', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('15', 'Italie', '6', 'Gardien de but', '40', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('16', 'Italie', '6', 'Attaquant de pointe', '31', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('France', '6', '27', '25');
INSERT INTO collaborateur_equipe VALUES ('28', 'France', '6');
INSERT INTO collaborateur_equipe VALUES ('29', 'France', '6');
INSERT INTO joueur_equipe VALUES ('21', 'France', '6', 'Avant-centre', '0', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('22', 'France', '6', 'Arriere latéral', '10', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('23', 'France', '6', 'Millieu defensif', '17', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('24', 'France', '6', 'Millieu offensif', '27', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('25', 'France', '6', 'Gardien de but', '28', 'France National');
INSERT INTO joueur_equipe VALUES ('26', 'France', '6', 'Attaquant de pointe', '39', 'Real Madrid');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Canada', '6', '37', '6');
INSERT INTO collaborateur_equipe VALUES ('38', 'Canada', '6');
INSERT INTO collaborateur_equipe VALUES ('39', 'Canada', '6');
INSERT INTO joueur_equipe VALUES ('31', 'Canada', '6', 'Avant-centre', '1', 'France National');
INSERT INTO joueur_equipe VALUES ('32', 'Canada', '6', 'Arriere latéral', '6', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('33', 'Canada', '6', 'Millieu defensif', '14', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('34', 'Canada', '6', 'Millieu offensif', '29', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('35', 'Canada', '6', 'Gardien de but', '32', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('36', 'Canada', '6', 'Attaquant de pointe', '36', 'Spain N.F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Bresil', '6', '47', '13');
INSERT INTO collaborateur_equipe VALUES ('48', 'Bresil', '6');
INSERT INTO collaborateur_equipe VALUES ('49', 'Bresil', '6');
INSERT INTO joueur_equipe VALUES ('41', 'Bresil', '6', 'Avant-centre', '0', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('42', 'Bresil', '6', 'Arriere latéral', '11', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('43', 'Bresil', '6', 'Millieu defensif', '14', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('44', 'Bresil', '6', 'Millieu offensif', '24', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('45', 'Bresil', '6', 'Gardien de but', '31', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('46', 'Bresil', '6', 'Attaquant de pointe', '50', 'Manchester United F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Suisse', '6', '57', '2');
INSERT INTO collaborateur_equipe VALUES ('58', 'Suisse', '6');
INSERT INTO collaborateur_equipe VALUES ('59', 'Suisse', '6');
INSERT INTO joueur_equipe VALUES ('51', 'Suisse', '6', 'Avant-centre', '1', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('52', 'Suisse', '6', 'Arriere latéral', '10', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('53', 'Suisse', '6', 'Millieu defensif', '13', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('54', 'Suisse', '6', 'Millieu offensif', '29', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('55', 'Suisse', '6', 'Gardien de but', '35', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('56', 'Suisse', '6', 'Attaquant de pointe', '50', 'Brazil nationnal');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Suede', '6', '67', '19');
INSERT INTO collaborateur_equipe VALUES ('68', 'Suede', '6');
INSERT INTO collaborateur_equipe VALUES ('69', 'Suede', '6');
INSERT INTO joueur_equipe VALUES ('61', 'Suede', '6', 'Avant-centre', '0', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('62', 'Suede', '6', 'Arriere latéral', '8', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('63', 'Suede', '6', 'Millieu defensif', '19', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('64', 'Suede', '6', 'Millieu offensif', '26', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('65', 'Suede', '6', 'Gardien de but', '32', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('66', 'Suede', '6', 'Attaquant de pointe', '40', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Chili', '6', '77', '3');
INSERT INTO collaborateur_equipe VALUES ('78', 'Chili', '6');
INSERT INTO collaborateur_equipe VALUES ('79', 'Chili', '6');
INSERT INTO joueur_equipe VALUES ('71', 'Chili', '6', 'Avant-centre', '1', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('72', 'Chili', '6', 'Arriere latéral', '10', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('73', 'Chili', '6', 'Millieu defensif', '20', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('74', 'Chili', '6', 'Millieu offensif', '25', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('75', 'Chili', '6', 'Gardien de but', '26', 'France National');
INSERT INTO joueur_equipe VALUES ('76', 'Chili', '6', 'Attaquant de pointe', '34', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Angleterre', '6', '87', '10');
INSERT INTO collaborateur_equipe VALUES ('88', 'Angleterre', '6');
INSERT INTO collaborateur_equipe VALUES ('89', 'Angleterre', '6');
INSERT INTO joueur_equipe VALUES ('81', 'Angleterre', '6', 'Avant-centre', '0', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('82', 'Angleterre', '6', 'Arriere latéral', '10', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('83', 'Angleterre', '6', 'Millieu defensif', '14', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('84', 'Angleterre', '6', 'Millieu offensif', '27', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('85', 'Angleterre', '6', 'Gardien de but', '24', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('86', 'Angleterre', '6', 'Attaquant de pointe', '44', 'Manchester United F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Mexique', '6', '97', '28');
INSERT INTO collaborateur_equipe VALUES ('98', 'Mexique', '6');
INSERT INTO collaborateur_equipe VALUES ('99', 'Mexique', '6');
INSERT INTO joueur_equipe VALUES ('91', 'Mexique', '6', 'Avant-centre', '0', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('92', 'Mexique', '6', 'Arriere latéral', '6', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('93', 'Mexique', '6', 'Millieu defensif', '12', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('94', 'Mexique', '6', 'Millieu offensif', '19', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('95', 'Mexique', '6', 'Gardien de but', '31', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('96', 'Mexique', '6', 'Attaquant de pointe', '43', 'AS Monaco');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Allemagne', '6', '107', '14');
INSERT INTO collaborateur_equipe VALUES ('108', 'Allemagne', '6');
INSERT INTO collaborateur_equipe VALUES ('109', 'Allemagne', '6');
INSERT INTO joueur_equipe VALUES ('101', 'Allemagne', '6', 'Avant-centre', '0', 'France National');
INSERT INTO joueur_equipe VALUES ('102', 'Allemagne', '6', 'Arriere latéral', '11', 'France National');
INSERT INTO joueur_equipe VALUES ('103', 'Allemagne', '6', 'Millieu defensif', '16', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('104', 'Allemagne', '6', 'Millieu offensif', '25', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('105', 'Allemagne', '6', 'Gardien de but', '34', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('106', 'Allemagne', '6', 'Attaquant de pointe', '41', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Portugal', '6', '117', '8');
INSERT INTO collaborateur_equipe VALUES ('118', 'Portugal', '6');
INSERT INTO collaborateur_equipe VALUES ('119', 'Portugal', '6');
INSERT INTO joueur_equipe VALUES ('111', 'Portugal', '6', 'Avant-centre', '0', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('112', 'Portugal', '6', 'Arriere latéral', '11', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('113', 'Portugal', '6', 'Millieu defensif', '21', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('114', 'Portugal', '6', 'Millieu offensif', '30', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('115', 'Portugal', '6', 'Gardien de but', '30', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('116', 'Portugal', '6', 'Attaquant de pointe', '48', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Autriche', '6', '127', '21');
INSERT INTO collaborateur_equipe VALUES ('128', 'Autriche', '6');
INSERT INTO collaborateur_equipe VALUES ('129', 'Autriche', '6');
INSERT INTO joueur_equipe VALUES ('121', 'Autriche', '6', 'Avant-centre', '1', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('122', 'Autriche', '6', 'Arriere latéral', '11', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('123', 'Autriche', '6', 'Millieu defensif', '14', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('124', 'Autriche', '6', 'Millieu offensif', '18', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('125', 'Autriche', '6', 'Gardien de but', '39', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('126', 'Autriche', '6', 'Attaquant de pointe', '38', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Yougoslavie', '6', '137', '22');
INSERT INTO collaborateur_equipe VALUES ('138', 'Yougoslavie', '6');
INSERT INTO collaborateur_equipe VALUES ('139', 'Yougoslavie', '6');
INSERT INTO joueur_equipe VALUES ('131', 'Yougoslavie', '6', 'Avant-centre', '1', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('132', 'Yougoslavie', '6', 'Arriere latéral', '8', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('133', 'Yougoslavie', '6', 'Millieu defensif', '15', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('134', 'Yougoslavie', '6', 'Millieu offensif', '20', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('135', 'Yougoslavie', '6', 'Gardien de but', '38', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('136', 'Yougoslavie', '6', 'Attaquant de pointe', '41', 'Spain N.F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Union sovietique', '6', '147', '7');
INSERT INTO collaborateur_equipe VALUES ('148', 'Union sovietique', '6');
INSERT INTO collaborateur_equipe VALUES ('149', 'Union sovietique', '6');
INSERT INTO joueur_equipe VALUES ('141', 'Union sovietique', '6', 'Avant-centre', '0', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('142', 'Union sovietique', '6', 'Arriere latéral', '7', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('143', 'Union sovietique', '6', 'Millieu defensif', '17', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('144', 'Union sovietique', '6', 'Millieu offensif', '24', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('145', 'Union sovietique', '6', 'Gardien de but', '34', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('146', 'Union sovietique', '6', 'Attaquant de pointe', '44', 'Real Madrid');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Tchecoslovaquie', '6', '157', '17');
INSERT INTO collaborateur_equipe VALUES ('158', 'Tchecoslovaquie', '6');
INSERT INTO collaborateur_equipe VALUES ('159', 'Tchecoslovaquie', '6');
INSERT INTO joueur_equipe VALUES ('151', 'Tchecoslovaquie', '6', 'Avant-centre', '0', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('152', 'Tchecoslovaquie', '6', 'Arriere latéral', '9', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('153', 'Tchecoslovaquie', '6', 'Millieu defensif', '14', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('154', 'Tchecoslovaquie', '6', 'Millieu offensif', '30', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('155', 'Tchecoslovaquie', '6', 'Gardien de but', '38', 'France National');
INSERT INTO joueur_equipe VALUES ('156', 'Tchecoslovaquie', '6', 'Attaquant de pointe', '35', 'FC Bayern');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Pologne', '6', '167', '16');
INSERT INTO collaborateur_equipe VALUES ('168', 'Pologne', '6');
INSERT INTO collaborateur_equipe VALUES ('169', 'Pologne', '6');
INSERT INTO joueur_equipe VALUES ('161', 'Pologne', '6', 'Avant-centre', '0', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('162', 'Pologne', '6', 'Arriere latéral', '8', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('163', 'Pologne', '6', 'Millieu defensif', '19', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('164', 'Pologne', '6', 'Millieu offensif', '22', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('165', 'Pologne', '6', 'Gardien de but', '32', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('166', 'Pologne', '6', 'Attaquant de pointe', '47', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Argentine', '6', '177', '11');
INSERT INTO collaborateur_equipe VALUES ('178', 'Argentine', '6');
INSERT INTO collaborateur_equipe VALUES ('179', 'Argentine', '6');
INSERT INTO joueur_equipe VALUES ('171', 'Argentine', '6', 'Avant-centre', '1', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('172', 'Argentine', '6', 'Arriere latéral', '8', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('173', 'Argentine', '6', 'Millieu defensif', '21', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('174', 'Argentine', '6', 'Millieu offensif', '30', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('175', 'Argentine', '6', 'Gardien de but', '28', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('176', 'Argentine', '6', 'Attaquant de pointe', '38', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Belgique', '6', '187', '12');
INSERT INTO collaborateur_equipe VALUES ('188', 'Belgique', '6');
INSERT INTO collaborateur_equipe VALUES ('189', 'Belgique', '6');
INSERT INTO joueur_equipe VALUES ('181', 'Belgique', '6', 'Avant-centre', '1', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('182', 'Belgique', '6', 'Arriere latéral', '11', 'Brazil nationnal');
INSERT INTO joueur_equipe VALUES ('183', 'Belgique', '6', 'Millieu defensif', '21', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('184', 'Belgique', '6', 'Millieu offensif', '18', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('185', 'Belgique', '6', 'Gardien de but', '28', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('186', 'Belgique', '6', 'Attaquant de pointe', '32', 'Brazil nationnal');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Croatie', '6', '197', '23');
INSERT INTO collaborateur_equipe VALUES ('198', 'Croatie', '6');
INSERT INTO collaborateur_equipe VALUES ('199', 'Croatie', '6');
INSERT INTO joueur_equipe VALUES ('191', 'Croatie', '6', 'Avant-centre', '1', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('192', 'Croatie', '6', 'Arriere latéral', '9', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('193', 'Croatie', '6', 'Millieu defensif', '17', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('194', 'Croatie', '6', 'Millieu offensif', '21', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('195', 'Croatie', '6', 'Gardien de but', '25', 'France National');
INSERT INTO joueur_equipe VALUES ('196', 'Croatie', '6', 'Attaquant de pointe', '48', 'Manchester United F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Pays-Bas', '6', '207', '4');
INSERT INTO collaborateur_equipe VALUES ('208', 'Pays-Bas', '6');
INSERT INTO collaborateur_equipe VALUES ('209', 'Pays-Bas', '6');
INSERT INTO joueur_equipe VALUES ('201', 'Pays-Bas', '6', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('202', 'Pays-Bas', '6', 'Arriere latéral', '9', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('203', 'Pays-Bas', '6', 'Millieu defensif', '20', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('204', 'Pays-Bas', '6', 'Millieu offensif', '18', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('205', 'Pays-Bas', '6', 'Gardien de but', '37', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('206', 'Pays-Bas', '6', 'Attaquant de pointe', '40', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Coree du Sud', '6', '217', '1');
INSERT INTO collaborateur_equipe VALUES ('218', 'Coree du Sud', '6');
INSERT INTO collaborateur_equipe VALUES ('219', 'Coree du Sud', '6');
INSERT INTO joueur_equipe VALUES ('211', 'Coree du Sud', '6', 'Avant-centre', '0', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('212', 'Coree du Sud', '6', 'Arriere latéral', '6', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('213', 'Coree du Sud', '6', 'Millieu defensif', '19', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('214', 'Coree du Sud', '6', 'Millieu offensif', '23', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('215', 'Coree du Sud', '6', 'Gardien de but', '40', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('216', 'Coree du Sud', '6', 'Attaquant de pointe', '46', 'Arsenal F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Japon', '6', '227', '15');
INSERT INTO collaborateur_equipe VALUES ('228', 'Japon', '6');
INSERT INTO collaborateur_equipe VALUES ('229', 'Japon', '6');
INSERT INTO joueur_equipe VALUES ('221', 'Japon', '6', 'Avant-centre', '0', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('222', 'Japon', '6', 'Arriere latéral', '7', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('223', 'Japon', '6', 'Millieu defensif', '12', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('224', 'Japon', '6', 'Millieu offensif', '19', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('225', 'Japon', '6', 'Gardien de but', '36', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('226', 'Japon', '6', 'Attaquant de pointe', '49', 'Liverpool F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Russie', '6', '237', '5');
INSERT INTO collaborateur_equipe VALUES ('238', 'Russie', '6');
INSERT INTO collaborateur_equipe VALUES ('239', 'Russie', '6');
INSERT INTO joueur_equipe VALUES ('231', 'Russie', '6', 'Avant-centre', '1', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('232', 'Russie', '6', 'Arriere latéral', '6', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('233', 'Russie', '6', 'Millieu defensif', '15', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('234', 'Russie', '6', 'Millieu offensif', '24', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('235', 'Russie', '6', 'Gardien de but', '26', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('236', 'Russie', '6', 'Attaquant de pointe', '38', 'Liverpool F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Maroque', '6', '247', '26');
INSERT INTO collaborateur_equipe VALUES ('248', 'Maroque', '6');
INSERT INTO collaborateur_equipe VALUES ('249', 'Maroque', '6');
INSERT INTO joueur_equipe VALUES ('241', 'Maroque', '6', 'Avant-centre', '0', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('242', 'Maroque', '6', 'Arriere latéral', '8', 'Chelsea F.C.');
INSERT INTO joueur_equipe VALUES ('243', 'Maroque', '6', 'Millieu defensif', '15', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('244', 'Maroque', '6', 'Millieu offensif', '31', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('245', 'Maroque', '6', 'Gardien de but', '41', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('246', 'Maroque', '6', 'Attaquant de pointe', '38', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Egypt', '6', '257', '27');
INSERT INTO collaborateur_equipe VALUES ('258', 'Egypt', '6');
INSERT INTO collaborateur_equipe VALUES ('259', 'Egypt', '6');
INSERT INTO joueur_equipe VALUES ('251', 'Egypt', '6', 'Avant-centre', '0', 'Olympique Lyonnais');
INSERT INTO joueur_equipe VALUES ('252', 'Egypt', '6', 'Arriere latéral', '8', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('253', 'Egypt', '6', 'Millieu defensif', '18', 'France National');
INSERT INTO joueur_equipe VALUES ('254', 'Egypt', '6', 'Millieu offensif', '30', 'France National');
INSERT INTO joueur_equipe VALUES ('255', 'Egypt', '6', 'Gardien de but', '33', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('256', 'Egypt', '6', 'Attaquant de pointe', '42', 'Chelsea F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Grece', '6', '267', '18');
INSERT INTO collaborateur_equipe VALUES ('268', 'Grece', '6');
INSERT INTO collaborateur_equipe VALUES ('269', 'Grece', '6');
INSERT INTO joueur_equipe VALUES ('261', 'Grece', '6', 'Avant-centre', '1', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('262', 'Grece', '6', 'Arriere latéral', '8', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('263', 'Grece', '6', 'Millieu defensif', '19', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('264', 'Grece', '6', 'Millieu offensif', '28', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('265', 'Grece', '6', 'Gardien de but', '38', 'Spain N.F.C.');
INSERT INTO joueur_equipe VALUES ('266', 'Grece', '6', 'Attaquant de pointe', '41', 'Manchester United F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Qatar', '6', '277', '24');
INSERT INTO collaborateur_equipe VALUES ('278', 'Qatar', '6');
INSERT INTO collaborateur_equipe VALUES ('279', 'Qatar', '6');
INSERT INTO joueur_equipe VALUES ('271', 'Qatar', '6', 'Avant-centre', '0', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('272', 'Qatar', '6', 'Arriere latéral', '7', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('273', 'Qatar', '6', 'Millieu defensif', '18', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('274', 'Qatar', '6', 'Millieu offensif', '21', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('275', 'Qatar', '6', 'Gardien de but', '35', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('276', 'Qatar', '6', 'Attaquant de pointe', '49', 'France National');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Etats-Unis', '6', '287', '9');
INSERT INTO collaborateur_equipe VALUES ('288', 'Etats-Unis', '6');
INSERT INTO collaborateur_equipe VALUES ('289', 'Etats-Unis', '6');
INSERT INTO joueur_equipe VALUES ('281', 'Etats-Unis', '6', 'Avant-centre', '0', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('282', 'Etats-Unis', '6', 'Arriere latéral', '9', 'F.C. Barcelona');
INSERT INTO joueur_equipe VALUES ('283', 'Etats-Unis', '6', 'Millieu defensif', '21', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('284', 'Etats-Unis', '6', 'Millieu offensif', '21', 'FC Bayern');
INSERT INTO joueur_equipe VALUES ('285', 'Etats-Unis', '6', 'Gardien de but', '36', 'Liverpool F.C.');
INSERT INTO joueur_equipe VALUES ('286', 'Etats-Unis', '6', 'Attaquant de pointe', '31', 'Manchester United F.C.');

 -- EQUIPE  + Association-- 

INSERT INTO equipe_foot VALUES ('Turquie', '6', '297', '20');
INSERT INTO collaborateur_equipe VALUES ('298', 'Turquie', '6');
INSERT INTO collaborateur_equipe VALUES ('299', 'Turquie', '6');
INSERT INTO joueur_equipe VALUES ('291', 'Turquie', '6', 'Avant-centre', '0', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('292', 'Turquie', '6', 'Arriere latéral', '8', 'Real Madrid');
INSERT INTO joueur_equipe VALUES ('293', 'Turquie', '6', 'Millieu defensif', '12', 'AS Monaco');
INSERT INTO joueur_equipe VALUES ('294', 'Turquie', '6', 'Millieu offensif', '28', 'Manchester United F.C.');
INSERT INTO joueur_equipe VALUES ('295', 'Turquie', '6', 'Gardien de but', '39', 'Arsenal F.C.');
INSERT INTO joueur_equipe VALUES ('296', 'Turquie', '6', 'Attaquant de pointe', '48', 'Arsenal F.C.');

 -- Stade -- 
INSERT INTO stade VALUES ('Cookie Center', 'Sier', '44000', 'Suisse', '1651');

 -- Match -- 

INSERT INTO match_foot VALUES ('2018-06-14', 'Suisse', 'Pays-Bas', 'Semi-finale', '0', '1', '6', 'Cookie Center', 'Sier');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Suisse', 'Pays-Bas', 'Principal', '2018-06-14');
INSERT INTO arbitre_match VALUES ('150', 'Suisse', 'Pays-Bas', 'Assistant', '2018-06-14');
INSERT INTO arbitre_match VALUES ('200', 'Suisse', 'Pays-Bas', 'Assistant', '2018-06-14');
INSERT INTO arbitre_match VALUES ('210', 'Suisse', 'Pays-Bas', 'Assistant', '2018-06-14');

 -- Match -- 

INSERT INTO match_foot VALUES ('2018-06-14', 'Suede', 'Coree du Sud', 'Semi-finale', '0', '1', '6', 'Cookie Center', 'Sier');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('100', 'Suede', 'Coree du Sud', 'Principal', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('23', '100', 'Suede', 'Coree du Sud', '2018-06-14', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('25', '100', 'Suede', 'Coree du Sud', '2018-06-14', 'Rouge');
INSERT INTO arbitre_match VALUES ('110', 'Suede', 'Coree du Sud', 'Assistant', '2018-06-14');
INSERT INTO arbitre_match VALUES ('180', 'Suede', 'Coree du Sud', 'Assistant', '2018-06-14');
INSERT INTO arbitre_match VALUES ('250', 'Suede', 'Coree du Sud', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('24', '250', 'Suede', 'Coree du Sud', '2018-06-14', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('25', '250', 'Suede', 'Coree du Sud', '2018-06-14', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('2018-06-14', 'Chili', 'Japon', 'Ronde de groupe', '5', '1', '6', 'Cookie Center', 'Sier');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Chili', 'Japon', 'Principal', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('34', '90', 'Chili', 'Japon', '2018-06-14', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('31', '90', 'Chili', 'Japon', '2018-06-14', 'Rouge');
INSERT INTO arbitre_match VALUES ('110', 'Chili', 'Japon', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('35', '110', 'Chili', 'Japon', '2018-06-14', 'Rouge');
INSERT INTO arbitre_match VALUES ('180', 'Chili', 'Japon', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('36', '180', 'Chili', 'Japon', '2018-06-14', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('35', '180', 'Chili', 'Japon', '2018-06-14', 'Jaune');
INSERT INTO arbitre_match VALUES ('250', 'Chili', 'Japon', 'Assistant', '2018-06-14');

 -- Match -- 

INSERT INTO match_foot VALUES ('2018-06-14', 'Angleterre', 'Russie', 'Finale', '2', '0', '6', 'Cookie Center', 'Sier');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Angleterre', 'Russie', 'Principal', '2018-06-14');
INSERT INTO arbitre_match VALUES ('130', 'Angleterre', 'Russie', 'Assistant', '2018-06-14');
INSERT INTO arbitre_match VALUES ('180', 'Angleterre', 'Russie', 'Assistant', '2018-06-14');
INSERT INTO arbitre_match VALUES ('220', 'Angleterre', 'Russie', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('46', '220', 'Angleterre', 'Russie', '2018-06-14', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('2018-06-14', 'Mexique', 'Maroque', 'Ronde de groupe', '2', '3', '6', 'Cookie Center', 'Sier');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('80', 'Mexique', 'Maroque', 'Principal', '2018-06-14');
INSERT INTO arbitre_match VALUES ('130', 'Mexique', 'Maroque', 'Assistant', '2018-06-14');
INSERT INTO arbitre_match VALUES ('190', 'Mexique', 'Maroque', 'Assistant', '2018-06-14');
INSERT INTO arbitre_match VALUES ('230', 'Mexique', 'Maroque', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('51', '230', 'Mexique', 'Maroque', '2018-06-14', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('52', '230', 'Mexique', 'Maroque', '2018-06-14', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('2018-06-14', 'Allemagne', 'Egypt', 'Quart de finale', '0', '3', '6', 'Cookie Center', 'Sier');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Allemagne', 'Egypt', 'Principal', '2018-06-14');
INSERT INTO arbitre_match VALUES ('120', 'Allemagne', 'Egypt', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('64', '120', 'Allemagne', 'Egypt', '2018-06-14', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('66', '120', 'Allemagne', 'Egypt', '2018-06-14', 'Jaune');
INSERT INTO arbitre_match VALUES ('200', 'Allemagne', 'Egypt', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('63', '200', 'Allemagne', 'Egypt', '2018-06-14', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('64', '200', 'Allemagne', 'Egypt', '2018-06-14', 'Jaune');
INSERT INTO arbitre_match VALUES ('230', 'Allemagne', 'Egypt', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('62', '230', 'Allemagne', 'Egypt', '2018-06-14', 'Rouge');

 -- Match -- 

INSERT INTO match_foot VALUES ('2018-06-14', 'Portugal', 'Grece', 'Semi-finale', '3', '2', '6', 'Cookie Center', 'Sier');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('60', 'Portugal', 'Grece', 'Principal', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('76', '60', 'Portugal', 'Grece', '2018-06-14', 'Jaune');
INSERT INTO arbitre_match VALUES ('110', 'Portugal', 'Grece', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('72', '110', 'Portugal', 'Grece', '2018-06-14', 'Rouge');
INSERT INTO arbitre_match VALUES ('180', 'Portugal', 'Grece', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('71', '180', 'Portugal', 'Grece', '2018-06-14', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('72', '180', 'Portugal', 'Grece', '2018-06-14', 'Jaune');
INSERT INTO arbitre_match VALUES ('210', 'Portugal', 'Grece', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('72', '210', 'Portugal', 'Grece', '2018-06-14', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2018-06-14', 'Autriche', 'Qatar', 'Finale', '2', '4', '6', 'Cookie Center', 'Sier');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('100', 'Autriche', 'Qatar', 'Principal', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('86', '100', 'Autriche', 'Qatar', '2018-06-14', 'Rouge');
INSERT INTO arbitre_match VALUES ('130', 'Autriche', 'Qatar', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('85', '130', 'Autriche', 'Qatar', '2018-06-14', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('81', '130', 'Autriche', 'Qatar', '2018-06-14', 'Jaune');
INSERT INTO arbitre_match VALUES ('180', 'Autriche', 'Qatar', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('84', '180', 'Autriche', 'Qatar', '2018-06-14', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('82', '180', 'Autriche', 'Qatar', '2018-06-14', 'Rouge');
INSERT INTO arbitre_match VALUES ('210', 'Autriche', 'Qatar', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('85', '210', 'Autriche', 'Qatar', '2018-06-14', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('83', '210', 'Autriche', 'Qatar', '2018-06-14', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2018-06-14', 'Yougoslavie', 'Etats-Unis', 'Match de 3e place', '5', '4', '6', 'Cookie Center', 'Sier');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('70', 'Yougoslavie', 'Etats-Unis', 'Principal', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('94', '70', 'Yougoslavie', 'Etats-Unis', '2018-06-14', 'Jaune');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('94', '70', 'Yougoslavie', 'Etats-Unis', '2018-06-14', 'Jaune');
INSERT INTO arbitre_match VALUES ('110', 'Yougoslavie', 'Etats-Unis', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('93', '110', 'Yougoslavie', 'Etats-Unis', '2018-06-14', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('95', '110', 'Yougoslavie', 'Etats-Unis', '2018-06-14', 'Jaune');
INSERT INTO arbitre_match VALUES ('200', 'Yougoslavie', 'Etats-Unis', 'Assistant', '2018-06-14');
INSERT INTO arbitre_match VALUES ('210', 'Yougoslavie', 'Etats-Unis', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('96', '210', 'Yougoslavie', 'Etats-Unis', '2018-06-14', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('93', '210', 'Yougoslavie', 'Etats-Unis', '2018-06-14', 'Jaune');

 -- Match -- 

INSERT INTO match_foot VALUES ('2018-06-14', 'Union sovietique', 'Turquie', 'Ronde de 16', '6', '5', '6', 'Cookie Center', 'Sier');

 -- Arbitre du Match -- 

INSERT INTO arbitre_match VALUES ('90', 'Union sovietique', 'Turquie', 'Principal', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('105', '90', 'Union sovietique', 'Turquie', '2018-06-14', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('101', '90', 'Union sovietique', 'Turquie', '2018-06-14', 'Jaune');
INSERT INTO arbitre_match VALUES ('140', 'Union sovietique', 'Turquie', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('103', '140', 'Union sovietique', 'Turquie', '2018-06-14', 'Rouge');
INSERT INTO arbitre_match VALUES ('180', 'Union sovietique', 'Turquie', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('105', '180', 'Union sovietique', 'Turquie', '2018-06-14', 'Jaune');
INSERT INTO arbitre_match VALUES ('250', 'Union sovietique', 'Turquie', 'Assistant', '2018-06-14');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('106', '250', 'Union sovietique', 'Turquie', '2018-06-14', 'Rouge');

 -- Sanction du match -- 

INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('102', '250', 'Union sovietique', 'Turquie', '2018-06-14', 'Rouge');
commit;


begin;
UPDATE personne 
SET pays_natal = 'Canada'
WHERE personne_id = 7;

UPDATE personne 
SET pays_natal = 'Uruguay'
WHERE personne_id = 47;

UPDATE personne 
SET pays_natal = 'Portugal'
WHERE personne_id = 97 AND personne_id = 157;

UPDATE personne 
SET pays_natal = 'Japon'
WHERE personne_id = 37;

UPDATE equipe_foot
SET placement  = 1
WHERE (nation = 'Italie' AND edition_coupe = 5) OR (nation = 'Italie' AND edition_coupe = 3);

UPDATE equipe_foot
SET placement  = 2
WHERE nation = 'Belgique' AND edition_coupe = 5;

UPDATE equipe_foot
SET placement  = 2
WHERE nation = 'Russie' AND edition_coupe = 3;

UPDATE equipe_foot 
set placement = 7
where nation = 'Russie' AND placement = 1;


UPDATE equipe_foot 
set placement = 7
where nation = 'Japon' AND placement = 1;

commit;

begin;

-- CHECK IF THEY DIDNT REPLICATE MATCH BY JUST SWITCHING NATION1, NATION2

CREATE OR REPLACE FUNCTION nation_order_trigger()
    RETURNS TRIGGER AS
    $$
    declare
    new_team_order record;
    BEGIN
    SELECT date, nation1, nation2 INTO new_team_order 
    FROM match_foot WHERE (date = NEW.date AND nation2 = NEW.nation1 AND nation1 = NEW.nation2);

    IF new_team_order IS NOT NULL THEN
    RAISE exception 'Erreur: Ce match existe deja dans la coupe';
    END IF;

    RETURN NEW;

    END;
    $$ language plpgsql;


CREATE TRIGGER match_order_insert BEFORE INSERT ON match_foot
FOR EACH ROW
EXECUTE PROCEDURE nation_order_trigger();




-- Function to lookup all player information from a team

CREATE OR REPLACE FUNCTION team_players(ed_arg int, nation_arg text)
    RETURNS TABLE (Prenom varchar(255), Nom varchar(255), Dossard INT, Position_ varchar(255),
    Equipe_Professionnelle text, Joueur_depuis text, Date_de_Naissance text)  
    
    AS
    $$
        select p.prenom, p.nom, eq.numero_dossard, eq.position,
        eq.equipe_ligue_professionnelle, j.joueur_depuis, p.ddn
        FROM joueur_equipe AS eq JOIN joueur AS j ON joueur_id = personne_id NATURAL JOIN personne p
        WHERE eq.nation = nation_arg AND eq.edition_coupe = ed_arg;
    $$ LANGUAGE SQL;


    commit;


    begin;

    CREATE OR REPLACE VIEW requete1 AS
WITH 
	finals AS (SELECT date, nation1, nation2 
		FROM Match_Foot 
		WHERE rang = 'Finale'),
	sanction1 AS (SELECT sanction_id, arbitre_id, match_date, nation_equipe_1, 
		nation_equipe_2 
		FROM Sanction),
	sanctionFinals AS (SELECT sanction_id, arbitre_id 
		FROM finals join sanction1
		ON date = match_date AND nation1 = nation_equipe_1 AND nation2 = nation_equipe_2),
	countSanctions AS (SELECT arbitre_id, COUNT(sanction_id) AS nb_sanctions 
		FROM sanctionFinals 
		GROUP BY arbitre_id),
	maxSanction AS (SELECT MAX(nb_sanctions) as max_sanctions FROM countSanctions),
	arbitre_result AS (SELECT arbitre_id 
		FROM maxSanction JOIN countSanctions 
		ON max_sanctions = nb_sanctions),
	personne1 AS (SELECT prenom, nom, personne_id FROM Personne)
SELECT nom, prenom 
FROM personne1 JOIN arbitre_result 
ON personne_id = arbitre_id;

CREATE OR REPLACE VIEW requete2 AS
SELECT nation, COUNT(placement) as nbCoupesGagnees 
FROM Equipe_Foot WHERE placement = 1
GROUP BY nation
ORDER BY nbCoupesGagnees DESC, nation;


CREATE OR REPLACE VIEW requete3 AS
WITH 
	entraineur1 AS (SELECT personne_id FROM Entraineur),
	equipe1 AS (SELECT entraineur_id, nation, edition_coupe FROM Equipe_Foot),
	entraineurs AS (SELECT personne_id, nation FROM entraineur1 JOIN equipe1 
		ON personne_id = entraineur_id),
	personne1 AS (SELECT personne_id, nom, prenom, pays_natal FROM Personne),
	result1 AS (SELECT * FROM entraineurs NATURAL JOIN personne1)
SELECT nom, prenom FROM result1
WHERE NOT nation = pays_natal
GROUP BY nom, prenom
ORDER BY nom, prenom;





CREATE OR REPLACE VIEW requete4 AS
WITH sanctions AS (SELECT sanction_id, arbitre_id, 
	nation_equipe_1, nation_equipe_2, match_date 
	FROM Sanction)
SELECT type_arbitre, COUNT(sanction_id) AS nb_sanctions 
FROM sanctions JOIN Arbitre_match 
ON match_date = date_match 
	AND nation_equipe_1 = nation1 
	AND nation_equipe_2 = nation2 
	AND sanctions.arbitre_id = Arbitre_match.arbitre_id
GROUP BY type_arbitre; 

commit;