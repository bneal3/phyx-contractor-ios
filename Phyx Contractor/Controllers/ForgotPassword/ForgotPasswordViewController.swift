//
//  ChangePasswordViewController.swift
//  Phyx Contractor
//
//  Created by sonnaris on 8/22/18.
//  Copyright © 2018 sonnaris. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var newField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    var btnBack : UIBarButtonItem!
    var lockToken: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }

    private func initialize() {
        
        self.title = "Forgot Password"
        btnBack = UIBarButtonItem(image: UIImage(named: "BackBlack"), style: .plain, target: self, action: #selector(self.clickedBack))
        self.navigationItem.leftBarButtonItem = btnBack
        self.navigationItem.hidesBackButton = true
        
        newField.delegate = self
        confirmField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapView))
        self.parentView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapView() {
        
        view.endEditing(true)
        
    }
    
    @objc func clickedBack() {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func clickedSave(_ sender: Any) {
        
        if let password = newField.text, let confirm = confirmField.text, password == confirm {
            
            // FLOW: Change password on server side
            ApiService.shared().forgotPassword(newPassword: password, lock: lockToken, onSuccess: { result in
                
                let alert = UIAlertController(title: "Password", message: "Password has been successfully updated", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    // FLOW: Go to auth view
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }, onFailure: { error in
                
                self.newField.text = ""
                self.confirmField.text = ""
                
                AlertManager.shared().error(title: "Error", message: "Could not update password at this time.")
                
            })
            
        } else {
            
        }
    }
    
}

extension ForgotPasswordViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}


extension ForgotPasswordViewController {
    
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
        
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification: Notification) {
        
        scrollView.contentInset = .zero
    }
}
