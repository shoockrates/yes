package src.main.com.example.garage;

import src.main.com.example.vehicles.Vehicle;

import java.io.*;
import java.util.List;
import java.util.ArrayList;

public class FileHandler {

    public static Thread saveVehicles(List<Vehicle> vehicles, String filePath) {
        Runnable saveRunnable = () -> {
            try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(filePath))) {
                oos.writeObject(vehicles);
                System.out.println("Sarasas issaugotas faile: " + filePath);
            } catch (IOException e) {
                System.err.println("Klaida issaugant sarasa: " + e.getMessage());
                // e.printStackTrace();
            }
        };

        Thread saveThread = new Thread(saveRunnable);
        saveThread.start();
        return saveThread;
    }

    public static Thread loadVehicles(String filePath, List<Vehicle> vehicles) {
        Runnable loadRunnable = () -> {
            try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(filePath))) {
                Object obj = ois.readObject();
                if (obj instanceof List) {
                    List<?> loadedList = (List<?>) obj;
                    List<Vehicle> loadedVehicles = new ArrayList<>();
                    for (Object item : loadedList) {
                        if (item instanceof Vehicle) {
                            loadedVehicles.add((Vehicle) item);
                        } else {
                            System.err.println("Faile rastas ne Vehicle tipo objektas: "
                                    + (item != null ? item.getClass().getName() : "null"));
                        }
                    }

                    vehicles.clear();
                    vehicles.addAll(loadedVehicles);

                    System.out.println(
                            "Sarasas nuskaitytas is failo: " + filePath + ". Ikelta objektu: " + vehicles.size());
                } else {
                    System.err.println("Failo formatas neteisingas - nerastas List objektas.");
                }
            } catch (FileNotFoundException e) {
                System.err.println("Klaida nuskaitant sarasa: Failas nerastas (" + filePath + ")");
            } catch (IOException e) {
                System.err.println("Klaida nuskaitant sarasa: " + e.getMessage());
                // e.printStackTrace();
            } catch (ClassNotFoundException e) {
                System.err.println("Klaida nuskaitant sarasa: Nerasta objekto klase. " + e.getMessage());
                // e.printStackTrace();
            }
        };

        Thread loadThread = new Thread(loadRunnable);
        loadThread.start();
        return loadThread;
    }
}