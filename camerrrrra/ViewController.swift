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
    
    override var prefersStatusBarHidden: Bool { return true }
    
    var selectedSetting = Setting.none
    let selectedButtonBackground = UIColor.white.withAlphaComponent(0.4)
    // Setting selector buttons
    @IBOutlet weak var wbButton: UIButton!
    @IBOutlet weak var isoButton: UIButton!
    @IBOutlet weak var expButton: UIButton!
    
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
    
    var rotate90 = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
    
    @IBOutlet weak var verticalSlider: UISlider!{
        didSet{
            verticalSlider.transform = rotate90
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
    @IBAction func expButton(_ sender: Any) {
        self.settingChange(setting: Setting.exp)
    }
    @IBAction func isoPress(_ sender: Any) {
        self.settingChange(setting: Setting.iso)
    }
    @IBAction func wbPress(_ sender: Any) {
        self.settingChange(setting: Setting.wb)
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
            // Runs animation of black overlayed screen fading
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
    func settingChange(setting: Setting) {
        var nextSetting = setting
        if (setting == self.selectedSetting) {
            nextSetting = Setting.none
        }
        self.deselect(setting: self.selectedSetting)
        self.selectedSetting = nextSetting
        self.select(setting: nextSetting)
    }
    func select(setting: Setting) {
        // deselect all
        verticalSlider.isHidden = true
        vertSlider.isHidden = true
        vSlider.isHidden = true
        switch setting {
        case Setting.iso:
            isoButton.backgroundColor = selectedButtonBackground
            verticalSlider.isHidden = false
        case Setting.exp:
            expButton.backgroundColor = selectedButtonBackground
            vertSlider.isHidden = false
        case Setting.none:
            // Noop
            wbButton.backgroundColor = UIColor.clear
        default:
            vSlider.isHidden = false
            wbButton.backgroundColor = selectedButtonBackground
        }
    }
    func deselect(setting: Setting) {
        switch setting {
        case Setting.iso:
            isoButton.backgroundColor = UIColor.clear
        case Setting.exp:
            expButton.backgroundColor = UIColor.clear
        default:
            // Wb case in default because default is needed
            wbButton.backgroundColor = UIColor.clear
        }
    }
    func hideButtons() {
        verticalSlider.isHidden = true
        vertSlider.isHidden = true
        vSlider.isHidden = true
        rotatePrompt.isHidden = false
        rotatePromptText.isHidden = false
        captureButton.isHidden = true
        
        isoButton.isHidden = true
        wbButton.isHidden = true
        expButton.isHidden = true
    }
    
    func showButtons() {
        self.select(setting: self.selectedSetting)
        rotatePrompt.isHidden = true
        rotatePromptText.isHidden = true
        captureButton.isHidden = false
        
        isoButton.isHidden = false
        wbButton.isHidden = false
        expButton.isHidden = false
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
        
        // should start with nothing selected
        self.settingChange(setting: self.selectedSetting)
        
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
        
        func styleSettingButton(button: UIButton) {
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 3
            button.layer.cornerRadius = 10
            button.transform = rotate90
        }
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.white.cgColor
            captureButton.layer.borderWidth = 3
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }

        styleSettingButton(button: wbButton)
        styleSettingButton(button: isoButton)
        styleSettingButton(button: expButton)
        styleCaptureButton()
        styleISOSlider()
        configureCameraController()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    enum Setting {
        case iso
        case wb
        case exp
        case none
    }
}
