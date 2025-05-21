package src.main.com.example.garage; // Galima perkelti į src/main/com/example/data, jei norima

import src.main.com.example.vehicles.Vehicle;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Valdo transporto priemonių duomenų išsaugojimą ir nuskaitymą iš dvejetainių failų
 * naudojant Object Serialization ir atskiras gijas.
 */
public class VehicleDataManager {

    private static final String FILE_NAME = "vehicles.dat";

    /**
     * Išsaugo Vehicle objektų sąrašą į dvejetainį failą atskiroje gijoje.
     * Po išsaugojimo operacijos pabaigos, onComplete Runnable yra vykdomas.
     * Tai simuliuoja `SwingUtilities.invokeLater` elgesį, skirtą pranešti pagrindinei (pvz., UI) gijai.
     *
     * @param vehicles Sąrašas transporto priemonių, kurias reikia išsaugoti.
     * @param onComplete Runnable objektas, kuris bus vykdomas "UI gijoje" po išsaugojimo operacijos.
     *                   Gali būti null, jei pranešimo nereikia.
     */
    public static void saveVehicles(List<Vehicle> vehicles, Runnable onComplete) {
        // Sukuriame naują giją, kuri vykdys išsaugojimo operaciją
        new Thread(() -> {
            try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(FILE_NAME))) {
                oos.writeObject(vehicles); // Įrašo visą sąrašą objektų
                System.out.println("[Duomenų Gija] Transporto priemonės sėkmingai išsaugotos į " + FILE_NAME);
            } catch (IOException e) {
                System.err.println("[Duomenų Gija] Klaida išsaugant transporto priemones: " + e.getMessage());
                e.printStackTrace();
            } finally {
                // Vykdomas atgalinis ryšys pagrindinėje gijoje, simuliuojant UI atnaujinimą
                if (onComplete != null) {
                    // Realioje Swing programoje: SwingUtilities.invokeLater(onComplete);
                    System.out.println("[Duomenų Gija] Išsaugojimo operacija baigta. Vykdomas atgalinis ryšys.");
                    onComplete.run(); // Šioje konsolės demonstracijoje tiesiogiai paleidžiame
                }
            }
        }, "SaveThread").start(); // Suteikiame gijai pavadinimą, kad būtų lengviau derinti
    }

    /**
     * Nuskaito Vehicle objektų sąrašą iš dvejetainio failo atskiroje gijoje.
     * Nuskaitymo rezultatas perduodamas atgal per LoadCallback sąsają.
     * Tai simuliuoja `SwingUtilities.invokeLater` elgesį, skirtą perduoti duomenis pagrindinei (pvz., UI) gijai.
     *
     * @param callback LoadCallback egzempliorius, kuris gaus nuskaitytas transporto priemones "UI gijoje".
     *                 Privalo būti nenulinis.
     */
    public static void loadVehicles(LoadCallback callback) {
        if (callback == null) {
            System.err.println("[VehicleDataManager] LoadCallback negali būti null.");
            return;
        }

        // Sukuriame naują giją, kuri vykdys nuskaitymo operaciją
        new Thread(() -> {
            List<Vehicle> loadedVehicles = null;
            try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(FILE_NAME))) {
                loadedVehicles = (List<Vehicle>) ois.readObject(); // Nuskaito visą sąrašą objektų
                System.out.println("[Duomenų Gija] Transporto priemonės sėkmingai nuskaitytos iš " + FILE_NAME);
            } catch (FileNotFoundException e) {
                System.err.println("[Duomenų Gija] Failas nerastas: " + FILE_NAME + ". Grąžinamas tuščias sąrašas.");
                loadedVehicles = new ArrayList<>(); // Grąžina tuščią sąrašą, jei failas dar neegzistuoja
            } catch (IOException e) {
                System.err.println("[Duomenų Gija] Klaida nuskaitant transporto priemones: " + e.getMessage());
                e.printStackTrace();
                loadedVehicles = new ArrayList<>(); // Grąžina tuščią sąrašą ir esant kitoms I/O klaidoms
            } catch (ClassNotFoundException e) {
                System.err.println("[Duomenų Gija] Klasė nerasta įkėlimo metu: " + e.getMessage());
                e.printStackTrace();
                loadedVehicles = new ArrayList<>(); // Grąžina tuščią sąrašą, jei klasė nerasta
            } finally {
                // Vykdomas atgalinis ryšys pagrindinėje gijoje, simuliuojant UI atnaujinimą
                // Realioje Swing programoje: SwingUtilities.invokeLater(() -> callback.onLoadComplete(loadedVehicles));
                System.out.println("[Duomenų Gija] Nuskaitymo operacija baigta. Vykdomas atgalinis ryšys.");
                callback.onLoadComplete(loadedVehicles); // Šioje konsolės demonstracijoje tiesiogiai paleidžiame
            }
        }, "LoadThread").start(); // Suteikiame gijai pavadinimą
    }

    /**
     * Atgalinio ryšio (callback) sąsaja, skirta asinchroniniams nuskaitymo rezultatams.
     * Tai simuliuoja mechanizmą, skirtą duomenims perduoti atgal į "UI giją" po nuskaitymo pabaigos.
     */
    public interface LoadCallback {
        /**
         * Kviečiamas, kai nuskaitymo operacija baigta.
         *
         * @param vehicles Sąrašas nuskaitytų transporto priemonių. Gali būti null arba tuščias,
         *                 jei įvyko klaida arba failas nebuvo rastas.
         */
        void onLoadComplete(List<Vehicle> vehicles);
    }
}