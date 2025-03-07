//
//  ViewController.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/5/25.
//

import UIKit

class ParkingViewController: UIViewController {

    @IBOutlet weak var availableSlotsLabel: UILabel!
    @IBOutlet weak var occupiedSlotsLabel: UILabel!
    
    @IBOutlet weak var driverNameTextField: UITextField!
    @IBOutlet weak var slotNumberTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var vehicleNumberTextField: UITextField!
    
    let viewModel = ParkingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        checkAndShowSetupScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSlotCounts()
    }

    // MARK: - Navigation Bar Setup
    func setupNavigationBar() {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editParkingSetup))
        navigationItem.rightBarButtonItem = editButton
    }

    // MARK: - Update Slot Counts
    func updateSlotCounts() {
        availableSlotsLabel.text = "\(viewModel.availableSlots)"
        occupiedSlotsLabel.text = "\(viewModel.occupiedSlots)"
    }

    // MARK: - Edit Parking Setup (Bottom Sheet)
    @objc func editParkingSetup() {
        let setupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetupParkingViewController") as! SetupParkingViewController
        setupVC.delegate = self
        setupVC.modalPresentationStyle = .pageSheet
        
        if let sheet = setupVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(setupVC, animated: true)
    }

    // MARK: - Log New Parking Entry
    @IBAction func logEntryTapped(_ sender: UIButton) {
        let totalFloors = viewModel.fetchTotalFloors() ?? 0
        let slotsPerFloor = viewModel.fetchTotalSlotsPerFloor() ?? 0
        
        if let error = InputValidator.validateDriverName(driverNameTextField.text) {
            showAlert(message: error)
            return
        }
        let (formattedSlotNumber, slotError) = InputValidator.validateAndFormatSlotNumber(slotNumberTextField.text, totalFloors: totalFloors, slotsPerFloor: slotsPerFloor)
        if let error = slotError {
            showAlert(message: error)
            return
        }

        if let error = InputValidator.validateTimeDuration(durationTextField.text) {
            showAlert(message: error)
            return
        }
        guard let duration = Int16(durationTextField.text ?? ""), duration > 0 else {
            showAlert(message: "Please enter a valid time duration.")
            return
        }
        if let error = InputValidator.validateVehicleNumber(vehicleNumberTextField.text) {
            showAlert(message: error)
            return
        }
        guard let validSlotNumber = formattedSlotNumber else {
            showAlert(message: "Invalid slot number.")
            return
        }

        viewModel.addParkingSlot(
            name: driverNameTextField.text ?? "",
            slotNumber: validSlotNumber,
            timeDurationInHour: duration,
            vehicleNumber: vehicleNumberTextField.text ?? ""
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
    
    // MARK: - Check and Show Setup Screen if Needed
    private func checkAndShowSetupScreen() {
        let totalFloors = CoreDataManager.shared.fetchTotalFloors() ?? 0
        let slotsPerFloor = CoreDataManager.shared.fetchTotalSlotsPerFloor() ?? 0

        if totalFloors == 0 || slotsPerFloor == 0 {
            let setupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetupParkingViewController") as! SetupParkingViewController
            setupVC.delegate = self
            setupVC.modalPresentationStyle = .fullScreen
            present(setupVC, animated: true)
        }
    }
}

// MARK: - SetupParkingDelegate Implementation
extension ParkingViewController: SetupParkingDelegate {
    func didSaveParkingConfiguration(totalFloors: Int16, slotsPerFloor: Int16) {
        viewModel.setTotalFloors(totalFloors)
        viewModel.setTotalSlotsPerFloor(slotsPerFloor)
        updateSlotCounts()
    }
}
