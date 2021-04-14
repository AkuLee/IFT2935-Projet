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