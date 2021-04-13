import javafx.fxml.FXML;
import javafx.scene.control.Alert;
import javafx.scene.control.TextArea;

import java.util.Vector;

public class Controller {

    private JDBC db = JDBC.getInstance();

    @FXML
    private TextArea textAnswer;

    @FXML
    public void question1() {
        textAnswer.clear();
        textAnswer.appendText("Réponse à la question 1\n");
        db.getConnection();

        Vector<Vector> vect = db.getActors();

        for(Vector x : vect) {
            for(int i=0; i<x.size(); i++)
                if(i==x.size()-1) textAnswer.appendText(x.get(i)+";\n");
                else textAnswer.appendText(x.get(i)+", ");
        }

    }

    @FXML
    public void question2() {
        textAnswer.clear();
        textAnswer.appendText("Réponse à la question 2\n");
        Hibernate hib = new Hibernate();
        Vector<String> result;
        try {
            hib.setUp();
            result = hib.getActorNames();
            for (String s : result) {
                textAnswer.appendText(s + "\n");
            }
            hib.tearDown();
        }
            catch (Exception e)  {
            System.out.println("Erreur : " + e);
            }
    }

    @FXML
    public void question3() {
        textAnswer.setText("Réponse à la question 3");
    }

    @FXML
    public void question4() {
        textAnswer.setText("Réponse à la question 4");
    }

    @FXML
    public void quit() {
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
                "Tina Liu Lee ()\n" +
                "Bojan Odobasic (952514)\n" +
                "Jean-Marc Prud\'homme (20137035)\n" +
                "Jean-Daniel Toupin ()\n";
        alert.setContentText(content);
        alert.show();
    }

}
