//
//  MetricsViewController.swift
//  Phyx Contractor
//
//  Created by Lee on 1/4/19.
//  Copyright © 2019 sonnaris. All rights reserved.
//

import UIKit

class RateViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var contractorLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var startedLabel: UILabel!
    @IBOutlet weak var endedLabel: UILabel!
    
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    var stars: [UIButton] = []
    var appointment: Appointment!
    var user: User!
    
    var closeBlock: (() -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let rating = appointment.rating, rating > 0 {
            starTapped(rating, update: false)
        } else {
            starReset()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // adjust height and width of dialog
        view.bounds.size.height = containerView.frame.height//UIScreen.main.bounds.size.height * 0.75
        view.bounds.size.width = containerView.frame.width//UIScreen.main.bounds.size.width * 0.70
        view.layer.cornerRadius = 5.0
        
        initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initUI() {
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        
        stars = [star1, star2, star3, star4, star5]
        
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 5
                
        serviceLabel.text = SERVICE_TITLES[appointment.service]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/d, h:mm a"
        let startTime = Date(timeIntervalSince1970: appointment.startTime!.toTimeInterval())
        startedLabel.text = dateFormatter.string(from: startTime)
        
        let endTime = Date(timeIntervalSince1970: appointment.endTime!.toTimeInterval())
        endedLabel.text = dateFormatter.string(from: endTime)
        
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
        
        if let avatar = user.avatar, avatar != "" {
            FSWrapper.wrapper.loadImage(url: URL(string: avatar)!, completion: { (image, error) in
                self.avatarImage.image = image
            })
        } else {
            avatarImage.image = UIImage(named: "AvatarPlaceholder")
        }
        contractorLabel.text = user.name
        
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        if (closeBlock != nil) {
            closeBlock!()
        }
    }
    
    func starReset() {
        for i in 0..<stars.count {
            stars[i].setImage(UIImage(named: "star"), for: .normal)
        }
    }
    
    func starTapped(_ number: Int, update: Bool) {
        starReset()
        for i in 0..<number {
            stars[i].setImage(UIImage(named: "star-filled"), for: .normal)
        }
        
        if update {
            ApiService.shared().patchAppointment(id: appointment.id, status: appointment.status, rating: number, onSuccess: { (appointment) in
                
                if (self.closeBlock != nil) {
                    self.closeBlock!()
                }
                
            }) { (response) in }
        }
    }
    
    @IBAction func star1Tapped(_ sender: Any) {
        starTapped(1, update: true)
    }
    
    @IBAction func star2Tapped(_ sender: Any) {
        starTapped(2, update: true)
    }
    
    @IBAction func star3Tapped(_ sender: Any) {
        starTapped(3, update: true)
    }
    
    @IBAction func star4Tapped(_ sender: Any) {
        starTapped(4, update: true)
    }
    
    @IBAction func star5Tapped(_ sender: Any) {
        starTapped(5, update: true)
    }
    
    
}
