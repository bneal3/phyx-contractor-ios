//
//  CMCameraVC.swift
//  stat
//
//  Created by Benjamin Neal on 2/6/18.
//  Copyright © 2018 Benjamin Neal. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

enum MediaType: Int {
    case Photo = 0
    case Video
}

protocol CameraControllerDelegate {
    var selectedImage: UIImage? { get set }
    var videoURL: URL? { get set }
    // var imageName: String? { get set }
}

protocol HybridCamDelegate {
    func handleExitButton()
}

class CMCameraVC: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraControllerDelegate {
    
    // MARK: Internal Class Data
    
    let hybridCamView = HybridCamView()
    let processMediaView = ProcessMediaView.init(frame: UIScreen.main.bounds)
    var selectedImage: UIImage? = nil
    var videoURL: URL? = nil
    var mediaType: MediaType = MediaType.Photo
    
    // MARK: View Controller Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedImage = nil
        videoURL = nil
        
        CamUtil.assertVideoAndMicAccess(vc: self) { (success) in
            guard success else {return}
            DispatchQueue.main.async {
                self.initiate()
            }
            
        }
    }
    
    // MARK: Core Class Functionality
    
    /**
     * When camera onCapture is called
     */
    private func onCapture(_ image:UIImage?,_ url:URL?,_ error:Error?) {
        
        processMediaView.onExit = {self.processMediaView.deInitiate()}
        
        // TODO: Handle image vs video being sent back to delegate
        processMediaView.onShare = { (image:UIImage?, url: URL?) in
            if let image = image {
                print("Image")
                self.selectedImage = image
                self.dismiss(animated: true, completion: nil)
            } else if let url = url {
                print("Video")
                self.videoURL = url
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        self.view.addSubview(processMediaView)
        if let error = error{
            ProcessMediaView.promptErrorDialog(vc: self, error: error, onComplete: {self.processMediaView.deInitiate()});return
        }else {
            processMediaView.present(image: image, url: url)
        }
    }
    
}

extension CMCameraVC {
    
    // MARK: UI Initialization
    
    func initiate(){
        hybridCamView.delegate = self
        hybridCamView.mediaType = self.mediaType
        self.view = hybridCamView
        hybridCamView.camView.onPhotoCaptureComplete = onCapture
        hybridCamView.camView.onVideoCaptureComplete = {(url:URL?,error:Error?)in self.onCapture(nil,url,error)}
    }
    
    // MARK: Selector Functions/UI Routines
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
