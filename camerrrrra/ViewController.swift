//
//  ViewController.swift
//  camerrrrra
//
//  Created by Peter Larsen on 11/5/17.
//  Copyright © 2017 Peter Larsen. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class ViewController: UIViewController {
    let cameraController = CameraController()
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var previewCaptureView: UIView!
    @IBOutlet weak var ISOSelectorView: UISegmentedControl!
    @IBOutlet weak var ISOSlider: UISlider!
    
    @IBAction func ISOChange(_ sender: UISlider) {
        try? cameraController.configureISO(iso: sender.value)
    }
    
    @IBAction func ISOSelector(_ sender: Any) {
        switch ISOSelectorView.selectedSegmentIndex{
        case 0:
            try? cameraController.configureISO(iso: 100)
            break
        case 1:
            try? cameraController.configureISO(iso: 200)
            break
        case 2:
            try? cameraController.configureISO(iso: 400)
            break
        case 3:
            try? cameraController.configureISO(iso: 800)
            break
        case 4:
            try? cameraController.configureISO(iso: 1600)
            break
        default:
            break
        }
    }
    
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            // This orients the image as if you took it landscape
            let imageOrientation: UIImageOrientation = .up
            let cgImage: CGImage = image.cgImage!
            let orientedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: imageOrientation)
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: orientedImage)
            }
        }
    }
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }
                // should be self.capturePreviewView, not self.inputView!
                try? self.cameraController.displayPreview(on: self.previewCaptureView)
                
            }
        }
        
        func styleISOSlider() {
            ISOSlider.minimumValue = cameraController.getMinISO()
            ISOSlider.maximumValue = cameraController.getMaxISO()
        }
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.white.cgColor
            captureButton.layer.borderWidth = 3
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        
        previewCaptureView.translatesAutoresizingMaskIntoConstraints = false
        styleCaptureButton()
        styleISOSlider()
        configureCameraController()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

