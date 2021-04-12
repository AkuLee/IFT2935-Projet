import names, os, random

# enleve le fichier pour le refaire
os.remove("personne.sql")
os.remove("coupe.sql")



# sql splitter
mid = "', '" 

# list de pays
pays = ["Uruguay", "Italie", "France", "Canada", "Bresil", "Suisse", "Suede", "Chili",
    "Angleterre", "Mexique", "Allemagne", "Portugal", "Autriche", "Yougoslavie","Union sovietique",
    "Tchecoslovaquie", "Pologne", "Argentine", "Belgique", "Croatie", "Pays-Bas", "Coree du Sud",
    "Japon", "Russie", "Maroque", "Egypt", "Grece", "Qatar", "Etats-Unis", "Turquie"]

# Position possible pour les joueurs
position_jouer = ["Avant-centre", "Arriere latéral", "Millieu defensif", "Millieu offensif", "Gardien de but"]
equipe_foot_prof = ["FC Bayern", "Olympique Lyonnais", "France National","Real Madrid", "Manchester United F.C.", "Arsenal F.C.", "Chelsea F.C.",
"Brazil nationnal", "AS Monaco", "Liverpool F.C.", "Spain N.F.C.", "F.C. Barcelona"]
expertise = ["Medecin", "Physiotherapeute","Psychologue sportif", "Assistant entraineur"]
type_arbitre = ["Principal", "Assistant"]
rang_match = ["Ronde de groupe", "Ronde de 16", "Quart de finale", "Semi-finale", "Match de 3e place", "Finale"]
couleur_sanction = ["Rouge", "Jaune"]

nom_stade = ["Rocket Center", "Bob Center", "Super Field", "Fern field", "Grandios Stadium", "Cookie Center"]
ville_stade = ["Hillford", "Harmsby", "Croma", "Bobski", "Hadderfoo", "Sier"]
date_coupe_debut = ["1998-06-10", "2002-05-31", "2006-06-09", "2010-06-11", "2014-06-12", "2018-06-14"]
date_coupe_fin = ["1998-07-12", "2002-06-30", "2006-07-9", "2010-07-11", "2014-07-13", "2018-07-15"]



# creation date de naissance random
def get_random_date(start_year, end_year, start_month, end_month, start_day, end_day):
    year = str(random.randrange(start_year, end_year))
    months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", 
        "10", "11", "12"]
    days = [
        "01", "02", "03", "04", "05", "06", "07", "08", "09",
        "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", 
        "20", "21", "22", "23", "24", "25", "26", "27", "28"]
    month = random.choice(months[start_month+1:end_month+1])
    day = random.choice(days[start_day+1:end_day+1])
    ddn = year + "-" + month + "-" + day
    return ddn

# ouvre le fichier
personne = open("personne.sql", "a")
personne.write("begin;\n\n")

id_personne = 1;


# ecrit le code SQL pour poluler la table personne
for equipe in pays:
    
    for i in range(10):
        nom = names.get_last_name()
        prenom = names.get_first_name(gender='male')
        sexe = 'M'
        ddn = get_random_date(1970, 1985,1,12,1,28) 
        values = "INSERT INTO personne (nom, prenom, ddn, pays_natal, sexe) VALUES ('" + nom + mid + prenom + mid + ddn + mid + equipe + mid + sexe + "');\n"
        personne.write(values)

        if i + 1 == 7:
            profession = "INSERT INTO entraineur VALUES ('" + str(id_personne) + mid + get_random_date(1997, 2004, 1, 12, 1, 28) +  "');\n\n"
        elif (i + 1 == 8 or i + 1 == 9):
            expert = expertise[id_personne % 3]
            profession = "INSERT INTO collaborateur VALUES ('" + str(id_personne) + mid + expert + mid +  get_random_date(1997, 2004, 1, 12, 1, 28) +  "');\n\n"
        elif i + 1 == 10:
            profession = "INSERT INTO arbitre VALUES ('" + str(id_personne) + mid + get_random_date(1997, 2004, 1, 12, 1, 28) +  "');\n\n"
        else:
            profession = "INSERT INTO joueur VALUES ('" + str(id_personne) + mid + get_random_date(1997, 2004, 1, 12, 1, 28) +  "');\n\n"
        
        personne.write(profession)
        
        id_personne += 1

        
personne.write("commit;")
personne.close()



# Creation COUPE

pop_coupe = open("coupe.sql", "a")
pop_coupe.write("begin; \n\n")

for coupe in range(6):
    pop_coupe.write("\n\n  -- Coupe Du Monde  --- \n")
    # section coupe + coupe pays
    edition = coupe + 1
    date_debut = date_coupe_debut[coupe]
    date_fin = date_coupe_fin[coupe]
    pays_c = pays[coupe]

    coupe_monde = "INSERT INTO coupe_du_monde VALUES ('" + str(edition) + mid + date_debut + mid + date_fin + "');\n"
    pays_coupe = "INSERT INTO pays_coupe VALUES ('" + pays_c + mid + str(edition) + "');\n\n"
    pop_coupe.write(coupe_monde)
    pop_coupe.write(pays_coupe)


    ptr_entraineur = 7
    ptr_collab = 8
    ptr_joueur = 1

    position = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]

    ## Section equipe
    for equipe in pays:
        pop_coupe.write("\n -- EQUIPE  + Association-- \n\n")
        rand = random.randint(0, len(position) - 1)
        classement = position[rand]
        position.pop(rand)

        # Equipe foot
        equipe_foot = "INSERT INTO equipe_foot VALUES ('" + equipe + mid + str(edition) + mid +  str(ptr_entraineur) + mid+ str(classement) + "');\n"
        pop_coupe.write(equipe_foot)
        ptr_entraineur += 10


        # collaborateur_equipe
        collab_equipe = "INSERT INTO collaborateur_equipe VALUES ('" + str(ptr_collab) + mid + equipe + mid +  str(edition) + "');\n"
        pop_coupe.write(collab_equipe)
        ptr_collab += 1

        collab_equipe = "INSERT INTO collaborateur_equipe VALUES ('" + str(ptr_collab) + mid + equipe + mid +  str(edition) + "');\n"
        pop_coupe.write(collab_equipe)
        ptr_collab += 9

        # jouer_equipe
        for x in range(6):
            pos_joueur = position_jouer[x]
            num_dossard = random.randint(6*x, 10*x+1)
            equipe_prof = equipe_foot_prof[random.randint(0, len(equipe_foot_prof) - 1)]
            jouer = "INSERT INTO joueur_equipe VALUES ('" + str(x + ptr_joueur) + mid + equipe + mid +  str(edition) + mid + pos_joueur + mid + str(num_dossard) + mid + equipe_prof + "');\n"
            pop_coupe.write(jouer)
        ptr_joueur += 10
        

    ## SEction Stade
    pop_coupe.write("\n -- Stade -- \n")
    capacity = random.randrange(30000, 50000, 1000)
    anne = random.randint(1500, 1950)
    stade = "INSERT INTO stade VALUES ('" + nom_stade[coupe] + mid + ville_stade[coupe] + mid +  str(capacity) + mid + pays[coupe] + mid+ str(anne) + "');\n"
    pop_coupe.write(stade)

    # Section Match + arbitre
    for j in range(10):

        pop_coupe.write("\n -- Match -- \n\n")
        # match
        date = date_coupe_debut[coupe]
        nation_1 = pays[j + coupe]
        nation_2 = pays[j + 10 + coupe * 2]
        rang = rang_match[random.randint(0, len(rang_match)-1)]
        score_1 = random.randint(0, 5)
        score_2 = random.randint(0, 5)
        if score_1 == score_2:
            score_1 += 1

        match_foot = "INSERT INTO match_foot VALUES ('" + date + mid + nation_1 + mid + nation_2 + mid + rang + mid + str(score_1) + mid + str(score_2) + mid + str(edition) + mid + nom_stade[coupe] + mid + ville_stade[coupe] + "');\n"
        pop_coupe.write(match_foot)

        # arbitre_match
        arbitre_scope = 1;
        pop_coupe.write("\n -- Arbitre du Match -- \n\n")
        for k in range(4):
            arbitre = random.randrange((k+1) * 50 + 10, (k+2) *  50 + 10, 10)
            if k == 0:
                type_arbitre_match = type_arbitre[0]
                arbitre_scope = arbitre
            else:
                type_arbitre_match = type_arbitre[1]
            
            arbitre_match = "INSERT INTO arbitre_match VALUES ('" + str(arbitre) + mid + nation_1 + mid + nation_2 + mid + type_arbitre_match + mid + date + "');\n"

            pop_coupe.write(arbitre_match)
        
        #sanction

        for x in range(random.randint(0, 3)):

            pop_coupe.write("\n -- Sanction du match -- \n\n")
            rand_joueur = random.randint(1, 6)
            couleur = couleur_sanction[random.randint(0, 1)]
            sanction = "INSERT INTO sanction (joueur_id, arbitre_id, nation_equipe_1, nation_equipe_2, match_date, couleur) VALUES ('" + str(rand_joueur + ((j +1) * 10))+ mid + str(arbitre_scope) + mid + nation_1 + mid + nation_2 + mid + date + mid + couleur + "');\n"
            pop_coupe.write(sanction)


pop_coupe.write("commit;")
pop_coupe.close()

