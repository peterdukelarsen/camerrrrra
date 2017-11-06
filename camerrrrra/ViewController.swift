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
    
    @IBOutlet weak var rotatePromptText: UILabel!
    @IBOutlet weak var rotatePrompt: UIImageView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var previewCaptureView: UIView!
    @IBOutlet weak var ISOSelectorView: UISegmentedControl!
    @IBOutlet weak var ISOSlider: UISlider!
    
    @IBOutlet weak var verticalSlider: UISlider!{
        didSet{
            verticalSlider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        }
    }
    
    @IBAction func ISOChange(_ sender: UISlider) {
        try? cameraController.configureISO(isoLevel: sender.value)
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
    func hideButtons() {
        verticalSlider.isHidden = true
        rotatePrompt.isHidden = false
        rotatePromptText.isHidden = false
    }
    
    func showButtons() {
        verticalSlider.isHidden = false
        rotatePrompt.isHidden = true
        rotatePromptText.isHidden = true
    }
    
    func handleRotation(notification: Notification) -> Void{
        let orientation = UIDevice.current.orientation
        if (orientation == .landscapeLeft) {
            showButtons()
        }
        else if (orientation == .portrait ||
            orientation == .portraitUpsideDown ||
            orientation == .landscapeRight) {
            hideButtons()
        }
    }
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: .main, using: handleRotation)
        
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
            ISOSlider.minimumValue = 0.0;
            ISOSlider.maximumValue = 1.0;
        }
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.white.cgColor
            captureButton.layer.borderWidth = 3
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }

        styleCaptureButton()
        styleISOSlider()
        configureCameraController()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

