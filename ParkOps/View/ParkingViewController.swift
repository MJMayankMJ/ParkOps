//
//  ViewController.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/5/25.
//

import UIKit
import CoreData

class ParkingViewController: UIViewController {

    @IBOutlet weak var availableSlotsLabel: UILabel!
    @IBOutlet weak var occupiedSlotsLabel: UILabel!
    
    @IBOutlet weak var driverNameTextField: UITextField!
    @IBOutlet weak var slotNumberTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var vehicleNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        checkAndAskForTotalSlots()
        updateSlotCounts()
    }
    
    // MARK: - Navigation Bar Setup
    func setupNavigationBar() {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTotalSlots))
        navigationItem.rightBarButtonItem = editButton
    }
    
    // MARK: - Update Slot Counts
    func updateSlotCounts() {
        let availableSlots = CoreDataManager.shared.availableSlots
        let occupiedSlots = CoreDataManager.shared.occupiedSlots
        
        availableSlotsLabel.text = "\(availableSlots)"
        occupiedSlotsLabel.text = "\(occupiedSlots)"
    }
    
    // MARK: - Edit Total Slots
    @objc func editTotalSlots() {
        let alert = UIAlertController(title: "Edit Total Slots", message: "Enter new total slots", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.text = "\(CoreDataManager.shared.fetchTotalSlots() ?? 0)"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text, let newTotalSlots = Int16(text) {
                CoreDataManager.shared.setTotalSlots(newTotalSlots)
                self.updateSlotCounts()
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Log New Parking Entry
    @IBAction func logEntryTapped(_ sender: UIButton) {
        guard let driverName = driverNameTextField.text, !driverName.isEmpty,
              let slotNumberText = slotNumberTextField.text, let slotNumber = Int16(slotNumberText),
              let durationText = durationTextField.text, let duration = Int16(durationText),
              let vehicleNumber = vehicleNumberTextField.text, !vehicleNumber.isEmpty else {
            showAlert(message: "Please fill all fields correctly.")
            return
        }

        CoreDataManager.shared.addParkingSlot(
            name: driverName,
            slotNumber: slotNumber,
            timeDurationInHour: duration,
            startingTime: Date(),
            vehicleNumber: vehicleNumber
        )
        
        updateSlotCounts()
        clearTextFields()
    }
    
    // MARK: - Helper Methods
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func clearTextFields() {
        driverNameTextField.text = ""
        slotNumberTextField.text = ""
        durationTextField.text = ""
        vehicleNumberTextField.text = ""
    }
    
    func checkAndAskForTotalSlots() {
        let totalSlots = CoreDataManager.shared.fetchTotalSlots() ?? 0
        
        if totalSlots == 0 {
            let alert = UIAlertController(title: "Set Total Slots", message: "Enter the total number of parking slots available.", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.keyboardType = .numberPad
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                if let text = alert.textFields?.first?.text, let newTotalSlots = Int16(text), newTotalSlots > 0 {
                    CoreDataManager.shared.setTotalSlots(newTotalSlots)
                    self.updateSlotCounts()
                } else {
                    self.checkAndAskForTotalSlots() // Show alert again if input is invalid
                }
            }
            
            alert.addAction(saveAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                self.checkAndAskForTotalSlots() // Force user to enter a value
            }))
            
            present(alert, animated: true)
        }
    }

}
