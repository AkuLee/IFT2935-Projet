package projet;

import javafx.fxml.FXML;
import javafx.scene.control.Alert;
import javafx.scene.control.TextArea;

public class Controller {

    @FXML
    private TextArea textAnswer;

    @FXML
    public void question1() {
        textAnswer.setText("Réponse à la question 1");
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
                "Aku Lee ()\n" +
                "Bojan Odobasic (952514)\n" +
                "Jean-Marc Prud\'homme (20137035)\n" +
                "Jean-Daniel Toupin ()\n";
        alert.setContentText(content);
        alert.show();
    }

}
