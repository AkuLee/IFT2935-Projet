import javax.persistence.*;

import org.hibernate.annotations.Immutable;

@Entity
@Immutable
public class TypeArbitreSanctionsView {


    private String typeArbitre;
    private int nbSanctions;

    public TypeArbitreSanctionsView() {

    }

    @Id
    @Column(name = "type_arbitre")
    public String getTypeArbitre() {
        return typeArbitre;
    }

    private void setTypeArbitre(String typeArbitre) {
        this.typeArbitre = typeArbitre;
    }

    @Column(name = "nb_sanctions")
    public int getNbSanctions() {
        return nbSanctions;
    }

    private void setNbSanctions(int nbSanctions) {
        this.nbSanctions = nbSanctions;
    }


}
