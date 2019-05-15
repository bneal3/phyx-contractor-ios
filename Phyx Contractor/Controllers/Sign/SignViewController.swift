//
//  SignViewController.swift
//  Camp
//
//  Created by sonnaris on 8/15/18.
//  Copyright © 2018 sonnaris. All rights reserved.
//

import UIKit
import AVKit
import SwiftyAvatar
import SVProgressHUD
import SDWebImage

class SignViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var birthField: UITextField!
    @IBOutlet weak var bioField: UITextView!
    @IBOutlet weak var videoField: UITextField!
    
    @IBOutlet weak var passwordCheck: UIImageView!
    @IBOutlet weak var confirmCheck: UIImageView!
    
    @IBOutlet weak var avatar: SwiftyAvatar!
    
    @IBOutlet weak var termsLabel: UILabel!
    
    private var selectedImage: UIImage? = nil
    private var selectedVideo: URL? = nil
    
    var phone: String?
    
    var bioPlaceholder = "Talk about yourself and your experience."
    
    private let formatter : DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private lazy var calendarPopup : CalendarPopUpView = {
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 50, height: 350)
        let calendar = CalendarPopUpView(frame: frame)
        calendar.center = view.center
        calendar.backgroundColor = .clear
        calendar.layer.shadowColor = UIColor.black.cgColor
        calendar.layer.shadowOpacity = 0.4
        calendar.layer.shadowOffset = .zero
        calendar.layer.shadowRadius = 5
        calendar.didSelectDay = {
            self.setSelectedDate()
        }
        return calendar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        
        self.nameField.becomeFirstResponder()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    private func initialize() {
        
        nameField.delegate = self
        passwordField.delegate = self
        confirmField.delegate = self
        addressField.delegate = self
        birthField.delegate = self
        
        confirmCheck.isHidden = true
        passwordCheck.isHidden = true
        
        let tapGestureView = UITapGestureRecognizer(target: self, action: #selector(self.didTapView))
        self.parentView.addGestureRecognizer(tapGestureView)
        parentView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.clickedAvatar))
        avatar.addGestureRecognizer(tapGesture)
        
        let tapGestureBirth = UITapGestureRecognizer(target: self, action: #selector(self.clickedBirth))
        birthField.addGestureRecognizer(tapGestureBirth)
        birthField.isUserInteractionEnabled = true
        
        let tapGestureVideo = UITapGestureRecognizer(target: self, action: #selector(self.clickedVideo))
        videoField.addGestureRecognizer(tapGestureVideo)
        videoField.isUserInteractionEnabled = true
        
        self.confirmField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        nameField.tag = 1
        passwordField.tag = 2
        confirmField.tag = 3
        
        calendarPopup.selectButton.addTarget(self, action: #selector(setSelectedDate), for: .touchUpInside)
        
        termsLabel.text = "By registering, you agree to the Terms of Service"
        bioField.text = bioPlaceholder
        bioField.textColor = UIColor.contractor
        bioField.selectedTextRange = bioField.textRange(from: bioField.beginningOfDocument, to: bioField.beginningOfDocument)
        
        let tapGestureTerms = UITapGestureRecognizer(target: self, action: #selector(clickedTerms))
        termsLabel.addGestureRecognizer(tapGestureTerms)
        termsLabel.isUserInteractionEnabled = true
        
    }
    
    @objc func didTapView() {
        
        self.view.endEditing(true)
    }
    
    @IBAction func clickedBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func clickedAvatar() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: {action in
            self.getPhotoFromCamera()
        })
        let cameraRoll = UIAlertAction(title: "Camera Roll", style: .default, handler: { action in
            self.getPhotoFromRoll()
        })
        
        actionSheet.addAction(camera)
        actionSheet.addAction(cameraRoll)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let p = passwordField.text
        let c = confirmField.text
        
        if p == c {
            
            passwordCheck.isHidden = false
            confirmCheck.isHidden = false
            
        } else {
            
            passwordCheck.isHidden = true
            confirmCheck.isHidden = true
            
        }
    }
    
    @objc func clickedBirth() {
        
        view.addSubview(calendarPopup)
        calendarPopup.anchor(top: nil, left: view.safeLeftAnchor(), bottom: birthField.safeTopAnchor(), right: view.safeRightAnchor(), paddingTop: 0, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 350)
    }
    
    @objc func setSelectedDate() {
        birthField.text = formatter.string(from: calendarPopup.birthdayPicker.date)
        calendarPopup.removeFromSuperview()
    }
    
    @objc func clickedVideo() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: {action in
            self.getVideoFromCamera()
        })
        let cameraRoll = UIAlertAction(title: "Camera Roll", style: .default, handler: { action in
            self.getVideoFromRoll()
        })
        
        actionSheet.addAction(camera)
        actionSheet.addAction(cameraRoll)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func getPhotoFromCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func getPhotoFromRoll() {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    private func getVideoFromCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.movie"]
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    private func getVideoFromRoll() {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.movie"]
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    @objc func clickedTerms() {
        
        let termsVC = TermsViewController(nibName: "TermsViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: termsVC)
        self.navigationController?.present(nav, animated: true, completion: nil)
        
    }
    
    @IBAction func clickedRegister(_ sender: Any) {
        
        if (nameField.text?.isEmpty)! {
            
            let alert = UIAlertController(title: "Error", message: "Must enter your name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if (lastNameField.text?.isEmpty)! {
            
            let alert = UIAlertController(title: "Error", message: "Must enter your last name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if (passwordField.text?.isEmpty)! || (passwordField.text?.count)! < 6 {
            
            let alert = UIAlertController(title: "Error", message: "Password must be more than six characters.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
            
        }
        
        if (confirmField.text?.isEmpty)! {
            
            let alert = UIAlertController(title: "Error", message: "Must confirm your password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if passwordField.text != confirmField.text {
            
            let alert = UIAlertController(title: "Error", message: "Password doesn't match.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
            
        }
        
        if (addressField.text?.isEmpty)! {
            
            let alert = UIAlertController(title: "Error", message: "Must enter your address.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if (birthField.text?.isEmpty)! {
            
            let alert = UIAlertController(title: "Error", message: "Must enter your birthday.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if (bioField.text?.isEmpty)! {
            
            let alert = UIAlertController(title: "Error", message: "Must have a bio.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        register()
    }
    
    func register() {
        
        let password = passwordField.text
        let first = nameField.text
        let last = lastNameField.text
        let address = addressField.text
        let bio = bioField.text
        
        let birth = birthField.text
        let date = formatter.date(from: birth!)
        let timestamp = date?.timeIntervalSince1970
        let birthday = Int64(timestamp!)
        
        guard let avatar = selectedImage else {
            
            let alert = UIAlertController(title: "Error", message: "Avatar not selected.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let video = selectedVideo else {

            let alert = UIAlertController(title: "Error", message: "Intro video not selected.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        SVProgressHUD.show()
        
        // FLOW: Register user on API
        ApiService.shared().registerContractor(phone: phone!, password: password!, first: first!, last: last!, address: address!, birth: birthday, bio: bio!, onSuccess: { result in
            
            // Image variables
            let imagePath = "\(result.id)/\(Date().toMillis()!)"
            let imageData = avatar.jpegData(compressionQuality: 0.1)
            let reference = FSWrapper.wrapper.AVATAR_REF.child(imagePath)
            
            // Video variables
            let name = "/\(result.id)/\(Date().toMillis()!).mp4"
            let videoRef = FSWrapper.wrapper.MEDIA_REF.child(name)

            DispatchQueue.global(qos: .background).async {
                let firebasegroup = DispatchGroup()
                
                // FLOW: Upload avatar
                firebasegroup.enter()
                reference.putData(imageData!, metadata: nil, completion: { (meta, error) in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                        firebasegroup.leave()
                        return
                    }
                    
                    reference.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred
                            firebasegroup.leave()
                            return
                        }
                        ContractorData.shared().setAvatar(avatar: downloadURL.absoluteString)
                        firebasegroup.leave()
                    }
                    
                })
                
                // FLOW: Upload video
                firebasegroup.enter()
                videoRef.putFile(from: video, metadata: nil) { metadata, error in
                    if let error = error {
                        print(error)
                        firebasegroup.leave()
                        return
                    } else {
                        videoRef.downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                // Uh-oh, an error occurred!
                                firebasegroup.leave()
                                return
                            }
                            ContractorData.shared().setVideo(video: downloadURL.absoluteString)
                            firebasegroup.leave()
                        }
                    }
                }
                
                firebasegroup.wait()
                
                result.avatar = ContractorData.shared().getAvatar()!
                result.video = ContractorData.shared().getVideo()!
                
                // FLOW: Save image to cache
                SDImageCache.shared().store(avatar, imageData: nil, forKey: result.avatar!, toDisk: false, completion: {})
                
                // FLOW: Call update user API
                ApiService.shared().updateProfile(phone: result.phone, first: result.first, last: result.last, address: result.address, bio: result.bio, avatar: result.avatar!, video: result.video!, onSuccess: { (user) in
                    
                    self.completeRegistration()
                    
                }, onFailure: { (error) in
                    print(error)
                    SVProgressHUD.dismiss()
                })
            }

        }, onFailure: { result in
            print(result)
            SVProgressHUD.dismiss()
        })
        
    }
    
    func completeRegistration() {
        
        SVProgressHUD.dismiss()
        
        let locationManager = LocationManager.sharedInstance
        locationManager.showVerboseMessage = true
        locationManager.autoUpdate = false
        locationManager.startUpdatingLocation()
        
        ContractorData.shared().sawApproved(saw: false)
        
        // FLOW: Continue to MainViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setMainScreen()

    }
    
}

extension SignViewController {
    
    func addObservers() {
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { notification in
            self.keyboardWillShow(notification: notification)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { notification in
            self.keyboardWillHide(notification: notification)
        }
        
    }
    
    func removeObservers() {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo, let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: containerView.frame.height - (view.frame.height - (view.frame.height - containerView.frame.minY)), right: 0)
        scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification: Notification) {
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: containerView.frame.height - (view.frame.height - (view.frame.height - containerView.frame.minY)), right: 0)
        scrollView.contentInset = contentInset
    }
}


extension SignViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == "public.image" {
                let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
                selectedImage = image
                avatar.image = image
            } else if mediaType == "public.movie" {
                let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
                selectedVideo = videoURL
                videoField.text = "Video Selected"
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension SignViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let tag = textField.tag
        switch tag {
        case 1:
            passwordField.becomeFirstResponder()
            break
        case 2:
            confirmField.becomeFirstResponder()
            break
        default:
            textField.resignFirstResponder()
            break
        }
        
        return true
    }

}

extension SignViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
}
