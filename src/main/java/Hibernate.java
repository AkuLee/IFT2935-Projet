import java.util.List;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;


public class Hibernate {
    private SessionFactory sessionFactory;

    private static Hibernate instance;

    static Hibernate getInstance () {
        if (instance == null) {
            instance = new Hibernate();
        }
        return instance;
    }

    private Hibernate () {

    }

    protected void init(String url, String username, String password)  {
        Configuration config = new Configuration();
        config.setProperty("hibernate.connection.driver_class","org.postgresql.Driver");
        config.setProperty("hibernate.connection.url", url);
        config.setProperty("hibernate.connection.username",username);
        config.setProperty("hibernate.connection.password",password);
        config.setProperty("hibernate.dialect","org.hibernate.dialect.PostgreSQL82Dialect");
        config.addAnnotatedClass(Personne.class);
        config.addAnnotatedClass(PaysCoupesGagneesView.class);
        config.addAnnotatedClass(TypeArbitreSanctionsView.class);

        try {
            sessionFactory = config.buildSessionFactory();
        }
        catch (Exception e) {

        }
    }

    protected void destroy()  {
        if ( sessionFactory != null ) {
            sessionFactory.close();
        }
    }

    public List<Personne> question1() {
        String query =
                "WITH finals AS (SELECT date, nation1, nation2 " +
                        "FROM Match_Foot " +
                        "WHERE rang = \'Finale\'), " +
                        "sanction1 AS (SELECT sanction_id, arbitre_id, match_date, nation_equipe_1, nation_equipe_2 " +
                        "FROM Sanction), " +
                        "sanctionFinals AS (SELECT sanction_id, arbitre_id " +
                        "FROM finals join sanction1 " +
                        "ON date = match_date AND nation1 = nation_equipe_1 AND nation2 = nation_equipe_2), " +
                        "countSanctions AS (SELECT arbitre_id, COUNT(sanction_id) AS nb_sanctions " +
                        "FROM sanctionFinals " +
                        "GROUP BY arbitre_id), " +
                        "maxSanction AS (SELECT MAX(nb_sanctions) as max_sanctions FROM countSanctions), " +
                        "arbitre_result AS (SELECT arbitre_id " +
                        "FROM maxSanction JOIN countSanctions " +
                        "ON max_sanctions = nb_sanctions), " +
                        "personne1 AS (SELECT * FROM Personne) " +
                        "SELECT personne_id, nom, prenom, ddn, pays_natal, sexe " +
                        "FROM personne1 JOIN arbitre_result " +
                        "ON personne1.personne_id = arbitre_result.arbitre_id ";


        Session session = sessionFactory.openSession();
        session.beginTransaction();

        List<Personne> result = (List<Personne>) session.createSQLQuery(query)
                .addEntity(Personne.class)
                .list();
        session.getTransaction().commit();
        session.close();
        return result;
    }


    public List<PaysCoupesGagneesView>  question2() {
        String query =
                "SELECT nation, COUNT(placement) as nbCoupesGagnees " +
                "FROM Equipe_Foot WHERE placement = 1 " +
                "GROUP BY nation " +
                "ORDER BY nbCoupesGagnees DESC, nation";


        Session session = sessionFactory.openSession();
        session.beginTransaction();

        List<PaysCoupesGagneesView> result = (List<PaysCoupesGagneesView>) session.createSQLQuery(query)
                .addEntity(PaysCoupesGagneesView.class)
                .list();
        session.getTransaction().commit();
        session.close();
        return result;
    }


    public List<Personne> question3() {

        String query =
        "WITH " +
        "entraineur1 AS (SELECT personne_id FROM Entraineur), " +
        "equipe1 AS (SELECT entraineur_id, nation, edition_coupe FROM Equipe_Foot), " +
        "entraineurs AS (SELECT personne_id, nation FROM entraineur1 JOIN equipe1 " +
        "ON personne_id = entraineur_id), " +
        "personne1 AS (SELECT personne_id, nom, prenom, ddn, pays_natal, sexe FROM Personne), " +
        "result1 AS (SELECT * FROM entraineurs NATURAL JOIN personne1) " +
        "SELECT personne_id, nom, prenom, ddn, pays_natal, sexe FROM result1 " +
        "WHERE NOT nation = pays_natal " +
        "GROUP BY personne_id, nom, prenom, ddn, pays_natal, sexe " +
        "ORDER BY nom, prenom";


        Session session = sessionFactory.openSession();
        session.beginTransaction();

        List<Personne> result = (List<Personne>) session.createSQLQuery(query)
                .addEntity(Personne.class)
                .list();
        session.getTransaction().commit();
        session.close();
        return result;
    }

    public List<TypeArbitreSanctionsView> question4() {

        String query =
                "WITH sanctions AS (SELECT sanction_id, arbitre_id, " +
                "nation_equipe_1, nation_equipe_2, match_date " +
        "FROM Sanction) " +
        "SELECT type_arbitre, COUNT(sanction_id) AS nb_sanctions " +
        "FROM sanctions JOIN Arbitre_match " +
        "ON match_date = date_match " +
        "AND nation_equipe_1 = nation1 " +
        "AND nation_equipe_2 = nation2 " +
        "AND sanctions.arbitre_id = Arbitre_match.arbitre_id " +
        "GROUP BY type_arbitre ";


        Session session = sessionFactory.openSession();
        session.beginTransaction();

        List<TypeArbitreSanctionsView> result = (List<TypeArbitreSanctionsView>) session.createSQLQuery(query)
                .addEntity(TypeArbitreSanctionsView.class)
                .list();
        session.getTransaction().commit();
        session.close();
        return result;
    }
}
