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

class BankInformationViewController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var routingField: UITextField!
    
    var btnBack: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Bank Information"
        
        
    }
    
    private func initialize() {
        
        btnBack = UIBarButtonItem(image: UIImage(named: "BackBlack"), style: .plain, target: self, action: #selector(self.clickedBack))
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.leftBarButtonItem = btnBack
        
        let tapGestureView = UITapGestureRecognizer(target: self, action: #selector(self.didTapView))
        self.view.addGestureRecognizer(tapGestureView)
        
    }
    
    @objc func clickedBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapView() {
        
        self.view.endEditing(true)
    }
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        
        guard !(accountField.text?.isEmpty)! else {
            let alert = UIAlertController(title: "Error", message: "Must enter account number.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard !(routingField.text?.isEmpty)! else {
            let alert = UIAlertController(title: "Error", message: "Must enter routing number.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        ApiService.shared().submitBank(account: accountField.text!, routing: routingField.text!, onSuccess: { (response) in
            if let paymentId = response.object["paymentId"] as? String {
                ContractorData.shared().setPaymentId(paymentId: paymentId)
                self.navigationController?.popViewController(animated: true)
            }
        }) { (error) in }

    }
    
}
