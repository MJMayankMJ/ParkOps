//
//  TransactionManagementViewController.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/11/25.
//

import UIKit
import CoreData



class TransactionManagementViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterByDateButton: UIButton!
    @IBOutlet weak var filterByStatusButton: UIButton!
    
    // Data source: Initially fetched using your custom method
    private var transactions: [ParkingSlotData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Transaction Management"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "RecentSlotBookingCell", bundle: nil),forCellReuseIdentifier: "RecentSlotBookingCell")
        
        fetchTransactions()
    }
    
    // MARK: - Fetch Data
    private func fetchTransactions() {
        transactions = CoreDataManager.shared.fetchSlotsForTransactionManagement()
        tableView.reloadData()
    }
    
    // Filter by Date:
    // Sort the transactions so that the one with the earliest startingTime comes first.
    @IBAction func filterByDateTapped(_ sender: UIButton) {
        transactions.sort { (slot1, slot2) -> Bool in
            if let t1 = slot1.startingTime, let t2 = slot2.startingTime {
                return t1 < t2
            }
            else if slot1.startingTime != nil {
                return true
            } else {
                return false
            }
        }
        tableView.reloadData()
    }
    
    // Filter by Status:
    // Sort the transactions so that "pending" records come first.
    // If two records have the same status, sort by startingTime.
    @IBAction func filterByStatusTapped(_ sender: UIButton) {
        transactions.sort { (slot1, slot2) -> Bool in
            let status1 = slot1.transactionStatus.lowercased()
            let status2 = slot2.transactionStatus.lowercased()
            
            if status1 == status2 {
                if status1 == "pending" {
                    if slot1.isPaymentDone != slot2.isPaymentDone {
                        return slot1.isPaymentDone && !slot2.isPaymentDone
                    } else {
                        if let t1 = slot1.startingTime, let t2 = slot2.startingTime {
                            return t1 < t2
                        } else if slot1.startingTime != nil {
                            return true
                        } else {
                            return false
                        }
                    }
                } else {
                    if let t1 = slot1.startingTime, let t2 = slot2.startingTime {
                        return t1 < t2
                    } else if slot1.startingTime != nil {
                        return true
                    } else {
                        return false
                    }
                }
            } else {
                if status1 == "pending" {
                    return true
                } else if status2 == "pending" {
                    return false
                } else {
                    return status1 < status2
                }
            }
        }
        tableView.reloadData()
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
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TransactionManagementViewController: UITableViewDelegate {
    // ......
}

// MARK: - RecentSlotBookingCellDelegate
extension TransactionManagementViewController: RecentSlotBookingCellDelegate {
    
    func didTapApprove(on slot: ParkingSlotData) {
        slot.transactionStatus = "approved"
        
        CoreDataManager.shared.saveContext()
        fetchTransactions()
        print("Approve tapped")
    }
    
    func didTapCancel(on slot: ParkingSlotData) {
        CoreDataManager.shared.deleteParkingSlot(slot: slot)
        fetchTransactions()
        print("Cancel tapped")
    }
    
    func didTapModify(on slot: ParkingSlotData) {
        // Modify logic can be implemented later.
    }
}
