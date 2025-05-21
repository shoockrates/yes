package src.main.com.example.garage;

import src.main.com.example.trucks.Truck;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Arrays;

public class AddTruckDialog extends JDialog implements ActionListener {

    private JTextField brandField, modelField, yearField, capacityField, axlesField;
    private JButton okButton, cancelButton;
    private Truck truck;

    public AddTruckDialog(Frame owner) {
        super(owner, "Pridėti sunkvežimį", true);

        truck = null;

        setLayout(new BorderLayout());
        JPanel inputPanel = new JPanel(new GridLayout(5, 2, 5, 5));

        // Įvesties laukai
        inputPanel.add(new JLabel("Gamintojas (Brand):"));
        brandField = new JTextField();
        inputPanel.add(brandField);

        inputPanel.add(new JLabel("Modelis:"));
        modelField = new JTextField();
        inputPanel.add(modelField);

        inputPanel.add(new JLabel("Metai:"));
        yearField = new JTextField();
        inputPanel.add(yearField);

        inputPanel.add(new JLabel("Krovinio talpa (kg):"));
        capacityField = new JTextField();
        inputPanel.add(capacityField);

        inputPanel.add(new JLabel("Ašių skaičius:"));
        axlesField = new JTextField();
        inputPanel.add(axlesField);

        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        okButton = new JButton("Pridėti");
        cancelButton = new JButton("Atšaukti");

        okButton.addActionListener(this);
        cancelButton.addActionListener(this);

        buttonPanel.add(okButton);
        buttonPanel.add(cancelButton);

        add(inputPanel, BorderLayout.CENTER);
        add(buttonPanel, BorderLayout.SOUTH);

        pack();
        setResizable(false);
        setLocationRelativeTo(owner);
    }

    @Override
    public void actionPerformed(ActionEvent e) {
        if (e.getSource() == okButton) {
            try {
                String brand = brandField.getText().trim();
                String model = modelField.getText().trim();
                int year = Integer.parseInt(yearField.getText().trim());
                double capacity = Double.parseDouble(capacityField.getText().trim());
                int axles = Integer.parseInt(axlesField.getText().trim());

                if (brand.isEmpty() || model.isEmpty()) {
                    JOptionPane.showMessageDialog(this,
                            "Gamintojas ir Modelis negali būti tušti.",
                            "Klaida", JOptionPane.ERROR_MESSAGE);
                    return;
                }

                if (year <= 0 || capacity < 0 || axles <= 0) {
                    JOptionPane.showMessageDialog(this,
                            "Metai, krovinio talpa ir ašių skaičius turi būti nenegiami (metai ir ašys > 0).",
                            "Klaida", JOptionPane.ERROR_MESSAGE);
                    return;
                }
                if (year < 1896) { // Pirmo sunkvežimio metai
                    JOptionPane.showMessageDialog(this,
                            "Metai turi būti vėlesni nei 1895 (pirmo sunkvežimio metai).",
                            "Klaida", JOptionPane.ERROR_MESSAGE);
                    return;
                }

                truck = new Truck(brand, model, year, capacity, axles, null); // null arba new String[0]

                dispose();

            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(this,
                        "Neteisingas skaičiaus formatas (metai, talpa ar ašių skaičius).",
                        "Klaida", JOptionPane.ERROR_MESSAGE);
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(this,
                        "Įvyko netikėta klaida: " + ex.getMessage(),
                        "Klaida", JOptionPane.ERROR_MESSAGE);
                ex.printStackTrace();
            }

        } else if (e.getSource() == cancelButton) {
            truck = null;
            dispose();
        }
    }

    public Truck getTruck() {
        return truck;
    }
}