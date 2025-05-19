package src.main.com.example.trucks;

import src.main.com.example.vehicles.Vehicle;
import src.main.com.example.vehicles.InvalidSpeedException;

public abstract class AbstractTruck extends Vehicle implements CargoManager {
    protected double cargoCapacityKG;
    protected boolean attachedPayload = false;
    protected double maxCargoCapacityKG = 1200;
    protected double maxPayloadCapacityKG = 2000;
    protected double payloadCapacityKG = 0;

    public AbstractTruck() {
        super();
    }

    public AbstractTruck(String brand, String model, int year) {
        super(brand, model, year);
    }

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
        if (speed > Truck.MAX_SPEED) {
            throw new InvalidSpeedException("Speed exceeds truck's maximum speed of " + Truck.MAX_SPEED, speed);
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
        if (speed > Truck.MAX_SPEED) {
            throw new InvalidSpeedException("Speed exceeds truck's maximum speed of " + Truck.MAX_SPEED, speed);
        }
        if (!direction)
            speed *= -1;
        this.y += speed;
    }
}