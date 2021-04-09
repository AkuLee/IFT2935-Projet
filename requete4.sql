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

