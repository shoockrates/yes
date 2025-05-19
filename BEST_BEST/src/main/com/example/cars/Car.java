package src.main.com.example.cars;

import src.main.com.example.vehicles.Vehicle;
import src.main.com.example.vehicles.InvalidSpeedException;

public class Car extends Vehicle {
    public static final int MAX_SPEED = 180;
    private int numberOfDoors;
    private boolean boostModeActive;
    private int boostCooldown;

    public Car() {
        super();
        this.numberOfDoors = 4;
        this.boostModeActive = false;
        this.boostCooldown = 0;
    }

    public Car(String brand, String model, int year, int doors) {
        super(brand, model, year);
        this.numberOfDoors = doors;
        this.boostModeActive = false;
        this.boostCooldown = 0;
    }

    @Override
    public void driveX(boolean direction, int speed) throws InvalidSpeedException {
        int effectiveSpeed = calculateEffectiveSpeed(speed);
        if (!direction)
            effectiveSpeed *= -1;
        this.x += effectiveSpeed;
        updateBoostCooldown();
    }

    @Override
    public void driveY(boolean direction, int speed) throws InvalidSpeedException {
        int effectiveSpeed = calculateEffectiveSpeed(speed);
        if (!direction)
            effectiveSpeed *= -1;
        this.y += effectiveSpeed;
        updateBoostCooldown();
    }

    private int calculateEffectiveSpeed(int speed) throws InvalidSpeedException {
        if (speed < 0) {
            throw new InvalidSpeedException("Speed cannot be negative", speed);
        }

        if (boostModeActive && boostCooldown == 0) {
            speed *= 50.5;
            boostCooldown = 5;
        }

        if (speed > MAX_SPEED) {
            throw new InvalidSpeedException("Speed exceeds car's maximum speed of " + MAX_SPEED, speed);
        }

        return speed;
    }

    private void updateBoostCooldown() {
        if (boostCooldown > 0) {
            boostCooldown--;
        } else {
            boostModeActive = false;
        }
    }

    public void activateBoostMode() {
        if (boostCooldown == 0) {
            boostModeActive = true;
        }
    }

    public int getNumberOfDoors() {
        return numberOfDoors;
    }

    public void setNumberOfDoors(int doors) {
        this.numberOfDoors = doors;
    }

    @Override
    public String toString() {
        return "Car: " + getBrand() + " " + getModel() +
                ", Doors: " + numberOfDoors + ", Year: " + getYear() +
                ", Boost Mode: " + (boostModeActive ? "Active" : "Inactive") +
                ", Cooldown: " + boostCooldown +
                " and it traveled " + x + " kms. on x axis and " + y + " kms. on y axis.";
    }
}