//
//  SetupParkingViewController.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/7/25.
//

import UIKit

protocol SetupParkingDelegate: AnyObject {
    func didSaveParkingConfiguration(totalFloors: Int16, slotsPerFloor: Int16)
}

class SetupParkingViewController: UIViewController {
    
    @IBOutlet weak var totalFloorsTextField: UITextField!
    @IBOutlet weak var slotsPerFloorTextField: UITextField!
    
    weak var delegate: SetupParkingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        guard let totalFloorsText = totalFloorsTextField.text,
              let slotsPerFloorText = slotsPerFloorTextField.text,
              let totalFloors = Int16(totalFloorsText), totalFloors > 0,
              let slotsPerFloor = Int16(slotsPerFloorText), slotsPerFloor > 0 else {
            showAlert(message: "Please enter valid numbers for floors and slots per floor.")
            return
        }
        
        // Get the required configuration based on occupied slots.
        // These helper methods should be implemented in ParkingViewModel.
        let viewModel = ParkingViewModel()
        let requiredFloors = viewModel.maxRequiredFloors()
        let requiredSlots = viewModel.maxRequiredSlotsPerFloor()
        
        var warningMessages = [String]()
        if totalFloors < requiredFloors {
            let requiredFloorLetter = Character(UnicodeScalar(64 + Int(requiredFloors))!)
            warningMessages.append("You have occupied slots on floor \(requiredFloorLetter). Total floors cannot be set to less than \(requiredFloors).")
        }
        if slotsPerFloor < requiredSlots {
            warningMessages.append("You have occupied slots requiring at least \(requiredSlots) slots per floor.")
        }
        
        // If new configuration is below what is required, warn the user.
        if !warningMessages.isEmpty {
            let message = warningMessages.joined(separator: "\n") + "\nProceeding will delete the out-of-range occupied slots. Do you want to continue?"
            let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Continue", style: .destructive, handler: { _ in
                // Delete the out-of-range occupied slots and update the configuration.
                CoreDataManager.shared.deleteOutOfRangeSlots(totalFloors: totalFloors, slotsPerFloor: slotsPerFloor)
                CoreDataManager.shared.setTotalFloors(totalFloors)
                CoreDataManager.shared.setTotalSlotsPerFloor(slotsPerFloor)
                self.delegate?.didSaveParkingConfiguration(totalFloors: totalFloors, slotsPerFloor: slotsPerFloor)
                self.dismiss(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            // New configuration is safe; update normally.
            CoreDataManager.shared.setTotalFloors(totalFloors)
            CoreDataManager.shared.setTotalSlotsPerFloor(slotsPerFloor)
            delegate?.didSaveParkingConfiguration(totalFloors: totalFloors, slotsPerFloor: slotsPerFloor)
            dismiss(animated: true)
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
