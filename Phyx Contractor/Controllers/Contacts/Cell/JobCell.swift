//
//  ContactCell.swift
//  Camp
//
//  Created by sonnaris on 8/20/18.
//  Copyright © 2018 sonnaris. All rights reserved.
//

import UIKit
import SwiftyAvatar

class JobCell: UITableViewCell {
    
    static let identifier = "JobCell"

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatar: SwiftyAvatar!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        parentView.backgroundColor = UIColor.white
        parentView.layer.cornerRadius = 3
                
        let path = UIBezierPath(rect: self.parentView.bounds)
        let border = CAShapeLayer()
        border.path = path.cgPath
        border.lineWidth = 2
        border.fillColor = UIColor.clear.cgColor
        self.parentView.layer.addSublayer(border)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setCell(appointment: Appointment) {
        if appointment.service > 1 || appointment.service < 8 {
            var service = SERVICES.first(where: { $0["serviceId"] as! Int == appointment.service })
            nameLabel.text = service!["name"] as! String
        } else {
            var massage = MASSAGES.first(where: { $0["serviceId"] as! Int == appointment.service })
            nameLabel.text = massage!["name"] as! String
        }
        
        clientNameLabel.text = "Ben Neal"
        addressLabel.text = "Los Angeles" // appointment.address.city
        // TODO: Get avatar image
        
    }
    
}
