package src.main.com.example.garage;

import src.main.com.example.vehicles.Vehicle;
import src.main.com.example.cars.Car;
import src.main.com.example.trucks.Truck;
import src.main.com.example.vehicles.InvalidSpeedException;

import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.*;
import java.util.ArrayList;
import java.util.List;

import javax.swing.SwingWorker;

public class GarageGUI extends JFrame {

    private DefaultListModel<Vehicle> vehicleListModel;
    private JList<Vehicle> vehicleJList;
    private JLabel statusLabel;
    private JButton saveButton;
    private JButton loadButton;

    private static final String FILE_EXTENSION = "dat";

    public GarageGUI() {
        setTitle("Automobilių ir Sunkvežimių Garažas");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(600, 400);
        setLocationRelativeTo(null);

        setLayout(new BorderLayout());

        vehicleListModel = new DefaultListModel<>();
        vehicleJList = new JList<>(vehicleListModel);
        JScrollPane scrollPane = new JScrollPane(vehicleJList);
        add(scrollPane, BorderLayout.CENTER);

        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));

        JButton addCarButton = new JButton("Pridėti automobilį");
        JButton addTruckButton = new JButton("Pridėti sunkvežimį");
        saveButton = new JButton("Išsaugoti sąrašą");
        loadButton = new JButton("Nuskaityti sąrašą");
        JButton exitButton = new JButton("Išeiti");

        buttonPanel.add(addCarButton);
        buttonPanel.add(addTruckButton);
        buttonPanel.add(saveButton);
        buttonPanel.add(loadButton);
        buttonPanel.add(exitButton);

        add(buttonPanel, BorderLayout.NORTH);

        statusLabel = new JLabel("Paruošta.", SwingConstants.CENTER);
        add(statusLabel, BorderLayout.SOUTH);

        addCarButton.addActionListener(e -> addVehicle("car"));
        addTruckButton.addActionListener(e -> addVehicle("truck"));
        saveButton.addActionListener(e -> saveVehicleList());
        loadButton.addActionListener(e -> loadVehicleList());
        exitButton.addActionListener(e -> System.exit(0));

        setVisible(true);
    }

    private void addVehicle(String type) {
        if ("car".equals(type)) {
            AddCarDialog carDialog = new AddCarDialog(this);
            carDialog.setVisible(true);

            Car newCar = carDialog.getCar();
            if (newCar != null) {
                vehicleListModel.addElement(newCar);
                statusLabel.setText("Pridėtas naujas automobilis: " + newCar.getModel());
            }

        } else if ("truck".equals(type)) {
            AddTruckDialog truckDialog = new AddTruckDialog(this);
            truckDialog.setVisible(true);

            Truck newTruck = truckDialog.getTruck();
            if (newTruck != null) {
                vehicleListModel.addElement(newTruck);
                statusLabel.setText("Pridėtas naujas sunkvežimis: " + newTruck.getModel());
            }
        }
    }

    private void saveVehicleList() {
        JFileChooser fileChooser = new JFileChooser();
        fileChooser.setDialogTitle("Išsaugoti transporto priemonių sąrašą");
        fileChooser.setSelectedFile(new File("vehicles." + FILE_EXTENSION));
        fileChooser.setFileFilter(new FileNameExtensionFilter("Data Files (*." + FILE_EXTENSION + ")", FILE_EXTENSION));

        int userSelection = fileChooser.showSaveDialog(this);

        if (userSelection == JFileChooser.APPROVE_OPTION) {
            File fileToSave = fileChooser.getSelectedFile();
            if (!fileToSave.getPath().toLowerCase().endsWith("." + FILE_EXTENSION)) {
                fileToSave = new File(fileToSave.getPath() + "." + FILE_EXTENSION);
            }

            if (fileToSave.exists()) {
                int confirm = JOptionPane.showConfirmDialog(this,
                        "Failas '" + fileToSave.getName() + "' jau egzistuoja. Perrašyti?",
                        "Patvirtinimas", JOptionPane.YES_NO_OPTION);
                if (confirm != JOptionPane.YES_OPTION) {
                    statusLabel.setText("Išsaugojimas atšauktas.");
                    return;
                }
            }

            List<Vehicle> vehiclesToSave = new ArrayList<>();
            for (int i = 0; i < vehicleListModel.size(); i++) {
                vehiclesToSave.add(vehicleListModel.getElementAt(i));
            }

            SaveWorker saveWorker = new SaveWorker(vehiclesToSave, fileToSave.getPath());
            saveWorker.execute();
        } else {
            statusLabel.setText("Išsaugojimas atšauktas.");
        }
    }

    private void loadVehicleList() {
        JFileChooser fileChooser = new JFileChooser();
        fileChooser.setDialogTitle("Nuskaityti transporto priemonių sąrašą");
        fileChooser.setFileFilter(new FileNameExtensionFilter("Data Files (*." + FILE_EXTENSION + ")", FILE_EXTENSION));

        int userSelection = fileChooser.showOpenDialog(this);

        if (userSelection == JFileChooser.APPROVE_OPTION) {
            File fileToLoad = fileChooser.getSelectedFile();

            if (!fileToLoad.exists()) {
                JOptionPane.showMessageDialog(this, "Failas nerastas: " + fileToLoad.getPath(), "Klaida",
                        JOptionPane.ERROR_MESSAGE);
                statusLabel.setText("Nuskaitymas nepavyko: failas nerastas.");
                return;
            }

            LoadWorker loadWorker = new LoadWorker(fileToLoad.getPath());
            loadWorker.execute();
        } else {
            statusLabel.setText("Nuskaitymas atšauktas.");
        }
    }

    private class SaveWorker extends SwingWorker<Void, Void> {

        private List<Vehicle> vehiclesToSave;
        private String filePath;
        private boolean saveSuccessful = false;

        public SaveWorker(List<Vehicle> vehicles, String filePath) {
            this.vehiclesToSave = vehicles;
            this.filePath = filePath;
            saveButton.setEnabled(false);
            loadButton.setEnabled(false);
            statusLabel.setText("Išsaugoma...");
        }

        @Override
        protected Void doInBackground() throws Exception {
            try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(filePath))) {
                oos.writeObject(vehiclesToSave);
                saveSuccessful = true;
            } catch (IOException e) {
                throw new Exception("Klaida išsaugant sąrašą: " + e.getMessage(), e);
            }
            return null;
        }

        @Override
        protected void done() {
            try {
                get();
                if (saveSuccessful) {
                    statusLabel.setText("Sąrašas sėkmingai išsaugotas: " + filePath);
                }
            } catch (Exception e) {
                statusLabel.setText("Išsaugojimas nepavyko.");
                JOptionPane.showMessageDialog(GarageGUI.this,
                        e.getMessage(),
                        "Išsaugojimo klaida",
                        JOptionPane.ERROR_MESSAGE);
                e.printStackTrace();
            } finally {
                saveButton.setEnabled(true);
                loadButton.setEnabled(true);
            }
        }
    }

    private class LoadWorker extends SwingWorker<List<Vehicle>, Void> {

        private String filePath;

        public LoadWorker(String filePath) {
            this.filePath = filePath;
            saveButton.setEnabled(false);
            loadButton.setEnabled(false);
            statusLabel.setText("Nuskaitoma...");
        }

        @Override
        protected List<Vehicle> doInBackground() throws Exception {
            List<Vehicle> loadedVehicles = new ArrayList<>();
            try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(filePath))) {
                Object obj = ois.readObject();
                if (obj instanceof List) {
                    List<?> loadedList = (List<?>) obj;
                    for (Object item : loadedList) {
                        if (item instanceof Vehicle) {
                            loadedVehicles.add((Vehicle) item);
                        } else {
                            System.err.println("Faile rastas ne Vehicle tipo objektas ir ignoruotas: "
                                    + (item != null ? item.getClass().getName() : "null"));
                        }
                    }
                } else {
                    throw new Exception("Failo formatas neteisingas - nerastas List objektas.");
                }
                return loadedVehicles;
            } catch (FileNotFoundException e) {
                throw new Exception("Klaida nuskaitant sąrašą: Failas nerastas (" + filePath + ")", e);
            } catch (IOException e) {
                throw new Exception("Klaida nuskaitant sąrašą: " + e.getMessage(), e);
            } catch (ClassNotFoundException e) {
                throw new Exception("Klaida nuskaitant sąrašą: Nerasta objekto klasė (" + e.getMessage() + ")", e);
            }
        }

        @Override
        protected void done() {
            try {
                List<Vehicle> loadedList = get();
                vehicleListModel.clear();
                for (Vehicle v : loadedList) {
                    vehicleListModel.addElement(v);
                }
                statusLabel.setText(
                        "Sąrašas sėkmingai nuskaitytas iš: " + filePath + ". Ikelta objektų: " + loadedList.size());
            } catch (Exception e) {
                statusLabel.setText("Nuskaitymas nepavyko.");
                JOptionPane.showMessageDialog(GarageGUI.this,
                        e.getMessage(),
                        "Nuskaitymo klaida",
                        JOptionPane.ERROR_MESSAGE);
                e.printStackTrace();
            } finally {
                saveButton.setEnabled(true);
                loadButton.setEnabled(true);
            }
        }
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                new GarageGUI();
            }
        });
    }
}