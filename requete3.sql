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