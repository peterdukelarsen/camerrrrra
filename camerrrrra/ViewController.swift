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
    
    var imageTemp = 3500
    
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
    
    var rightLabel: UILabel!
    var leftLabel: UILabel!
    
    var currentValueLabel: UILabel!
    
    let rotate90 = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
    
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
        func scaleSliderVal(val: Float, min: Float, max: Float, targetMin: Float, targetMax: Float) -> Int {
            // Scale to 0 - 1
            let og = (val - min) / (max - min)
            // Square 0-1 is still in range 0-1
            let ng = pow(og, 4)
            return Int(targetMin + ng * (targetMax - targetMin))
        }
        // reverse value
        let value = sender.value
        
        let maxTemp = 20000.0
        let minTemp = 690.0
        
        self.imageTemp = scaleSliderVal(val: value, min: sender.minimumValue, max: sender.maximumValue, targetMin: Float(minTemp), targetMax: Float(maxTemp))

        let reverseVal = 1 - ((sender.value - sender.minimumValue) / (sender.maximumValue - sender.minimumValue))
        
        let newNewKelvin = scaleSliderVal(val: reverseVal, min: 0, max: 1, targetMin: Float(minTemp), targetMax: Float(maxTemp))
        
        try? cameraController.configureWB(wb: Float(newNewKelvin))
    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        // Runs animation of black overlayed screen fading
        self.camFlash()
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
    @IBAction func touchDown(_ sender: UISlider) {
        let point = sender.center
        let pixels = sender.frame.height
        
        // 0 if value is minimum, 1 if value is at maximum
        let howFarDownTheSlider = (sender.value - sender.minimumValue) / (sender.maximumValue - sender.minimumValue)
        self.currentValueLabel.center.x = point.x + 50
        self.currentValueLabel.center.y = point.y + pixels * CGFloat(howFarDownTheSlider - 0.5)
        
        self.currentValueLabel.isHidden = false
        self.currentValueLabel.text = getLabel(value: sender.value)
    }
    @IBAction func touchUp(_ sender: UISlider) {
        self.currentValueLabel.isHidden = true
    }
}

extension ViewController {
    func getLabel(value: Float) -> String {
        if (self.selectedSetting == Setting.exp) {
            return "1/\(Int(round(1 / self.cameraController.getCurrentSpeed())))"
        }
        else if (self.selectedSetting == Setting.iso) {
            return "\(self.cameraController.getCurrentISO())"
        }
        else if (self.selectedSetting == Setting.wb) {
            return "\(self.imageTemp)K"
        }
        else {
            return "N/A"
        }
    }
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
        // Hides all sliders first, then maybe exposes one.
        verticalSlider.isHidden = true
        vertSlider.isHidden = true
        vSlider.isHidden = true
        switch setting {
        case Setting.iso:
            isoButton.backgroundColor = selectedButtonBackground
            verticalSlider.isHidden = false
            self.position(slider: verticalSlider, leftText: "22", rightText: "704")
        case Setting.exp:
            expButton.backgroundColor = selectedButtonBackground
            vertSlider.isHidden = false
            self.position(slider: vertSlider, leftText: "1/10 s", rightText: "1/704 s")
        case Setting.none:
            self.rightLabel.isHidden = true
            self.leftLabel.isHidden = true
        default:
            vSlider.isHidden = false
            wbButton.backgroundColor = selectedButtonBackground
            self.position(slider: vSlider, leftText: "690 K", rightText: "20000 K")
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
        // Shows the rotate prompt and hides all other buttons
        verticalSlider.isHidden = true
        vertSlider.isHidden = true
        vSlider.isHidden = true
        rotatePrompt.isHidden = false
        rotatePromptText.isHidden = false
        captureButton.isHidden = true
        
        leftLabel.isHidden = true
        rightLabel.isHidden = true
        currentValueLabel.isHidden = true
        
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
        
        // We register an observer with the notification to track device orientation
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: .main, using: handleRotation)
        
        // Creates rightLabel and leftLabel and adds them to the view
        self.initLabels()
        
        // This sets the sliders up so none are showing and no buttons are selected
        self.settingChange(setting: self.selectedSetting)
        
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
            ISOSlider.isContinuous = true
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
    // The ~position~ method moves the right and left labels to
    // either side of the passed in slider and sets their text
    func position(slider: UISlider, leftText: String, rightText: String) {
        // This pulls out variables needed to position the labels.
        // We pull out the height of the slider and labels
        // because they have all been transformed.
        let halfRightLabelHeight = self.rightLabel.frame.height
        let halfLeftLabelHeight = self.leftLabel.frame.height
        let sliderCenterX = slider.center.x
        let sliderCenterY = slider.center.y
        let halfSliderHeight = slider.frame.height / 2
        
        // Here we compute the offset to position the label to the side of the slider.
        let rightY = sliderCenterY + halfSliderHeight + halfRightLabelHeight - 85
        let leftY = sliderCenterY - halfSliderHeight - halfLeftLabelHeight + 85
        
        // This function sets the position and text of a label.
        func setLabel(x: CGFloat, y: CGFloat, text: String, label: UILabel) {
            label.isHidden = false
            label.center.x = x
            label.center.y = y
            label.text = text
        }
        
        // Reposition both labels and set their text.
        setLabel(x: sliderCenterX, y: rightY, text: rightText, label: self.rightLabel)
        setLabel(x: sliderCenterX, y: leftY, text: leftText, label: self.leftLabel)
    }
    func initLabels() {
        // Creates a basic label
        func initLabel() -> UILabel {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 20))
            label.transform = rotate90
            label.textColor = UIColor.white
            return label
        }
        self.currentValueLabel = initLabel()
        self.rightLabel = initLabel()
        self.leftLabel = initLabel()
        
        self.currentValueLabel.textAlignment = .center
        self.rightLabel.textAlignment = .left
        self.leftLabel.textAlignment = .right
        
        self.view.addSubview(self.rightLabel)
        self.view.addSubview(self.leftLabel)
        self.view.addSubview(self.currentValueLabel)
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
