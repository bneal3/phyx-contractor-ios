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
import SVProgressHUD

class AppointmentConfirmationViewController: UIViewController {
        
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var parentView: UIView!
    
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var lengthLabel: UILabel!
    
    @IBOutlet weak var contractorAvatar: UIImageView!
    @IBOutlet weak var contractorLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var costLabel: UILabel!
    
    var appointment: Appointment!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        initialize()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tabBarController?.navigationController?.isNavigationBarHidden = true
        
        setupAppointment()
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
        
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor(netHex: 0xA9A9A9).cgColor
        notesTextView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOut))
        view.addGestureRecognizer(tapGesture)

        // Bar buttons
        
        let btnBack = UIBarButtonItem(image: UIImage(named: "BackBlack")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(self.clickedBack))
        self.navigationItem.leftBarButtonItem = btnBack
        
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    private func setupAppointment() {
        serviceLabel.text = SERVICE_TITLES[appointment.service]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let meetingTime = Date(timeIntervalSince1970: appointment.meetingTime.toTimeInterval())
        dateLabel.text = dateFormatter.string(from: meetingTime)
        
        addressLabel.text = appointment.location
        
        contractorAvatar.layer.masksToBounds = true
        contractorAvatar.layer.cornerRadius = contractorAvatar.frame.width / 2
        
        SVProgressHUD.show()
        ApiService.shared().getUser(id: appointment.userId, onSuccess: { (user) in
            SVProgressHUD.dismiss()
            
            if let avatar = user.avatar, avatar != "" {
                FSWrapper.wrapper.loadImage(url: URL(string: avatar)!, completion: { (image, error) in
                    self.contractorAvatar.image = image
                })
            } else {
                self.contractorAvatar.image = UIImage(named: "AvatarPlaceholder")
            }
            self.contractorLabel.text = user.name
            
        }) { (response) in
            SVProgressHUD.dismiss()
        }
        
        if let length = appointment.length {
            lengthLabel.text = "\(String(length)) minutes"
        }

        if let notes = appointment.notes {
            notesTextView.text = notes
        }
    }
    
    @objc func tappedOut() {
        self.view.endEditing(true)
    }
    
    @objc func clickedBack() {
        
        self.navigationController?.popViewController(animated: true)
        
    }

    @IBAction func selectTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func passTapped(_ sender: Any) {
        // FLOW: Accept appointment
        ApiService.shared().patchAppointment(id: appointment.id, status: 1, rating: nil, onSuccess: { (appointment) in
            
            let sessionVC = SessionViewController(nibName: "SessionViewController", bundle: nil)
            sessionVC.appointment = appointment
            self.navigationController?.pushViewController(sessionVC, animated: true)
            
        }) { (response) in }
    }
}

extension AppointmentConfirmationViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // TODO: Zoom up
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        notesTextView.resignFirstResponder()
        
        return true
    }
    
}
