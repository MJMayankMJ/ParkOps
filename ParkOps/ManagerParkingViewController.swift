//
//  ManagerParkingViewController.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/5/25.
//

import UIKit

class ManageParkingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    struct ParkingSlot {
        let slotName: String
        let duration: String
        let isAvailable: Bool
    }
    
    var parkingSlots: [ParkingSlot] = [
        ParkingSlot(slotName: "Slot 1", duration: "2 hrs", isAvailable: true),
        ParkingSlot(slotName: "Slot 2", duration: "24 hrs", isAvailable: false),
        ParkingSlot(slotName: "Slot 3", duration: "72 hrs", isAvailable: true)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register the custom XIB cell
        tableView.register(UINib(nibName: "ParkingSlotCell", bundle: nil), forCellReuseIdentifier: "ParkingSlotCell")
        
        // Remove separators
        tableView.separatorStyle = .none
    }
    
    // MARK: - UITableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkingSlots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingSlotCell", for: indexPath) as? ParkingSlotCell else {
            return UITableViewCell()
        }
        
        let slot = parkingSlots[indexPath.row]
        
        cell.slotStatusLabel.text = "\(slot.slotName) - \(slot.isAvailable ? "Available" : "Unavailable")"
        cell.durationLabel.text = "Duration: \(slot.duration)"
        
        return cell
    }

    // MARK: - Set Cell Height to Screen Size / 6
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 6
    }
}
