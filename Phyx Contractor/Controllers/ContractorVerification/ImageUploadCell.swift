//
//  SettingCell.swift
//  Phyx Contractor
//
//  Created by sonnaris on 8/16/18.
//  Copyright © 2018 sonnaris. All rights reserved.
//

import UIKit

class ImageUploadCell: UITableViewCell {
    
    static let identifier = "ImageUploadCell"
    
    @IBOutlet weak var documentView: UIImageView!

    var delegate: RemoveDocumentDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
        // Configure the view for the selected state
    }
    
    public func configureCell(image: UIImage) {
        
        documentView.image = image

    }
    
    @IBAction func removeTapped(_ sender: Any) {
        
        print("YERR")
        
        if delegate != nil {
            delegate.removeDocument(sender: sender as! UIButton)
        }
        
    }
    
}

protocol RemoveDocumentDelegate {
    func removeDocument(sender: UIButton)
}
