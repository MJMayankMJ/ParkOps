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
    
    let viewModel = ParkingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        checkAndShowSetupScreen()
        DispatchQueue.main.async {
            self.createDummyDataIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSlotCounts()
    }
    
    // MARK: - Navigation Bar Setup
    func setupNavigationBar() {
        // Right bar button for editing
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editParkingSetup))
        navigationItem.rightBarButtonItem = editButton

        // Create the custom "Clear All Data" UIButton
        let clearAllButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Clear All Data", for: .normal)
            button.setTitleColor(.red, for: .normal)
            button.addTarget(self, action: #selector(clearAllDataTapped), for: .touchUpInside)
            return button
        }()

        // Wrap the UIButton in a UIBarButtonItem
        let clearAllBarButtonItem = UIBarButtonItem(customView: clearAllButton)
        navigationItem.leftBarButtonItem = clearAllBarButtonItem
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
    
    @objc private func clearAllDataTapped() {
        let alert = UIAlertController(title: "Clear All Data?", message: "This will delete all parking slots and reset floors and slots per floor. This action cannot be undone.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { _ in
            self.viewModel.clearAllParkingData()
            DispatchQueue.main.async {
                self.updateSlotCounts()
                self.editParkingSetup()
            }
        }))

        present(alert, animated: true, completion: nil)
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
        ) { errorMessage in
            DispatchQueue.main.async {
                if let error = errorMessage {
                    self.showAlert(message: error)
                } else {
                    self.updateSlotCounts()
                    self.clearTextFields()
                }
            }
        }
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

 //MARK: - SetupParkingDelegate Implementation
extension ParkingViewController: SetupParkingDelegate {
    func didSaveParkingConfiguration(totalFloors: Int16, slotsPerFloor: Int16) {
        viewModel.setTotalFloors(totalFloors)
        viewModel.setTotalSlotsPerFloor(slotsPerFloor)
        updateSlotCounts()
    }
}

extension ParkingViewController {
    func createDummyDataIfNeeded() {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<ParkingSlotData> = ParkingSlotData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "transactionStatus == %@", "pending") // Filter only pending records
        
        do {
            let existingPendingRecords = try context.fetch(fetchRequest)
            
            // If there are already pending records, do not create new dummy data
            if !existingPendingRecords.isEmpty {
                print("Pending transactions already exist. Skipping dummy data creation.")
                return
            }
            
            print("No pending transactions found. Creating dummy data...")
            
            //10 dummy data
            for i in 1...10 {
                let slot = ParkingSlotData(context: context)
                
                // Assign basic details
                slot.id = UUID()
                slot.name = "Driver \(i)"
                slot.slotNumber = "A\(i)"
                slot.timeDurationInHour = Int16(2 + i)
                slot.startingTime = Date()
                slot.vehicleNumber = "ABC-123\(i)"
                
                slot.transactionStatus = "pending"
                slot.isPaymentDone = (i <= 5)
            }
            
            // Save context
            try context.save()
            print("Dummy data created successfully!")
            
        } catch {
            context.rollback()
            print("Error checking or creating dummy data: \(error)")
        }
    }

}
