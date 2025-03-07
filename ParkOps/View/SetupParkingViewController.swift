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
        setupUI()
    }

    private func setupUI() {
        totalFloorsTextField.keyboardType = .numberPad
        slotsPerFloorTextField.keyboardType = .numberPad
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        guard let totalFloorsText = totalFloorsTextField.text,
              let slotsPerFloorText = slotsPerFloorTextField.text,
              let totalFloors = Int16(totalFloorsText), totalFloors > 0,
              let slotsPerFloor = Int16(slotsPerFloorText), slotsPerFloor > 0 else {
            showAlert(message: "Please enter valid numbers for floors and slots per floor.")
            return
        }

        // Save values to Core Data
        CoreDataManager.shared.setTotalFloors(totalFloors)
        CoreDataManager.shared.setTotalSlotsPerFloor(slotsPerFloor)
        
        delegate?.didSaveParkingConfiguration(totalFloors: totalFloors, slotsPerFloor: slotsPerFloor)

        dismiss(animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

