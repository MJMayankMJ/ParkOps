//
//  ManagerParkingViewController.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/5/25.
//

import UIKit
import CoreData

class ManageParkingViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var parkingSlots: [ParkingSlotData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "ParkingSlotCell", bundle: nil), forCellReuseIdentifier: "ParkingSlotCell")
        
        tableView.separatorStyle = .none
        
        setNavTitle()
        fetchParkingSlots()
    }
    
    func fetchParkingSlots() {
        parkingSlots = CoreDataManager.shared.fetchAllParkingSlots().sorted(by: { $0.slotNumber < $1.slotNumber })
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 6
    }
    
    private func setNavTitle() {
        navigationItem.title = "Manage Parking"
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemRed]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}

// MARK: - UITableView Data Source

extension ManageParkingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkingSlots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingSlotCell", for: indexPath) as? ParkingSlotCell else {
            return UITableViewCell()
        }
        
        let slot = parkingSlots[indexPath.row]
        cell.configure(with: slot)
        cell.delegate = self // Set delegate for edit and delete actions
        
        return cell
    }
}

// MARK: - ParkingSlotCell Delegate

extension ManageParkingViewController: ParkingSlotCellDelegate {
    
    func didTapEdit(for slot: ParkingSlotData) {
        presentEditScreen(for: slot)
    }

    func didTapDelete(for slot: ParkingSlotData) {
        CoreDataManager.shared.deleteParkingSlot(slot: slot)
        fetchParkingSlots()
    }
    
    private func presentEditScreen(for slot: ParkingSlotData) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "EditSlotViewController") as? EditSlotViewController {
            editVC.modalPresentationStyle = .pageSheet
            if let sheet = editVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
            editVC.slot = slot
            editVC.delegate = self // Update data after editing
            present(editVC, animated: true)
        }
    }
}

// MARK: - EditSlotViewController Delegate

extension ManageParkingViewController: EditSlotDelegate {
    func didUpdateSlot(_ updatedSlot: ParkingSlotData) {
        fetchParkingSlots()
    }
    
    func didDeleteSlot(_ slot: ParkingSlotData) {
        CoreDataManager.shared.deleteParkingSlot(slot: slot)
           fetchParkingSlots() // Refresh the table view to reflect deletion
       }
}
