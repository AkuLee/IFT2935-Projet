import names, os, random

# enleve le fichier pour le refaire
os.remove("personne.sql")

# ouvre le fichier
personne = open("personne.sql", "a")

# list de pays
pays = ["Uruguay", "Italie", "France", "Canada", "Bresil", "Suisse", "Suede", "Chili",
    "Angleterre", "Mexique", "Allemagne", "Portugal", "Autriche", "Yougoslavie","Union sovietique",
    "Tchecoslovaquie", "Pologne", "Argentine", "Belgique", "Croatie", "Pays-Bas", "Coree du Sud",
    "Japon", "Russie", "Maroque", "Egypt", "Grece", "Qatar", "Etats-Unis", "Turquie"]

# creation date de naissance random
def birthday():
    ddn = random.choice([
        "1980", "1981", "1982", "1983", "1984", "1985", "1986", 
        "1987", "1988", "1989", "1990", "1991", "1992", "1993",
        "1994", "1996", "1997", "1998", "1999", "2000"
        ]) + "-" + (random.choice([
        "01", "02", "03", "04", "05", "06", "07", "08", "09", 
        "10", "11", "12"
        ]) + "-" + random.choice([
        "01", "02", "03", "04", "05", "06", "07", "08", "09",
        "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", 
        "20", "21", "22", "23", "24", "25", "26", "27", "28"]))
    return ddn

# ecrit le code SQL pour poluler la table personne
for equipe in pays:
    for id in range(50):
        nom = names.get_last_name()
        prenom = names.get_first_name(gender='male')
        sexe = 'M'
        ddn = birthday()
        mid = "', '"   
        values = "INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('" + nom + mid + prenom + mid + ddn + mid + equipe + mid + sexe + "');\n"
        personne.write(values)

personne.close()
