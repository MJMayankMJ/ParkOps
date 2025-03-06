//
//  RecentSlotBookingCell.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/5/25.
//

//import UIKit
//
//class RecentSlotBookingCell: UITableViewCell {
//    
//    @IBOutlet weak var slotNumberLabel: UILabel!
//    @IBOutlet weak var timeLabel: UILabel!
//    @IBOutlet weak var slotLabel: UILabel!
//    @IBOutlet weak var userLabel: UILabel!
//    
//    @IBOutlet weak var approveButton: UIButton!
//    @IBOutlet weak var cancelButton: UIButton!
//    @IBOutlet weak var modifyButton: UIButton!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupUI()
//    }
//    
//    func setupUI() {
//        approveButton.layer.cornerRadius = 10
//        approveButton.backgroundColor = UIColor.systemRed
//        approveButton.setTitleColor(.white, for: .normal)
//    }
//    
//    func configure(with slot: SlotBooking) {
//        slotNumberLabel.text = "Slot #\(slot.slotNumber)"
//        timeLabel.text = "Time: \(slot.time)"
//        slotLabel.text = "Slot: \(slot.slotCode)"
//        userLabel.text = "User: \(slot.userName)"
//    }
//}
