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
