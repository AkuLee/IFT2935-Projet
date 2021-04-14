import javafx.fxml.FXML;
import javafx.scene.control.Alert;
import javafx.scene.control.TextArea;


import java.util.List;

public class Controller {

    Hibernate hib = Hibernate.getInstance();

    @FXML
    private TextArea textAnswer;

    @FXML
    public void question1() {

        textAnswer.clear();
        textAnswer.appendText("Question 1\n\nDonner le nom et le prénom de l\'arbitre qui a donné le plus de \n" +
                        "sanctions pendant les matchs de finale.\n\n" +
                "Réponse\n\n");
        List<Personne> result;
        try {
            result = hib.question1();
            for (Personne p : result) {
                textAnswer.appendText(p.getNom() + ", " + p.getPrenom() + "\n");
            }
        }
        catch (Exception e)  {
            System.out.println("Erreur : " + e);
        }
    }

    @FXML
    public void question2() {
        textAnswer.clear();
        textAnswer.appendText("Question 2\n\nPlacer les nations en ordre décroissant du nombre de coupes \n" +
                "du monde gagnées.\n\n" +
                "Réponse\n\n");
        List<PaysCoupesGagneesView> result;
        try {
            result = hib.question2();
            for (PaysCoupesGagneesView p : result) {
                textAnswer.appendText(p.getNation() + " : " + p.getNbCoupesGagnees() + "\n");
            }
        }
        catch (Exception e)  {
            System.out.println("Erreur : " + e);
        }
    }

    @FXML
    public void question3() {
        textAnswer.clear();
        textAnswer.appendText("Question 3\n\nDonner le nom et prénom des entraîneurs qui entraînaient \n" +
               "une équipe d’une nation autre que son pays natal.\n\n" +
                "Réponse\n\n");
        List<Personne> result;
        try {
            result = hib.question3();
            for (Personne p : result) {
                textAnswer.appendText(p.getNom() + ", " + p.getPrenom() + "\n");
            }
        }
        catch (Exception e)  {
            System.out.println("Erreur : " + e);
        }
    }

    @FXML
    public void question4() {
        textAnswer.clear();
        textAnswer.appendText("Question 4\n\nCombien de sanctions ont été données par des arbitres assistants \n"
                + "et par des arbitres principaux ?\n\n" +
                "Réponse\n\n");
        List<TypeArbitreSanctionsView> result;
        try {
            result = hib.question4();
            for (TypeArbitreSanctionsView p : result) {
                textAnswer.appendText(p.getTypeArbitre() + " : " + p.getNbSanctions() + "\n");
            }
        }
        catch (Exception e)  {
            System.out.println("Erreur : " + e);
        }
    }

    @FXML
    public void quit() {
        Hibernate.getInstance().destroy();
        System.exit(0);
    }

    @FXML
    public void clear() {
        textAnswer.clear();
    }

    @FXML
    public void help() {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle("À propos");
        alert.setHeaderText("Projet du cours IFT2035 Hiver 2021");
        String content ="Ce projet a été remis par :\n" +
                "Tina Liu Lee (20092684)\n" +
                "Bojan Odobasic (952514)\n" +
                "Jean-Marc Prud\'homme (20137035)\n" +
                "Jean-Daniel Toupin (20046724)\n";
        alert.setContentText(content);
        alert.show();
    }

}
