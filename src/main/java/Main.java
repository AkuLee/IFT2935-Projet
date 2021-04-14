import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.geometry.Insets;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.ButtonBar;
import javafx.scene.control.ButtonType;
import javafx.scene.control.Dialog;
import javafx.scene.layout.GridPane;
import javafx.stage.Stage;
import javafx.scene.control.TextField;
import javafx.scene.control.Label;
import java.util.Optional;

public class Main extends Application {

    @Override
    public void start(Stage primaryStage) throws Exception{
        Parent root = FXMLLoader.load(getClass().getResource("mainWindow.fxml"));
        primaryStage.setTitle("IFT2035 - Projet");
        primaryStage.setScene(new Scene(root, 640, 400));
        primaryStage.show();
        requestLogin();

    }


    public static void main(String[] args) {
        launch(args);
    }

    public void requestLogin() {

        Dialog<String[]> dialog = new Dialog<>();
        dialog.setTitle("Connexion à la base de donnée");

        ButtonType save = new ButtonType("Enregistrer", ButtonBar.ButtonData.OK_DONE);
        dialog.getDialogPane().getButtonTypes().add(save);

        GridPane grid = new GridPane();
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(10, 10, 10, 10));

        TextField url = new TextField();
        url.setText("jdbc:postgresql://localhost:5432/projet_foot");
        url.setMinWidth(300);
        TextField username = new TextField();
        username.setText("postgres");
        TextField password = new TextField();
        password.setText("postgres");
        grid.addRow(0, new Label("URL : "), url);
        grid.addRow(1, new Label("Utilisateur : "), username );
        grid.addRow(2, new Label("Mot de passe : "), password);

        dialog.getDialogPane().setContent(grid);

        dialog.setResultConverter(dialogButton -> {
            String[] infos = new String[3];
            infos[0] = url.getText();
            infos[1] = username.getText();
            infos[2] = password.getText();
            return infos;
        });

        Optional<String[]> result = dialog.showAndWait();

        result.ifPresent(infos -> {
            Hibernate.getInstance().init(infos[0], infos[1], infos[2]);
        });
    }

}
