//
//  ParkingSlotCell.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/5/25.
//

import UIKit

class ParkingSlotCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var slotStatusLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Style the container view
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4

        // Style buttons
        editButton.layer.cornerRadius = 10
        editButton.backgroundColor = UIColor.systemRed
        editButton.setTitleColor(.white, for: .normal)
        
        deleteButton.setTitleColor(.gray, for: .normal)
    }
}
