package src.main.com.example.vehicles;

public class InvalidSpeedException extends VehicleException {
    private final int invalidSpeed;

    public InvalidSpeedException(String message, int invalidSpeed) {
        super(message);
        this.invalidSpeed = invalidSpeed;
    }

    public int getInvalidSpeed() {
        return invalidSpeed;
    }
}