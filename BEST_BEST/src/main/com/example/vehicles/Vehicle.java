package src.main.com.example.vehicles;

public class Vehicle {
    private String brand;
    private String model;
    private int year;
    int defaultSpeed = 10;
    private final String type = "Light vehicle";
    public static final int MAX_SPEED = 160;
    private static int vehicleCount = 0;
    protected int x = 0;
    protected int y = 0;

    public Vehicle() {
        this("", "", 0);
    }

    public Vehicle(String brand, String model, int year) {
        this.brand = brand;
        this.model = model;
        this.year = year;
        ++vehicleCount;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public final String getType() {
        return type;
    }

    public static int getVehicleCount() {
        return vehicleCount;
    }

    public void driveX(boolean direction) {
        if (!direction) {
            this.x += defaultSpeed * -1;
        } else {
            this.x += defaultSpeed;
        }
    }

    public void driveY(boolean direction) {
        if (!direction) {
            this.x += defaultSpeed * -1;
        } else {
            this.x += defaultSpeed;
        }
    }

    public void driveX(boolean direction, int speed) throws InvalidSpeedException {
        if (speed < 0) {
            throw new InvalidSpeedException("Speed cannot be negative", speed);
        }
        if (speed > MAX_SPEED) {
            throw new InvalidSpeedException("Speed exceeds maximum allowed speed of " + MAX_SPEED, speed);
        }
        if (!direction)
            speed *= -1;
        this.x += speed;
    }

    public void driveY(boolean direction, int speed) throws InvalidSpeedException {
        if (speed < 0) {
            throw new InvalidSpeedException("Speed cannot be negative", speed);
        }
        if (speed > MAX_SPEED) {
            throw new InvalidSpeedException("Speed exceeds maximum allowed speed of " + MAX_SPEED, speed);
        }
        if (!direction)
            speed *= -1;
        this.y += speed;
    }

    public String toString() {
        return "Vehicle Info: " + brand + " " + model + " (" + year +
                ") Type: " + type + " and it traveled " + x + " kms. on x axis and " + y + " kms. on y axis.";
    }
}