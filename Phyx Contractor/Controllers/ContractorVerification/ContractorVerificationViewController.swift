//
//  ChatSettingViewController.swift
//  Phyx Contractor
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

class ContractorVerificationViewController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    
    var btnBack: UIBarButtonItem!
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Contractor Verification"
        
        
    }
    
    private func initialize() {
        
        btnBack = UIBarButtonItem(image: UIImage(named: "BackBlack"), style: .plain, target: self, action: #selector(self.clickedBack))
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.leftBarButtonItem = btnBack
        
//        if !ContractorData.shared().getSubmitted() {
//            btnBack.isEnabled = false
//        } else {
//            btnBack.isEnabled = true
//        }
        
        let xib = UINib(nibName: ImageUploadCell.identifier, bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: ImageUploadCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    @objc func clickedBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        if images.count > 0 {
            DispatchQueue.global(qos: .background).async {

                var paths: [String] = []
                
                let group = DispatchGroup()
                
                for image in self.images {
                    group.enter()
                    
                    let imagePath = "\(ContractorData.shared().getId())/\(Date().toMillis()!)"
                    let imageData = image.jpegData(compressionQuality: 0.1)
                    let reference = FSWrapper.wrapper.DOCUMENT_REF.child(imagePath)
                    
                    // FLOW: Upload picture
                    reference.putData(imageData!, metadata: nil, completion: { (meta, error) in
                        if error != nil {
                            print(error?.localizedDescription as Any)
                            group.leave()
                            return
                        }
                        reference.downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                // Uh-oh, an error occurred
                                group.leave()
                                return
                            }
                            paths.append(downloadURL.absoluteString)
                            group.leave()
                        }
                        
                    })
                }
                // NOTE: DispatchGroup wait method makes sure to wait until all requests in a group have completed before executing
                group.wait()
                
                ApiService.shared().submitDocuments(documents: paths, onSuccess: { (response) in
                    ContractorData.shared().setSubmitted(submitted: true)
                    self.navigationController?.popViewController(animated: true)
                }) { (error) in }
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Must submit at least one document.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func addBtnTapped(_ sender: Any) {
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
    
    private func getPhotoFromCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
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
}

extension ContractorVerificationViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == "public.image" {
                let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
                self.images.append(image)
            }
            self.tableView.reloadData()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}


extension ContractorVerificationViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageUploadCell.identifier, for: indexPath) as! ImageUploadCell
        
        cell.delegate = self
        cell.configureCell(image: images[indexPath.row])
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

extension ContractorVerificationViewController : RemoveDocumentDelegate {
    
    func removeDocument(sender: UIButton) {
        print("HRE")
        guard let cell = sender.superview?.superview as? ImageUploadCell else {
            return // or fatalError() or whatever
        }
        print("HUH")
        let indexPath = self.tableView.indexPath(for: cell)
        
        self.images.remove(at: indexPath!.row)

        self.tableView.reloadData()
        
    }
    
}
