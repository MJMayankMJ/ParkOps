//
//  RecentSlotBookingCell.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/5/25.
//

import UIKit

protocol RecentSlotBookingCellDelegate: AnyObject {
    func didTapApprove(on slot: ParkingSlotData)
    func didTapCancel(on slot: ParkingSlotData)
    func didTapModify(on slot: ParkingSlotData)
}

class RecentSlotBookingCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var slotLabel: UILabel!
    @IBOutlet weak var paymentstatusLabel: UILabel!
    
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var modifyButton: UIButton!
    
    weak var delegate: RecentSlotBookingCellDelegate?
    
    // a reference to the current slot data so we can pass it when buttons are tapped.
    private var currentSlotData: ParkingSlotData?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Called just before the cell is reused (e.g. scrolling off-screen)
    override func prepareForReuse() {
        super.prepareForReuse()
        currentSlotData = nil
    }
    
    // MARK: - Configure Cell
    // to populate the cell's labels/buttons with data from ParkingSlotData
    
    func configure(with slotData: ParkingSlotData) {
        // Store the data in currentSlotData so the button taps can access it
        currentSlotData = slotData
        
        // Name
        nameLabel.text = slotData.name
        
        // Time
        if let startTime = slotData.startingTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            timeLabel.text = "Time: \(formatter.string(from: startTime))"
        } else {
            timeLabel.text = "Time: N/A"
        }
        
        // Duration
        durationLabel.text = "Duration: \(slotData.timeDurationInHour) hrs"
        
        // Slot
        slotLabel.text = "Slot: \(slotData.slotNumber)"
        
        // Payment Status
        paymentstatusLabel.text = slotData.isPaymentDone ? "Payment: ✅" : "Payment: ❌"
    }

    
    // MARK: - IBActions
    @IBAction func approveButtonTapped(_ sender: UIButton) {
        guard let slot = currentSlotData else { return }
        delegate?.didTapApprove(on: slot)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        guard let slot = currentSlotData else { return }
        delegate?.didTapCancel(on: slot)
    }
    
    @IBAction func modifyButtonTapped(_ sender: UIButton) {
        guard let slot = currentSlotData else { return }
        delegate?.didTapModify(on: slot)
    }
}
