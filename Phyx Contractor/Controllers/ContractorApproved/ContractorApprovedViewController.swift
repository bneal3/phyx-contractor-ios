//
//  MetricsViewController.swift
//  Camp
//
//  Created by Lee on 1/4/19.
//  Copyright © 2019 sonnaris. All rights reserved.
//

import UIKit

class ContractorApprovedViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var earningsLabel: UILabel!

    var closeBlock: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // adjust height and width of dialog
        view.bounds.size.height = containerView.frame.height//UIScreen.main.bounds.size.height * 0.75
        view.bounds.size.width = containerView.frame.width//UIScreen.main.bounds.size.width * 0.70
        view.layer.cornerRadius = 5.0
        
        initUI()
    }
    
    @IBAction func gotItTapped(_ sender: Any) {
        if (closeBlock != nil) {
            closeBlock!()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initUI() {
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 5
        
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
        
    }
}
