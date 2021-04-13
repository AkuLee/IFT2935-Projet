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