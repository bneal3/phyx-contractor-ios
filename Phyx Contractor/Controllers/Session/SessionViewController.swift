//
//  ProfileViewController.swift
//  Camp
//
//  Created by sonnaris on 8/16/18.
//  Copyright © 2018 sonnaris. All rights reserved.
//

import UIKit
import Popover
import SwiftyAvatar
import RealmSwift
import LSDialogViewController
import MapKit
import SVProgressHUD

class SessionViewController: UIViewController {
        
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var parentView: UIView!
    
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    
    @IBOutlet weak var rateBtn: UIButton!
    @IBOutlet weak var contractorAvatar: UIImageView!
    @IBOutlet weak var contractorLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var statusLabelView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var statusBtn: UIButton!
    
    var appointment: Appointment!
    var user: User!
    
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
        
        self.navigationItem.title = "Session Details"
        
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor(netHex: 0xA9A9A9).cgColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOut))
        view.addGestureRecognizer(tapGesture)
        
//        let labelTap = UITapGestureRecognizer(target: self, action: #selector(passTapped))
//        statusLabelView.addGestureRecognizer(labelTap)
//        
        let phoneTap = UITapGestureRecognizer(target: self, action: #selector(clickedPhone))
        phoneLabel.addGestureRecognizer(phoneTap)

        // Bar buttons
        
        let btnBack = UIBarButtonItem(image: UIImage(named: "BackBlack")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(self.clickedBack))
        self.navigationItem.leftBarButtonItem = btnBack
        
        if appointment == nil {
            appointment = AppointmentData.shared().getAppointment()
        }
        
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
            self.user = user
            
            if let avatar = user.avatar, avatar != "" {
                FSWrapper.wrapper.loadImage(url: URL(string: avatar)!, completion: { (image, error) in
                    self.contractorAvatar.image = image
                })
            } else {
                self.contractorAvatar.image = UIImage(named: "AvatarPlaceholder")
            }
            self.contractorLabel.text = user.name
            
            self.phoneLabel.text = user.phone
        }) { (response) in
            SVProgressHUD.dismiss()
        }
        
        if let length = appointment.length {
            lengthLabel.text = "\(String(length)) minutes"
        }
        
        if let notes = appointment.notes {
            notesTextView.text = notes
        }

        if appointment.status >= 0 {
            if appointment.status == 1 {
                statusBtn.setTitle("Begin", for: .normal)
            } else if appointment.status == 2 {
                statusBtn.setTitle("Arrived", for: .normal)
            } else if appointment.status == 3 {
                statusBtn.setTitle("Complete", for: .normal)
            }
            
            if appointment.status == 4 {
                rateBtn.isHidden = false
                statusBtn.isHidden = true
            } else {
                rateBtn.isHidden = true
                statusBtn.isHidden = false
            }
            statusLabel.text = APPOINTMENT_STATUS[appointment.status]
        } else {
            statusLabel.text = "Cancelled"
            statusBtn.isHidden = true
        }
    }
    
    @objc func tappedOut() {
        
        self.view.endEditing(true)
        
    }
    
    @objc func clickedBack() {
        
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    @objc func clickedPhone() {
        
        guard let number = URL(string: "tel://" + phoneLabel.text!) else { return }
        UIApplication.shared.open(number)
        
    }
    
    @IBAction func rateBtnTapped(_ sender: Any) {
        let dialogViewController = RateViewController(nibName: "RateViewController", bundle: nil)
        dialogViewController.appointment = appointment
        dialogViewController.user = user
        
        dialogViewController.closeBlock = {
            self.dismissDialogViewController(LSAnimationPattern.fadeInOut)
            self.navigationController?.popToRootViewController(animated: true)
        }
        presentDialogViewController(dialogViewController, animationPattern: LSAnimationPattern.fadeInOut)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to cancel?",
                                      message: "Your ability to get appointments will be affected",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            ApiService.shared().patchAppointment(id: self.appointment.id, status: -1, rating: self.appointment.rating, onSuccess: { (appointment) in
                
                let alert = UIAlertController(title: "Successfully cancelled appointment",
                                              message: "Please contact us if further assistance is needed.",
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }, onFailure: { (response) in })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func statusTapped(_ sender: Any) {
        if appointment.status == 1 {
            ApiService.shared().patchAppointment(id: appointment.id, status: 1, rating: nil, onSuccess: { (appointment) in
                
                self.openMapForPlace()
                
            }) { (response) in }
        } else {
            ApiService.shared().patchAppointment(id: appointment.id, status: appointment.status + 1, rating: nil, onSuccess: { (appointment) in

            }) { (response) in }
        }
    }
    
//    @objc func passTapped() {
//        let status = AppointmentData.shared().getStatus()! + 1
//        print(status)
//        if status < APPOINTMENT_STATUS.count {
//            AppointmentData.shared().setStatus(status: status)
//            statusLabel.text = APPOINTMENT_STATUS[AppointmentData.shared().getStatus()!]
//        } else {
//            AppointmentData.shared().setEndTime(endTime: Date().toMillis())
//            
//            // TODO: Create object in API and then store object in realm
//            let appointment = AppointmentData.shared().getAppointment()
//            // RealmService.shared.createIfNotExists(appointment)
//            
//            
//        }
//        
//        if status == 2 {
//            openMapForPlace()
//        }
//    
//    }
    
    func openMapForPlace() {
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(AppointmentData.shared().getLocation()) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                // handle no location found
                // TODO: Alert
                return
            }
            
            // Use your location
            let latitude: CLLocationDegrees = location.coordinate.latitude
            let longitude: CLLocationDegrees = location.coordinate.longitude
            
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Client Location"
            mapItem.openInMaps(launchOptions: options)
        }

    }
}
