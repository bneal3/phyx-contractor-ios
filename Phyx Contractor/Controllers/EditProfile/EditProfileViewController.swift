//
//  SignViewController.swift
//  Phyx Contractor
//
//  Created by sonnaris on 8/15/18.
//  Copyright © 2018 sonnaris. All rights reserved.
//

import UIKit
import AVKit
import SwiftyAvatar
import SVProgressHUD
import SDWebImage

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var birthField: UITextField!
    @IBOutlet weak var bioField: UITextView!
    @IBOutlet weak var videoField: UITextField!
    
    @IBOutlet weak var avatar: SwiftyAvatar!
    
    var btnBack : UIBarButtonItem!
    
    private var selectedImage: UIImage? = nil
    private var selectedVideo: URL? = nil
    
    let bioPlaceholder = "Talk about yourself and your experience."
    
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
        
        self.title = "Edit Profile"
        btnBack = UIBarButtonItem(image: UIImage(named: "BackBlack"), style: .plain, target: self, action: #selector(self.clickedBack))
        self.navigationItem.leftBarButtonItem = btnBack
        self.navigationItem.hidesBackButton = true
        
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
        
        calendarPopup.selectButton.addTarget(self, action: #selector(setSelectedDate), for: .touchUpInside)
        
        fillData()
        
    }
    
    private func fillData() {
        
        nameField.delegate = self
        lastNameField.delegate = self
        phoneField.delegate = self
        addressField.delegate = self
        
        if let avatar = ContractorData.shared().getAvatar() {
            FSWrapper.wrapper.loadImage(url: URL(string: avatar)!, completion: { (image, error) in
                self.avatar.image = image
            })
        }
        
        nameField.text = ContractorData.shared().getFirstName()
        lastNameField.text = ContractorData.shared().getLastName()
        
        phoneField.text = ContractorData.shared().getPhone()
        addressField.text = ContractorData.shared().getAddress()
        
        let dateString = formatter.string(from: Date(timeIntervalSince1970: Double(ContractorData.shared().getUserBirthday())))
        birthField.text = dateString
        birthField.isEnabled = false
        
        bioField.text = ContractorData.shared().getBio()
        bioField.textColor = UIColor.contractor
        
        videoField.text = "Selected Video"
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
    
    // TODO: Phone number validation
    @IBAction func clickedRegister(_ sender: Any) {
        
        if (nameField.text?.isEmpty)! {
            
            let alert = UIAlertController(title: "Error", message: "Must enter your first name.", preferredStyle: .alert)
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
        
        if (phoneField.text?.isEmpty)! {
            
            let alert = UIAlertController(title: "Error", message: "Must enter your phone number.", preferredStyle: .alert)
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
        
        updateProfile()
    }
    
    func updateProfile() {
        
        let phone = phoneField.text
        let first = nameField.text
        let last = lastNameField.text
        let address = addressField.text
        let bio = bioField.text

        let birth = birthField.text
        let date = formatter.date(from: birth!)
        let timestamp = date?.timeIntervalSince1970
        let birthday = Int64(timestamp!)

        SVProgressHUD.show()

        DispatchQueue.global(qos: .background).async {
            let firebasegroup = DispatchGroup()
            
            if let avatar = self.selectedImage {
                
                // Image variables
                let imagePath = "\(ContractorData.shared().getId())/\(Date().toMillis()!)"
                let imageData = avatar.jpegData(compressionQuality: 0.1)
                let reference = FSWrapper.wrapper.AVATAR_REF.child(imagePath)
                
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
                        // FLOW: Save image to cache
                        SDImageCache.shared().store(avatar, imageData: nil, forKey: downloadURL.absoluteString, toDisk: false, completion: {})
                        firebasegroup.leave()
                    }
                    
                })
            }
            
            if let video = self.selectedVideo {
                // Video variables
                let name = "/\(ContractorData.shared().getId())/\(Date().toMillis()!).mp4"
                let videoRef = FSWrapper.wrapper.MEDIA_REF.child(name)
                
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
            }
            
            firebasegroup.wait()
            
            // FLOW: Call update user API
            ApiService.shared().updateProfile(phone: phone!, first: first!, last: last!, address: address!, bio: bio!, avatar: ContractorData.shared().getAvatar()!, video: ContractorData.shared().getVideo()!, onSuccess: { (user) in
                
                self.completeUpdate()
                
            }, onFailure: { (error) in
                print(error)
                SVProgressHUD.dismiss()
            })
        }

    }
    
    func completeUpdate() {
        
        SVProgressHUD.dismiss()
        
        self.navigationController?.popViewController(animated: true)

    }
    
}

extension EditProfileViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
}


extension EditProfileViewController {
    
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


extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension EditProfileViewController: UITextViewDelegate {
    
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
