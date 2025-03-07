//
//  EditSlotViewController.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/6/25.
//

import UIKit

protocol EditSlotDelegate: AnyObject {
    func didUpdateSlot(_ updatedSlot: ParkingSlotData)
    func didDeleteSlot(_ slot: ParkingSlotData)
}

class EditSlotViewController: UIViewController {
    
    weak var delegate: EditSlotDelegate?
    var slot: ParkingSlotData?
    
    @IBOutlet weak var slotNumberTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var vehicleNumberTextField: UITextField!
    @IBOutlet weak var startingTimePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        guard let slot = slot else { return }
        
        slotNumberTextField.text = slot.slotNumber
        slotNumberTextField.isEnabled = false
        durationTextField.text = "\(slot.timeDurationInHour)"
        vehicleNumberTextField.text = slot.vehicleNumber
        
        if let startTime = slot.startingTime {
            startingTimePicker.date = startTime
        } else {
            startingTimePicker.isEnabled = false
        }
    }
    
    @IBAction func saveChanges(_ sender: UIButton) {
        guard let slot = slot else { return }
        
        // Validate Inputs
        if let error = InputValidator.validateTimeDuration(durationTextField.text) {
            showAlert(message: error)
            return
        }
        
        if let error = InputValidator.validateVehicleNumber(vehicleNumberTextField.text) {
            showAlert(message: error)
            return
        }
        
        // Apply Changes
        slot.timeDurationInHour = Int16(Int(durationTextField.text ?? "0") ?? 0)
        slot.vehicleNumber = vehicleNumberTextField.text ?? ""
        slot.startingTime = startingTimePicker.date
        
        // Save changes to Core Data
        CoreDataManager.shared.saveContext()
        
        delegate?.didUpdateSlot(slot) // Notify delegate
        dismiss(animated: true)
    }
    
    @IBAction func deleteSlot(_ sender: UIButton) {
        guard let slot = slot else { return }
        
        CoreDataManager.shared.deleteParkingSlot(slot: slot)
        delegate?.didDeleteSlot(slot) // Notify delegate about deletion
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
