//
//  TransactionManagementViewController.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/11/25.
//

import UIKit

class TransactionManagementViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterByDateButton: UIButton!
    @IBOutlet weak var filterByStatusButton: UIButton!
    
    // Data source
    private var transactions: [ParkingSlotData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Transaction Management"
        
        // Set table view dataSource & delegate
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "RecentSlotBookingCell", bundle: nil), forCellReuseIdentifier: "RecentSlotBookingCell")
        
        // Fetch initial data
        fetchTransactions()
    }
    
    // MARK: - Fetch Data
    private func fetchTransactions() {
        // Using the method from your CoreDataManager that returns
        // everything that is NOT (approved && paid).
        transactions = CoreDataManager.shared.fetchSlotsForTransactionManagement()
        tableView.reloadData()
    }
    
    // MARK: - IBActions
    @IBAction func filterByDateTapped(_ sender: UIButton) {
        // Implement date-based filtering if desired
        print("Filter by Date tapped")
    }
    
    @IBAction func filterByStatusTapped(_ sender: UIButton) {
        // Implement status-based filtering if desired
        print("Filter by Status tapped")
    }
}

// MARK: - UITableViewDataSource
extension TransactionManagementViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RecentSlotBookingCell",
            for: indexPath
        ) as? RecentSlotBookingCell else {
            return UITableViewCell()
        }
        
        let slotData = transactions[indexPath.row]
        cell.configure(with: slotData)
        
        // Set the cell's delegate to self
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UITableViewDelegate (Optional)
extension TransactionManagementViewController: UITableViewDelegate {
    // e.g., didSelectRowAt if needed
}

// MARK: - RecentSlotBookingCellDelegate
extension TransactionManagementViewController: RecentSlotBookingCellDelegate {
    
    /// Called when user taps Approve in the cell
    func didTapApprove(on slot: ParkingSlotData) {
        // Example logic: Mark transaction as approved
        slot.transactionStatus = "approved"
        
        // If you also want to mark it as paid at the same time, do:
        // slot.isPaymentDone = true
        
        // Save the changes
        CoreDataManager.shared.saveContext()
        
        // Re-fetch so that if it's now (approved && paid), it moves to Manage Slots
        fetchTransactions()
    }
    
    /// Called when user taps Cancel in the cell
    func didTapCancel(on slot: ParkingSlotData) {
        // Example logic: we can either mark as "cancelled" or remove it from the DB
        // Let's delete the record entirely:
        CoreDataManager.shared.deleteParkingSlot(slot: slot)
        
        // Re-fetch
        fetchTransactions()
    }
    
    /// Called when user taps Modify in the cell
    func didTapModify(on slot: ParkingSlotData) {
        // For example, present an alert or a screen to modify the slot details
        // We'll do a simple example changing the slot number
        let alert = UIAlertController(title: "Modify Slot", message: "Enter new slot number:", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "e.g. A10"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            if let newSlotNumber = alert.textFields?.first?.text, !newSlotNumber.isEmpty {
                slot.slotNumber = newSlotNumber
                CoreDataManager.shared.saveContext()
                self.fetchTransactions()
            }
        }))
        present(alert, animated: true)
    }
}
