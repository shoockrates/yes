package src.main.com.example.factories;

import src.main.com.example.trucks.Truck;
import src.main.com.example.vehicles.Vehicle;
import java.util.Arrays;

public class TruckFactory implements VehicleFactory {
    private String brand;
    private String model;
    private int year;
    private double cargoCapacity;
    private int axles;
    private String[] ownerName;

    public TruckFactory(String brand, String model, int year, double cargoCapacity, int axles, String[] ownerName) {
        this.brand = brand;
        this.model = model;
        this.year = year;
        this.cargoCapacity = cargoCapacity;
        this.axles = axles;
        if (ownerName != null) {
            this.ownerName = Arrays.copyOf(ownerName, ownerName.length);
        } else {
            this.ownerName = new String[0];
        }
    }

    @Override
    public Vehicle createVehicle() {
        String[] ownerNameToPass = null;
        if (this.ownerName != null) {
            ownerNameToPass = Arrays.copyOf(this.ownerName, this.ownerName.length);
        }
        return new Truck(brand, model, year, cargoCapacity, axles, ownerNameToPass);
    }
}