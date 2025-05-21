package src.main.com.example.cars;

//import src.main.com.example.vehicles.Vehicle; // Jau importuota per extends
import src.main.com.example.vehicles.InvalidSpeedException;
import src.main.com.example.vehicles.Vehicle; // Reikia aiškaus importo, net jei extends
import java.io.Serializable; // Importuojame

public class Car extends Vehicle implements Serializable { // Implementuojame Serializable
    private static final long serialVersionUID = 1L; // Gera praktika

    public static final int MAX_SPEED = 180; // Ši konstanta nėra serializuojama (static)
    private int numberOfDoors;
    public boolean boostModeActive;
    public int boostCooldown;

    public Car() {
        super();
        this.numberOfDoors = 4;
        this.boostModeActive = false;
        this.boostCooldown = 0;
    }

    public Car(String brand, String model, int year, int doors) {
        super(brand, model, year);
        this.numberOfDoors = doors;
        this.boostModeActive = false; // Pradinės būsenos
        this.boostCooldown = 0; // Pradinės būsenos
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

        // Pataisome skaičiavimą, kad netaikytų boosto kiekvienu važiavimu, jei cooldown
        // > 0
        if (boostModeActive && boostCooldown > 0) { // Boostas aktyvus ir dar neatsidarė (cooldown > 0)
            // Važiuoja įprastu greičiu, bet mažina cooldown
        } else if (boostModeActive && boostCooldown == 0) { // Boostas aktyvus ir pasibaigė cooldown
            // Šis scenarijus neturėtų įvykti, nes activateBoostMode reikalauja
            // boostCooldown == 0
            // Tiesiog važiuojam normaliu greičiu
        } else { // Boostas neaktyvus arba cooldown > 0 (turi palaukti)
            // Važiuojam normaliu greičiu
        }

        // Gal originali idėja buvo, kad boost'as trunka tam tikrą laiką?
        // Pagal esamą kodą, boostCooldown *mažėja* kiekvienu drive() kvietimu, jei > 0.
        // activateBoostMode() veikia TIK kai boostCooldown == 0.
        // Tai reiškia, kad boostModeActive = true nustatoma tik vieną kartą, kol
        // boostCooldown vėl pasieks 0.
        // Greičio padidinimas *taikomas* TIK kai boostModeActive YRA true IR
        // boostCooldown YRA 0.
        // Tai atrodo kaip vienkartinis greičio šuolis, po kurio boostCooldown tampa 5,
        // ir 5 drive() kvietimus boostModeActive yra true, bet boostCooldown > 0, todėl
        // greitis NĖRA padidintas.
        // Po 5 drive() kvietimų boostCooldown pasieks 0, ir boostModeActive bus
        // nustatytas į false.
        // Aš interpretuosiu, kad greitis padidinamas TIK kai boostModeActive yra true
        // *ir* dar nebuvo panaudotas (t.y., boostCooldown dar nebuvo nustatytas po
        // paskutinio aktyvavimo, kas nelabai atitinka boostCooldown mažėjimą).
        // Pakeisiu logiką: boost taikomas, jei boostModeActive yra true. boostCooldown
        // nustatomas, kai boostas *panaudojamas* (t.y. greitis padidinamas), o
        // mažinamas per drive() kvietimus.

        int appliedSpeed = speed;
        if (boostModeActive && boostCooldown == 0) { // Boostas aktyvus IR paruoštas naudoti
            appliedSpeed = (int) (speed * 1.5); // Padidinkim greitį 50%
            boostCooldown = 5; // Nustatom cooldown'ą (5 drive() ciklai)
        }

        if (appliedSpeed > MAX_SPEED) { // Patikriname padidintą greitį prieš MAX_SPEED
            throw new InvalidSpeedException("Speed (" + appliedSpeed + ") exceeds car's maximum speed of " + MAX_SPEED,
                    appliedSpeed);
        }

        return appliedSpeed;
    }

    private void updateBoostCooldown() {
        if (boostCooldown > 0) {
            boostCooldown--;
        } else {
            boostModeActive = false; // Išjungiame boostą, kai cooldown pasiekia 0
        }
    }

    public void activateBoostMode() {
        if (boostCooldown == 0) { // Galima aktyvuoti tik kai cooldown pasibaigęs
            boostModeActive = true;
            // boostCooldown bus nustatytas kai kitą kartą bus kviestas drive() su aktyviu
            // boostModeActive
        } else {
            System.out.println("Boost mode is on cooldown. " + boostCooldown + " drive cycles remaining.");
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
                ", Traveled: " + x + " kms (x), " + y + " kms (y).";
    }
}