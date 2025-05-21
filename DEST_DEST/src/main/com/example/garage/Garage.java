package src.main.com.example.garage;

import src.main.com.example.vehicles.Vehicle;
import src.main.com.example.cars.Car;
import src.main.com.example.trucks.Truck;
import src.main.com.example.vehicles.InvalidSpeedException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.io.FileNotFoundException; // Failo nuskaitymo klaidai

public class Garage {
    public static void main(String[] args) {

        // Vietoj originalaus kodo, įvedame meniu ir sąrašo tvarkymą
        List<Vehicle> vehicleList = new ArrayList<>();
        Scanner scanner = new Scanner(System.in);
        String filePath = "vehicles.dat"; // Failo pavadinimas išsaugojimui/nuskaitymui
        boolean running = true;

        System.out.println("Automobilių ir sunkvežimių garažas - Valdymo meniu");

        while (running) {
            System.out.println("\nMENIU:");
            System.out.println("1. Prideti automobili");
            System.out.println("2. Prideti sunkvezimi");
            System.out.println("3. Issaugoti sarasa");
            System.out.println("4. Nuskaityti sarasa");
            System.out.println("5. Rodyti visus transporto priemones");
            // Galite pridėti 6. Testuoti važiavimą, 7. Aktyvuoti boostą (Car), 8.
            // Pritvirtinti/nuimti krovinį (Truck)
            System.out.println("6. Iseiti");

            System.out.print("Pasirinkite veiksma: ");
            String choice = scanner.nextLine();

            try { // Pridėtas try/catch blokas skaitymo klaidoms (pvz., parseInt)

                switch (choice) {
                    case "1": // Add Car
                        System.out.print("Iveskite gamintoja (Brand): ");
                        String carBrand = scanner.nextLine();
                        System.out.print("Modelis: ");
                        String carModel = scanner.nextLine();
                        System.out.print("Metai: ");
                        int carYear = Integer.parseInt(scanner.nextLine());
                        System.out.print("Duru skaicius: ");
                        int carDoors = Integer.parseInt(scanner.nextLine());

                        Car newCar = new Car(carBrand, carModel, carYear, carDoors);
                        vehicleList.add(newCar);
                        System.out.println("Automobilis pridėtas.");
                        break;

                    case "2": // Add Truck
                        System.out.print("Iveskite gamintoja (Brand): ");
                        String truckBrand = scanner.nextLine();
                        System.out.print("Modelis: ");
                        String truckModel = scanner.nextLine();
                        System.out.print("Metai: ");
                        int truckYear = Integer.parseInt(scanner.nextLine());
                        System.out.print("Krovinio talpa (kg): ");
                        double truckCapacity = Double.parseDouble(scanner.nextLine());
                        System.out.print("Asiu skaicius: ");
                        int truckAxles = Integer.parseInt(scanner.nextLine());
                        // Meniu supaprastintas, savininku masyvas pridedamas tuščias arba null
                        // (naudojant konstruktorių be ownerName)
                        // Jei norite, galite pridėti savininkų įvedimą, bet tai sudėtingiau per
                        // konsolę.
                        // Truck newTruck = new Truck(truckBrand, truckModel, truckYear, truckCapacity,
                        // truckAxles, new String[0]); // Tuščias savininkų sąrašas
                        Truck newTruck = new Truck(truckBrand, truckModel, truckYear, truckCapacity, truckAxles, null); // Konstruktorius
                                                                                                                        // tvarkys
                                                                                                                        // null
                        vehicleList.add(newTruck);
                        System.out.println("Sunkvežimis pridėtas.");
                        break;

                    case "3": // Save List
                        System.out.println("Issaugoma i faila...");
                        Thread saveThread = FileHandler.saveVehicles(vehicleList, filePath);
                        try {
                            saveThread.join(); // Laukiame, kol gija baigs darbą
                        } catch (InterruptedException e) {
                            System.err.println("Issaugojimo gija nutraukta: " + e.getMessage());
                        }
                        break;

                    case "4": // Load List
                        System.out.println("Nuskaitoma is failo...");
                        Thread loadThread = FileHandler.loadVehicles(filePath, vehicleList);
                        try {
                            loadThread.join(); // Laukiame, kol gija baigs darbą
                        } catch (InterruptedException e) {
                            System.err.println("Nuskaitymo gija nutraukta: " + e.getMessage());
                        }
                        break;

                    case "5": // Show all
                        if (vehicleList.isEmpty()) {
                            System.out.println("Sarasas tuscias.");
                        } else {
                            System.out.println("\n--- Transporto priemonių sąrašas ---");
                            for (int i = 0; i < vehicleList.size(); i++) {
                                Vehicle v = vehicleList.get(i);
                                System.out.println((i + 1) + ". " + v.toString());
                                // Galite pridėti specifinės informacijos pagal tipą, jei reikia
                                if (v instanceof Car) {
                                    Car c = (Car) v;
                                    System.out.println("   (" + c.getNumberOfDoors() + " durys, Boost: "
                                            + (c.boostModeActive ? "Aktyvus" : "Neaktyvus") + ", Cooldown: "
                                            + c.boostCooldown + ")"); // Prieiga prie būsenos
                                } else if (v instanceof Truck) {
                                    Truck t = (Truck) v;
                                    System.out.println("   (" + t.getAxles() + " ašys, Krovinys: "
                                            + t.getCargoCapacity() + "kg, Max: " + t.getMaxCargoCapacity() + "kg)");
                                }
                            }
                            System.out.println("------------------------------------");
                        }
                        break;

                    case "6": // Exit
                        running = false;
                        System.out.println("Programa baigia darba.");
                        break;

                    default:
                        System.out.println("Neteisingas pasirinkimas. Bandykite dar karta.");
                        break;
                }
            } catch (NumberFormatException e) {
                System.err.println("Neteisingas skaičiaus formatas: " + e.getMessage());
            } catch (Exception e) { // Bendras gaudytojas netikėtoms klaidoms
                System.err.println("Įvyko klaida: " + e.getMessage());
                // e.printStackTrace();
            }
        }

        scanner.close();
    }
}