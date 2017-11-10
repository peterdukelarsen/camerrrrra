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
    var choice = "ISO"
    
    @IBOutlet weak var rotatePromptText: UILabel!
    @IBOutlet weak var rotatePrompt: UIImageView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var previewCaptureView: UIView!
    @IBOutlet weak var ISOSelectorView: UISegmentedControl!
    @IBOutlet weak var ISOSlider: UISlider!
    @IBOutlet weak var SpeedSlider: UISlider!
    @IBOutlet weak var WBSlider: UISlider!
    @IBOutlet weak var ChooseSlider: UISegmentedControl!
    @IBOutlet weak var flash: UIView!
    
    @IBOutlet weak var verticalSlider: UISlider!{
        didSet{
            verticalSlider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        }
    }
    
    @IBOutlet weak var vertSlider: UISlider!{
        didSet{
            vertSlider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        }
    }
    @IBOutlet weak var vSlider: UISlider!{
        didSet{
            vSlider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        }
    }
    @IBOutlet weak var verticalChooser: UISegmentedControl!{
        didSet{
            verticalChooser.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        }
    }
    
    
    @IBAction func sliderChoice(_ sender: UISegmentedControl) {
        switch sender.titleForSegment(at: sender.selectedSegmentIndex) {
        case "ISO"?:
            verticalSlider.isHidden = false
            vertSlider.isHidden = true
            vSlider.isHidden = true
            break
        case "Shutter Speed"?:
            verticalSlider.isHidden = true
            vertSlider.isHidden = false
            vSlider.isHidden = true
            break
        case "White Balance"?:
            verticalSlider.isHidden = true
            vertSlider.isHidden = true
            vSlider.isHidden = false
            break
        default:
            verticalSlider.isHidden = true
            vertSlider.isHidden = true
            vSlider.isHidden = true
        }
    }
    @IBAction func ISOChange(_ sender: UISlider) {
        try? cameraController.configureISO(isoLevel: sender.value)
    }
    @IBAction func SpeedChange(_ sender: UISlider) {
        try? cameraController.configureSpeed(speedLevel: sender.value)
    }
    @IBAction func WBChange(_ sender: UISlider) {
        try? cameraController.configureWB(wb: sender.value)
    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            self.camFlash()
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
        vertSlider.isHidden = true
        vSlider.isHidden = true
        verticalChooser.isHidden = true
        rotatePrompt.isHidden = false
        rotatePromptText.isHidden = false
    }
    
    func showButtons() {
        verticalSlider.isHidden = false
        vertSlider.isHidden = true
        vSlider.isHidden = true
        verticalChooser.isHidden = false
        rotatePrompt.isHidden = true
        rotatePromptText.isHidden = true
    }
    
    func camFlash() {
        let shutterView = UIView(frame: self.previewCaptureView.frame)
        shutterView.backgroundColor = UIColor.black
        view.addSubview(shutterView)
        UIView.animate(withDuration: 0.2, animations: {
            shutterView.alpha = 0
        }, completion: { (_) in
            shutterView.removeFromSuperview()
        })
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

