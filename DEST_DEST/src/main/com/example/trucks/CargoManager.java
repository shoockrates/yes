package src.main.com.example.trucks;

public interface CargoManager extends PayloadAttachable {
    void setCargoCapacity(double cargoCapacity);

    double getCargoCapacity();

    double getMaxCargoCapacity();
}