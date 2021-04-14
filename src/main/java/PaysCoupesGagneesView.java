import javax.persistence.*;

import org.hibernate.annotations.Immutable;

@Entity
@Immutable
public class PaysCoupesGagneesView {


    private String nation;
    private int nbCoupesGagnees;

    public PaysCoupesGagneesView() {

    }

    @Id
    @Column(name = "nation")
    public String getNation() {
        return nation;
    }

    private void setNation(String nation) {
        this.nation = nation;
    }

    @Column(name = "nbCoupesGagnees")
    public int getNbCoupesGagnees() {
        return nbCoupesGagnees;
    }

    private void setNbCoupesGagnees(int nbCoupesGagnees) {
        this.nbCoupesGagnees = nbCoupesGagnees;
    }


}
