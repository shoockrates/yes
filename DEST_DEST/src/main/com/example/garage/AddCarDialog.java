package src.main.com.example.garage;

import src.main.com.example.cars.Car;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class AddCarDialog extends JDialog implements ActionListener {

    private JTextField brandField, modelField, yearField, doorsField;
    private JButton okButton, cancelButton;
    private Car car;

    public AddCarDialog(Frame owner) {
        super(owner, "Pridėti automobilį", true);

        car = null;

        setLayout(new BorderLayout());
        JPanel inputPanel = new JPanel(new GridLayout(4, 2, 5, 5)); // 4 eilutės, 2 stulpeliai, 5px tarpai

        inputPanel.add(new JLabel("Gamintojas (Brand):"));
        brandField = new JTextField();
        inputPanel.add(brandField);

        inputPanel.add(new JLabel("Modelis:"));
        modelField = new JTextField();
        inputPanel.add(modelField);

        inputPanel.add(new JLabel("Metai:"));
        yearField = new JTextField();
        inputPanel.add(yearField);

        inputPanel.add(new JLabel("Durų skaičius:"));
        doorsField = new JTextField();
        inputPanel.add(doorsField);

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
                int doors = Integer.parseInt(doorsField.getText().trim());

                if (brand.isEmpty() || model.isEmpty()) {
                    JOptionPane.showMessageDialog(this,
                            "Gamintojas ir Modelis negali būti tušti.",
                            "Klaida", JOptionPane.ERROR_MESSAGE);
                    return;
                }

                if (year <= 0 || doors <= 0) {
                    JOptionPane.showMessageDialog(this,
                            "Metai ir durų skaičius turi būti teigiami skaičiai.",
                            "Klaida", JOptionPane.ERROR_MESSAGE);
                    return;
                }
                if (year < 1886) {
                    JOptionPane.showMessageDialog(this,
                            "Metai turi būti vėlesni nei 1885 (pirmo automobilio metai).",
                            "Klaida", JOptionPane.ERROR_MESSAGE);
                    return;
                }

                car = new Car(brand, model, year, doors);

                dispose();

            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(this,
                        "Neteisingas skaičiaus formatas (metai arba durų skaičius).",
                        "Klaida", JOptionPane.ERROR_MESSAGE);
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(this,
                        "Įvyko netikėta klaida: " + ex.getMessage(),
                        "Klaida", JOptionPane.ERROR_MESSAGE);
                ex.printStackTrace();
            }

        } else if (e.getSource() == cancelButton) {
            car = null;
            dispose();
        }
    }

    public Car getCar() {
        return car;
    }
}