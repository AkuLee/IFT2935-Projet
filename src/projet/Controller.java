package projet;

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

        if(db.getConnection() != null)
            textAnswer.appendText("le nombre des acteurs : "+db.getActorNbr() + "\n");
        textAnswer.appendText("_______________________________________\n");
        Vector<Vector> vect = db.getActors();

        for(Vector x : vect) {
            for(int i=0; i<x.size(); i++)
                if(i==x.size()-1) textAnswer.appendText(x.get(i)+";\n");
                else textAnswer.appendText(x.get(i)+", ");
        }



        textAnswer.appendText("_______________________________________\n");

        for(int i=1;i <10;i++) {
            Vector<String> v = db.getFullName(i);
            textAnswer.appendText(v.get(0)+" = "+v.get(1));

        }
    }

    @FXML
    public void question2() {
        textAnswer.setText("Réponse à la question 2");
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
