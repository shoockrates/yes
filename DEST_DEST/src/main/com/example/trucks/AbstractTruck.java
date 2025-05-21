package src.main.com.example.trucks;

import src.main.com.example.vehicles.Vehicle;
import src.main.com.example.vehicles.InvalidSpeedException;
import java.io.Serializable; // Importuojame

public abstract class AbstractTruck extends Vehicle implements CargoManager, Serializable { // Implementuojame
                                                                                            // Serializable
    private static final long serialVersionUID = 1L; // Gera praktika

    protected double cargoCapacityKG;
    protected boolean attachedPayload = false;
    protected double maxCargoCapacityKG = 1200; // Šie bus serializuojami
    protected double maxPayloadCapacityKG = 2000; // Šie bus serializuojami
    protected double payloadCapacityKG = 0;

    public AbstractTruck() {
        super();
    }

    public AbstractTruck(String brand, String model, int year) {
        super(brand, model, year);
    }

    // ... (Likę metodai lieka tokie patys)

    @Override
    public void setCargoCapacity(double cargoCapacity) {
        if (cargoCapacity < 0)
            return;
        this.cargoCapacityKG = Math.min(cargoCapacity, maxCargoCapacityKG);
    }

    @Override
    public double getCargoCapacity() {
        return cargoCapacityKG + payloadCapacityKG;
    }

    @Override
    public double getMaxCargoCapacity() {
        return attachedPayload ? maxCargoCapacityKG + maxPayloadCapacityKG : maxCargoCapacityKG;
    }

    @Override
    public void attachPayload(double payloadCapacity) {
        this.payloadCapacityKG = Math.min(payloadCapacity, maxPayloadCapacityKG);
        this.attachedPayload = true;
    }

    @Override
    public void detachPayload() {
        this.payloadCapacityKG = 0;
        this.attachedPayload = false;
    }

    @Override
    public void driveX(boolean direction, int speed) throws InvalidSpeedException {
        if (speed < 0) {
            throw new InvalidSpeedException("Speed cannot be negative", speed);
        }
        // Naudojame Truck.MAX_SPEED, nes AbstractTruck neturi savo MAX_SPEED konstanto,
        // o Truck turi.
        // Galbūt čia turėtų būti nauja konstanta arba Vehicle.MAX_SPEED, bet sekame
        // esamą logiką.
        // Jei naudojame Truck.MAX_SPEED, reikia užtikrinti, kad Truck klasė būtų
        // pasiekiama.
        // Pakeiskime į super.MAX_SPEED arba Vehicle.MAX_SPEED, kad būtų labiau
        // abstraktu.
        // Naudojame Vehicle.MAX_SPEED kaip bendrą ribą.
        if (speed > Vehicle.MAX_SPEED) { // Pakeista iš Truck.MAX_SPEED
            throw new InvalidSpeedException("Speed exceeds maximum allowed speed of " + Vehicle.MAX_SPEED, speed);
        }
        if (!direction)
            speed *= -1;
        this.x += speed;
    }

    @Override
    public void driveY(boolean direction, int speed) throws InvalidSpeedException {
        if (speed < 0) {
            throw new InvalidSpeedException("Speed cannot be negative", speed);
        }
        if (speed > Vehicle.MAX_SPEED) { // Pakeista iš Truck.MAX_SPEED
            throw new InvalidSpeedException("Speed exceeds maximum allowed speed of " + Vehicle.MAX_SPEED, speed);
        }
        if (!direction)
            speed *= -1;
        this.y += speed;
    }
}