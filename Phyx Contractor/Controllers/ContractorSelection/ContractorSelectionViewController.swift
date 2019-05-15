//
//  ProfileViewController.swift
//  Phyx Contractor
//
//  Created by sonnaris on 8/16/18.
//  Copyright © 2018 sonnaris. All rights reserved.
//

import UIKit
import Popover
import SwiftyAvatar
import RealmSwift

class ContractorSelectionViewController: UIViewController {
    
    var contractor: Contractor!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var parentView: UIView!
    
    @IBOutlet weak var levelView: UIView!
    
    @IBOutlet weak var avatarView: SwiftyAvatar!
    @IBOutlet weak var nameView: UILabel!
    @IBOutlet weak var userNameView: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var videoThumbnail: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tabBarController?.navigationController?.isNavigationBarHidden = true
        
        setupContractor()
    }
    
    private func initialize() {
        
        self.levelView.layer.cornerRadius = 3
        
        let path = UIBezierPath(rect: self.levelView.bounds)
        let border = CAShapeLayer()
        border.path = path.cgPath
        border.lineWidth = 2
        border.fillColor = UIColor.clear.cgColor
        self.levelView.layer.addSublayer(border)
        
        self.navigationItem.title = "Contractor Found"

        // Bar buttons
        
        let btnBack = UIBarButtonItem(image: UIImage(named: "BackBlack")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(self.clickedBack))
        self.navigationItem.leftBarButtonItem = btnBack
        
    }
    
    private func setupContractor() {
        
        if let avatar = contractor.avatar, avatar != "" {
            FSWrapper.wrapper.loadImage(url: URL(string: avatar)!, completion: { (image, error) in
                self.avatarView.image = image
            })
        } else {
            avatarView.image = UIImage(named: "AvatarPlaceholder")
        }
        
        nameView.text = contractor.first + " " + contractor.last
        var profession = "Chiropractor"
        let service = AppointmentData.shared().getService()
        if service > 1, service < 8 {
            profession = "Masseuse"
        } else if service == 8 {
            profession = "Acupuncturist"
        }
        userNameView.text = profession
        
        bioLabel.text = contractor.bio
        if let video = contractor.video, video != "" {
            FSWrapper.wrapper.loadImage(url: URL(string: video)!, completion: { (image, error) in
                self.videoThumbnail.image = image
            })
        } else {
            videoThumbnail.image = UIImage(named: "VideoPlaceholder")
        }
        
    }

    
    @objc func clickedBack() {
        
        self.navigationController?.popViewController(animated: true)
        
    }

    @IBAction func selectTapped(_ sender: Any) {
        AppointmentData.shared().setContractorId(contractorId: contractor.id)
        AppointmentData.shared().setStatus(status: 1)

        let confirmationVC = AppointmentConfirmationViewController(nibName: "AppointmentConfirmationViewController", bundle: nil)
        self.navigationController?.pushViewController(confirmationVC, animated: true)
    }
    
    @IBAction func passTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    
}
