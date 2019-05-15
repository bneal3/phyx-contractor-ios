//
//  CMCameraVC+HybridCamDelegate.swift
//  camp
//
//  Created by Kevin Hall on 6/27/18.
//  Copyright © 2018 Benjamin Neal. All rights reserved.
//

import UIKit

extension CMCameraVC: HybridCamDelegate {
    func handleExitButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
