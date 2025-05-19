package src.main.com.example.garage;

import src.main.com.example.trucks.Truck;
import src.main.com.example.vehicles.Vehicle;
import src.main.com.example.factories.VehicleFactory;
import src.main.com.example.factories.TruckFactory;
import java.util.Arrays;

public class Garage {
    public static void main(String[] args) {
        System.out.println("--- Truck Creation using Factory Method ---");
        System.out.println("Demonstrating the Factory Method pattern for creating Vehicles (Trucks).");

        String truckBrand = "Volvo";
        String truckModel = "FH16";
        int truckYear = 2024;
        double truckCapacity = 40000.0;
        int truckAxles = 16;
        String[] initialTruckOwners = new String[] { "Factory Owner 1", "Factory Owner 2" };

        VehicleFactory truckFactory = new TruckFactory(
                truckBrand,
                truckModel,
                truckYear,
                truckCapacity,
                truckAxles,
                initialTruckOwners);

        Vehicle myTruckFromFactory = truckFactory.createVehicle();

        if (myTruckFromFactory instanceof Truck) {
            Truck createdTruck = (Truck) myTruckFromFactory;
            System.out.println("\nSuccessfully created Vehicle (Truck) using Factory Method:");
            System.out.println(createdTruck);

            System.out.println("\n--- Testing array independence after factory creation ---");
            if (initialTruckOwners != null && initialTruckOwners.length > 0) {
                System.out
                        .println("Original array content BEFORE modification: " + Arrays.toString(initialTruckOwners));
                initialTruckOwners[0] = "MODIFIED ORIGINAL ARRAY OWNER";
                System.out
                        .println("Original array content AFTER modification:  " + Arrays.toString(initialTruckOwners));
            }

            System.out.println("Created Truck Owner Array Ref:  " + createdTruck.getOwnerName());
            System.out.println("Created Truck Owner Array Content: " + Arrays.toString(createdTruck.getOwnerName()));
            System.out.println(
                    "Analysis: If the content above did NOT change, the factory correctly handled deep copying.");

        } else {
            System.out.println("\nFailed to create a Truck using the factory. Created object type: "
                    + myTruckFromFactory.getClass().getName());
        }

        System.out.println("\n" + "-".repeat(30));
        System.out.println("--- Original Truck Cloning Test (Unchanged Section) ---");
        System.out.println("-".repeat(30));

        System.out.println("--- Truck Cloning Test ---");
        System.out.println("--- IMPORTANT: Cloning behavior (Deep or Shallow for Owner Array) ---");
        System.out.println("--- is controlled by commenting/uncommenting the block within Truck.java: clone() ---");
        System.out.println("--- The block marked START_DEEP_COPY_SECTION -> END_DEEP_COPY_SECTION: ---");
        System.out.println("--- - COMMENTED OUT (default): SHALLOW clone for Owner Array ---");
        System.out.println("--- - UNCOMMENTED: DEEP clone for Owner Array ---");

        Truck originalTruck = new Truck("Freightliner", "Cascadia", 2023, 35000.0, 18,
                new String[] { "Original Owner 1 Name", "Original Owner 2 Name" });

        System.out.println("\n--- Initial State ---");
        System.out.println("Original Truck: " + originalTruck);
        System.out.println("Original Owner Array Ref: " + originalTruck.getOwnerName());
        if (originalTruck.getOwnerName() != null) {
            System.out.println("Original Owner Array Content: " + Arrays.toString(originalTruck.getOwnerName()));
        }

        try {
            Truck clonedTruck = (Truck) originalTruck.clone();

            System.out.println("\n--- After Cloning (Before Modifying Original) ---");
            System.out.println("Original Truck: " + originalTruck);
            System.out.println("Cloned Truck:   " + clonedTruck);
            System.out.println("Original Owner Array Ref: " + originalTruck.getOwnerName());
            System.out.println("Cloned Owner Array Ref:   " + clonedTruck.getOwnerName());

            System.out.println("\n--- Modifying ORIGINAL Truck's Owner Array ---");

            String[] originalOwners = originalTruck.getOwnerName();
            if (originalOwners != null && originalOwners.length > 0) {
                System.out.println("Modifying originalTruck.getOwnerName()[0]...");
                originalOwners[0] = "MODIFIED Original Owner Name";

                System.out.println("Adding a new element to originalTruck's owner array...");
                String[] updatedOriginalOwners = Arrays.copyOf(originalOwners, originalOwners.length + 1);
                updatedOriginalOwners[updatedOriginalOwners.length - 1] = "NEW Owner Added To Original";
                originalTruck.setOwnerName(updatedOriginalOwners);

            } else if (originalOwners != null && originalOwners.length == 0) {
                System.out.println("Original owner array was empty. Setting a new array on originalTruck.");
                originalTruck.setOwnerName(new String[] { "MODIFIED Original Owner Name" });
            } else {
                System.out.println("Original owner array was null. Setting a new array on originalTruck.");
                originalTruck.setOwnerName(new String[] { "MODIFIED Original Owner Name" });
            }

            System.out.println("\n--- After Modifying ORIGINAL Truck ---");
            System.out.println("Original Truck: " + originalTruck);
            System.out.println("Cloned Truck:   " + clonedTruck);

            System.out.println("\n--- Final Comparison ---");
            System.out.println("Original Owner Array Ref: " + originalTruck.getOwnerName());
            System.out.println("Original Owner Array Content: " + Arrays.toString(originalTruck.getOwnerName()));
            System.out.println("Cloned Owner Array Ref:   " + clonedTruck.getOwnerName());
            System.out.println("Cloned Owner Array Content: " + Arrays.toString(clonedTruck.getOwnerName()));

            System.out.println("\n--- Analysis ---");
            System.out.println(
                    "If Owner Array References are the SAME and content changed: SHALLOW CLONE (Truck.clone() block COMMENTED)");
            System.out.println(
                    "If Owner Array References are DIFFERENT and cloned content did NOT change: DEEP CLONE (Truck.clone() block UNCOMMENTED)");

        } catch (CloneNotSupportedException e) {
            System.err.println("Cloning failed: " + e.getMessage());
        }

        System.out.println("\n--- End of Cloning Test ---");
    }
}