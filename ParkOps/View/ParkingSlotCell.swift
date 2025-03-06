//
//  ParkingSlotCell.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/5/25.
//

import UIKit

protocol ParkingSlotCellDelegate: AnyObject {
    func didTapEdit(for slot: ParkingSlotData)
    func didTapDelete(for slot: ParkingSlotData)
}

class ParkingSlotCell: UITableViewCell {

    weak var delegate: ParkingSlotCellDelegate?
    private var slot: ParkingSlotData? // Store slot reference

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var slotStatusLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func configure(with slot: ParkingSlotData) {
        self.slot = slot // Store slot reference
        
        let isAvailable = slot.startingTime == nil
        slotStatusLabel.text = "Slot \(slot.slotNumber) - \(isAvailable ? "Available" : "Unavailable")"
        
        if isAvailable {
            durationLabel.isHidden = true
            timeRemainingLabel.isHidden = true
        } else {
            durationLabel.isHidden = false
            timeRemainingLabel.isHidden = false
            
            durationLabel.text = "Duration: \(slot.timeDurationInHour) hrs"
            
            if let remainingTime = calculateRemainingTime(startingTime: slot.startingTime!, duration: slot.timeDurationInHour) {
                timeRemainingLabel.text = "Time Remaining: \(remainingTime)"
            } else {
                timeRemainingLabel.text = "Time Expired"
            }
        }
    }

    @IBAction func editButtonTapped(_ sender: UIButton) {
        guard let slot = slot else { return }
        delegate?.didTapEdit(for: slot)
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let slot = slot else { return }
        delegate?.didTapDelete(for: slot)
    }

    private func calculateRemainingTime(startingTime: Date, duration: Int16) -> String? {
        let calendar = Calendar.current
        let endTime = calendar.date(byAdding: .hour, value: Int(duration), to: startingTime)
        let timeLeft = endTime?.timeIntervalSinceNow ?? 0

        if timeLeft > 0 {
            let hours = Int(timeLeft) / 3600
            let minutes = (Int(timeLeft) % 3600) / 60
            return "\(hours) hrs \(minutes) min"
        }
        return "Time Expired"
    }

    private func setupUI () {
        // Style the contenView
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        deleteButton.setTitleColor(.gray, for: .normal)
    }
}



