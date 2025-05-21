package src.main.com.example.garage;

import src.main.com.example.vehicles.Vehicle;
import src.main.com.example.cars.Car;
import src.main.com.example.trucks.Truck;

import javax.swing.table.AbstractTableModel;
import java.util.List;
import java.util.ArrayList;

public class VehicleTableModel extends AbstractTableModel {

    private List<Vehicle> vehicles;
    private final String[] columnNames = { "Tipas", "Gamintojas", "Modelis", "Metai", "Spec. Info" };

    public VehicleTableModel(List<Vehicle> vehicles) {

        this.vehicles = vehicles;
    }

    public void setVehicles(List<Vehicle> vehicles) {
        this.vehicles = vehicles;
        fireTableDataChanged();
    }

    public List<Vehicle> getVehicles() {
        return vehicles;
    }

    @Override
    public int getRowCount() {
        return vehicles.size();
    }

    @Override
    public int getColumnCount() {
        return columnNames.length;
    }

    @Override
    public String getColumnName(int column) {
        return columnNames[column];
    }

    @Override
    public Object getValueAt(int rowIndex, int columnIndex) {
        if (rowIndex < 0 || rowIndex >= vehicles.size()) {
            return null;
        }

        Vehicle vehicle = vehicles.get(rowIndex);

        switch (columnIndex) {
            case 0:
                return vehicle.getClass().getSimpleName(); // Arba vehicle.getType() jei norite "Light vehicle"
            case 1:
                return vehicle.getBrand();
            case 2:
                return vehicle.getModel();
            case 3:
                return vehicle.getYear();

            case 4:
                if (vehicle instanceof Car) {
                    Car car = (Car) vehicle;
                    return car.getNumberOfDoors() + " durys, Boost: " + (car.boostModeActive ? "Aktyvus" : "Neaktyvus")
                            + ", Cooldown: " + car.boostCooldown; // Prieiga prie viešų ar package-private būsenų
                } else if (vehicle instanceof Truck) {
                    Truck truck = (Truck) vehicle;
                    return truck.getAxles() + " ašys, Talpa: " + truck.getCargoCapacity() + "kg";
                }
                return "";
            default:
                return null;
        }
    }

    public void addVehicle(Vehicle vehicle) {
        vehicles.add(vehicle);
        fireTableRowsInserted(vehicles.size() - 1, vehicles.size() - 1);
    }

    public void updateList(List<Vehicle> newList) {
        this.vehicles = newList;
        fireTableDataChanged();
    }
}