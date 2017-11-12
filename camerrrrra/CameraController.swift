//
//  CameraController.swift
//  camerrrrra
//
//  Created by Peter Larsen on 11/5/17.
//  Copyright © 2017 Peter Larsen. All rights reserved.
//
import AVFoundation
import Foundation
import UIKit

class CameraController : NSObject {
    var captureSession: AVCaptureSession?
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
}

extension CameraController {
    // Constructs our preview using the captureSession.
    // Inserts instance of AVCaptureVideoPreviewLayer into the passed in view
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning
            else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
}

extension CameraController {
    // Sets up input from the rear camera, a capture session and the output
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            // Construct new capture session
            self.captureSession = AVCaptureSession()
        }
        func configureCaptureDevices() throws {
            self.rearCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
            if let camera = self.rearCamera {
                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
            else {
                throw CameraControllerError.noCamerasAvailable
            }
        }
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession
                else { throw CameraControllerError.captureSessionIsMissing }
            if let camera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: camera)
                if captureSession.canAddInput(self.rearCameraInput!) {
                    captureSession.addInput(self.rearCameraInput!)
                }
                else {
                    throw CameraControllerError.inputsAreInvalid
                }
            }
            else {
                throw CameraControllerError.noCamerasAvailable
            }
        }
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession
                else { throw CameraControllerError.captureSessionIsMissing }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.photoOutput!) {
                captureSession.addOutput(self.photoOutput!)
            }
            
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
}

extension CameraController {
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning
            else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        let settings = AVCapturePhotoSettings()
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
    func getMinISO () -> Float {
        return (self.rearCamera?.activeFormat.minISO)!
    }
    
    func getMaxISO () -> Float {
        return (self.rearCamera?.activeFormat.maxISO)!
    }
    
    func configureISO (isoLevel:Float) throws {
        if (isoLevel < 0 || isoLevel > 1){
            print("argument out of range")
            return
        }
        
        let max = self.getMaxISO()
        let min = self.getMinISO()
        
        let iso = min + isoLevel * (max - min)
        
        if let camera = self.rearCamera {
            try camera.lockForConfiguration()
            camera.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: iso, completionHandler: nil)
            camera.unlockForConfiguration()
        }
        else {
            throw CameraControllerError.noCamerasAvailable
        }
    }
    
    func getMaxSpeed() -> CMTime {
        return (self.rearCamera?.activeFormat.maxExposureDuration)!
    }
    
    func getMinSpeed() -> CMTime {
        return (self.rearCamera?.activeFormat.minExposureDuration)!
    }
    
    func configureSpeed (speedLevel:Float) throws {
        /*
        print("Current exposure duration: ")
        print(AVCaptureDevice.currentExposureDuration)
        
        let CMSpeedLevel = CMTimeMakeWithSeconds(Float64(speedLevel)/100, 100)
        
        let max = self.getMaxSpeed()
        let min = self.getMinSpeed()
        
        let speed = CMTimeAdd(min, CMTimeMultiply(CMSpeedLevel, Int32(CMTimeGetSeconds(CMTimeSubtract(max, min)))))
        print("min: ")
        print(min)
        print("max: ")
        print(max)
        print("speed: ")
        print(speed)
        print(speedLevel)
        print("CMSpeedLevel: ")
        print(CMSpeedLevel)
        */
        
        let speedInt = Int32(speedLevel)
        print(speedInt)
        var speed = CMTimeMake(1, 200)
        print(speed)
        switch speedInt {
        case 0:
            speed = CMTimeMake(1, 10)
            break
        case 1:
            speed = CMTimeMake(1, 25)
            break
        case 2:
            speed = CMTimeMake(1, 50)
            break
        case 3:
            speed = CMTimeMake(1, 75)
            break
        case 4:
            speed = CMTimeMake(1, 100)
            break
        case 5:
            speed = CMTimeMake(1, 150)
            break
        case 6:
            speed = CMTimeMake(1, 400)
            break
        case 7:
            speed = CMTimeMake(1, 475)
            break
        case 8:
            speed = CMTimeMake(1, 550)
            break
        case 9:
            speed = CMTimeMake(1, 600)
            break
        case 10:
            speed = CMTimeMake(1, 700)
            break
        default:
            speed = CMTimeMake(1, 300)
            break
        }
 
        print(speed)
        if let camera = self.rearCamera {
            try camera.lockForConfiguration()
            camera.setExposureModeCustom(duration: speed, iso: AVCaptureDevice.currentISO, completionHandler: nil)
            camera.unlockForConfiguration()
            print(speed)
        }
        else {
            throw CameraControllerError.noCamerasAvailable
        }
    }
    
    func configureWB(wb: Float) throws {
        let gains = kToRGBGains(k: Int(wb))
        if let camera = self.rearCamera {
            try camera.lockForConfiguration()
            camera.setWhiteBalanceModeLocked(with: gains, completionHandler: nil)
            camera.unlockForConfiguration()
        }
        else {
            throw CameraControllerError.noCamerasAvailable
        }
        
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Swift.Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
            
        else if let data = photo.fileDataRepresentation() {
            let image = UIImage(data: data)
            self.photoCaptureCompletionBlock?(image, nil)
        }
        else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
}

extension CameraController {
    // One decimal of precision,
    func getCurrentSpeed() -> Float {
        if let camera = self.rearCamera {
            return Float(camera.exposureDuration.seconds)
        }
        else {
            return -1
        }
    }
    func getCurrentISO() -> Int {
        if let camera = self.rearCamera {
            return Int(camera.iso)
        }
        else {
            return -1
        }
    }
}

extension CameraController {
    // 1500 K to 15000 K
    // https://github.com/mattdesl/kelvin-to-rgb/blob/master/index.js
    func kToRGBGains(k: Int) -> AVCaptureDevice.WhiteBalanceGains {
        let maxGain: Float
        if let camera = self.rearCamera {
            maxGain = camera.maxWhiteBalanceGain
        }
        else {
            maxGain = 1.0
        }
        let temp = Float(k / 100)
        var red: Float
        var blue: Float
        var green: Float
        
        if (temp <= 66) {
            red = 255
        } else {
            red = Float(temp - 60.0)
            red = Float(329.698727466 * pow(Double(red), -0.1332047592))
            if (red < 0) {
                red = 0
            }
            if (red > 255) {
                red = 255
            }
        }
        
        if (temp <= 66) {
            green = temp
            green = Float(99.4708025861 * log(Double(green)) - 161.1195681661)
            if (green < 0) {
                green = 0
            }
            if (green > 255) {
                green = 255
            }
        } else {
            green = temp - 60
            green = Float(288.1221695283 * pow(Double(green), -0.0755148492))
            if (green < 0) {
                green = 0
            }
            if (green > 255) {
                green = 255
            }
        }
        
        if (temp >= 66) {
            blue = 255
        } else {
            if (temp <= 19) {
                blue = 0
            } else {
                blue = temp - 10
                blue = Float(138.5177312231 * log(Double(blue)) - 305.0447927307)
                if (blue < 0) {
                    blue = 0
                }
                if (blue > 255) {
                    blue = 255
                }
            }
        }
        func gainFrom255(n: Float) -> Float {
            return 1.0 + (n / 255) * (maxGain - 1.0)
        }
        blue = gainFrom255(n: blue)
        red = gainFrom255(n: red)
        green = gainFrom255(n: green)
        print(blue)
        print(red)
        print(green)
        
        return AVCaptureDevice.WhiteBalanceGains(redGain: red, greenGain: green, blueGain: blue)
    }
    
}

extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
}
