//
//  ChatSettingViewController.swift
//  Camp
//
//  Created by sonnaris on 8/20/18.
//  Copyright © 2018 sonnaris. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import SVProgressHUD
import FirebaseStorage
import SDWebImage
import PubNub

class ServiceDetailsViewController: UIViewController {
    
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var meetingDatePicker: UIDatePicker!
    
    @IBOutlet weak var continueBtn: UIButton!
    
    var btnBack: UIBarButtonItem!
    var details: [String: Any]!
    
    var isMassage: Bool = false
    var massageTimes = [30, 60, 90]
    
    let massageLengthSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(frame: CGRect(x: 0, y: 0, width: 150, height: 24))
        segmentedControl.backgroundColor = .white
        segmentedControl.tintColor = .contractor
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "Avenir", size: 16) ?? UIFont.boldSystemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "Avenir", size: 16) ?? UIFont.boldSystemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .selected)
        return segmentedControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Service Details"
        
        if isMassage {
            massageLengthSegmentedControl.isHidden = false
        } else {
            massageLengthSegmentedControl.isHidden = true
        }

    }
    
    private func initialize() {
        
        if let image = details["image"] as? String, image != "" {
            serviceImage.image = UIImage(named: image)
        }
        if let name = details["name"] as? String {
            serviceName.text = name
        }
        if let description = details["description"] as? String {
            descriptionLabel.text = description
        }
        
        meetingDatePicker.date = Date()
        meetingDatePicker.minimumDate = Date()
        
        btnBack = UIBarButtonItem(image: UIImage(named: "BackBlack"), style: .plain, target: self, action: #selector(self.clickedBack))
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.leftBarButtonItem = btnBack
        
        for (index, time) in massageTimes.enumerated() {
            massageLengthSegmentedControl.insertSegment(withTitle: String(time) + " mins", at: index, animated: true)
        }
        
        self.view.addSubview(massageLengthSegmentedControl)
        massageLengthSegmentedControl.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 32, height: 40)
        massageLengthSegmentedControl.anchor(top: meetingDatePicker.safeBottomAnchor(), left: self.view.safeLeftAnchor(), bottom: nil, right: self.view.safeRightAnchor(), paddingTop: 8, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: massageLengthSegmentedControl.frame.width, height: massageLengthSegmentedControl.frame.height)
        massageLengthSegmentedControl.isHidden = true
        
        massageLengthSegmentedControl.selectedSegmentIndex = 0
        
    }
    
    @objc func clickedBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        AppointmentData.shared().setService(service: details["serviceId"] as! Int)
        AppointmentData.shared().setMeetingTime(meetingTime: meetingDatePicker.date.toMillis())
        if isMassage {
            AppointmentData.shared().setLength(length: massageTimes[massageLengthSegmentedControl.selectedSegmentIndex])
        }
        
        let locationSelectionVC = LocationSelectionViewController()
        self.navigationController?.pushViewController(locationSelectionVC, animated: true)
    }
}
