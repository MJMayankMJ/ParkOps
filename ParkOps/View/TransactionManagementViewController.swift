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
        
        title = "Transaction Management"
        
        // Table View Setup
        tableView.dataSource = self
        tableView.delegate = self
        
        // Register the custom cell (if using a nib file)
        tableView.register(UINib(nibName: "RecentSlotBookingCell", bundle: nil),
                           forCellReuseIdentifier: "RecentSlotBookingCell")
        
        // Initial fetch
        fetchTransactions()
    }
    
    // MARK: - Fetch Data
    private func fetchTransactions() {
        // Using the method that returns everything not (approved && paid)
        transactions = CoreDataManager.shared.fetchSlotsForTransactionManagement()
        tableView.reloadData()
    }
    
    // MARK: - IBActions
    @IBAction func filterByDateTapped(_ sender: UIButton) {
        // Optional: Implement date-based filtering
        print("Filter by Date tapped")
    }
    
    @IBAction func filterByStatusTapped(_ sender: UIButton) {
        // Optional: Implement status-based filtering
        print("Filter by Status tapped")
    }
}

// MARK: - UITableViewDataSource
extension TransactionManagementViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
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
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate (Optional)
extension TransactionManagementViewController: UITableViewDelegate {
    // e.g. didSelectRowAt, if needed
}

// MARK: - RecentSlotBookingCellDelegate
extension TransactionManagementViewController: RecentSlotBookingCellDelegate {
    
    func didTapApprove(on slot: ParkingSlotData) {
        // Mark as approved, optionally mark as paid
        slot.transactionStatus = "approved"
        // slot.isPaymentDone = true  // to move to Manage Slots immediately
        
        CoreDataManager.shared.saveContext()
        // Refresh the list so that if it's (approved && paid), it disappears from here
        fetchTransactions()
        print("tapped on aprrove button")
    }
    
    func didTapCancel(on slot: ParkingSlotData) {
        // e.g. remove from DB or mark as "rejected"
        // Here, let's just delete it
        CoreDataManager.shared.deleteParkingSlot(slot: slot)
        
        // Refresh
        fetchTransactions()
        print("tapped on cancel button")
    }
    
    func didTapModify(on slot: ParkingSlotData) {
        // Not implemented for now
    }
}
