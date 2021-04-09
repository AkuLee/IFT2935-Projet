SELECT nation, COUNT(placement) as nbCoupesGagnees 
FROM Equipe_Foot WHERE placement = 1
GROUP BY nation
ORDER BY nbCoupesGagnees DESC, nation;