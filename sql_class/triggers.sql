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