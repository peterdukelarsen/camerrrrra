//
//  ViewController.swift
//  camerrrrra
//
//  Created by Peter Larsen on 11/5/17.
//  Copyright © 2017 Peter Larsen. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    let cameraController = CameraController()
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var previewCaptureView: UIView!
    
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
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
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.white.cgColor
            captureButton.layer.borderWidth = 3
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        previewCaptureView.translatesAutoresizingMaskIntoConstraints = false
        styleCaptureButton()
        configureCameraController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

