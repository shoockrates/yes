package src.main.com.example.trucks;

import java.util.Arrays;
import java.io.Serializable;

public class Truck extends AbstractTruck implements Cloneable, Serializable {
    private static final long serialVersionUID = 1L;

    public static final int MAX_SPEED = 120;
    private int axles;

    private String[] ownerName;

    public Truck() {
        super();
        this.ownerName = new String[0];
    }

    public Truck(String brand, String model, int year, double cargoCapacity, int axles, String[] ownerName) {
        super(brand, model, year);
        setCargoCapacity(cargoCapacity);
        this.axles = axles;

        if (ownerName != null) {
            this.ownerName = Arrays.copyOf(ownerName, ownerName.length);
        } else {
            this.ownerName = new String[0];
        }
    }

    public String[] getOwnerName() {
        return ownerName;
    }

    public void setOwnerName(String[] ownerName) {
        if (ownerName != null) {
            this.ownerName = Arrays.copyOf(ownerName, ownerName.length); // Saugo kopiją
        } else {
            this.ownerName = new String[0];
        }
    }

    public int getAxles() {
        return axles;
    }

    public void setAxles(int axles) {
        this.axles = axles;
    }

    @Override
    public Object clone() throws CloneNotSupportedException {
        Truck clonedTruck = (Truck) super.clone();

        // START DEEP COPY
        if (this.ownerName != null) {
            clonedTruck.ownerName = Arrays.copyOf(this.ownerName, this.ownerName.length);
        } else {
            clonedTruck.ownerName = new String[0];
        }
        // END DEEP COPY

        return clonedTruck;
    }

    @Override
    public String toString() {
        String ownersString = (ownerName != null && ownerName.length > 0)
                ? Arrays.toString(ownerName)
                : "No owners listed";
        return String.format(
                "Truck: %s %s (%d), Capacity: %.1f kgs, Payload: %s, Axles: %d, Owners: %s, Total capacity: %.1f kgs, Traveled: %d kms (x), %d kms (y).",
                getBrand(), getModel(), getYear(), cargoCapacityKG,
                attachedPayload ? String.format("%.1f kgs", payloadCapacityKG) : "No",
                axles, ownersString, getCargoCapacity(), x, y);
    }
}