//
//  ViewController.swift
//  WeirdCamera
//
//  Created by Jash on 2019/2/1.
//  Copyright © 2019 Jash. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import GPUImage

class ViewController: UIViewController {
    
    private var previewImageView: GPUImageView!
    private var camera: GPUImageStillCamera!
    private var filter: GPUImageFilter!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        AVCaptureDevice.requestAccess(for: .video) { (granted: Bool) -> Void in
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCamera()
                    }
                }
            }
        }
    }
    
    private func setupCamera() {
        // 改 still camera
        camera = GPUImageStillCamera.init(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: AVCaptureDevice.Position.back)
        camera.outputImageOrientation = .portrait
        camera.frameRate = 30
        camera.horizontallyMirrorFrontFacingCamera = true
        
        filter = GPUImageFilter.init(fragmentShaderFromFile: "shader")
        
        previewImageView = GPUImageView(frame: view.bounds)
        view.addSubview(previewImageView)
        
        camera.addTarget(filter)
        filter.addTarget(previewImageView)
        
        camera.startCapture()
        
        setupOthers()
    }
    
    private func setupOthers() {
        let width = view.bounds.width
        let height = view.bounds.height
        
        let buttonWidth = CGFloat(floorf(Float(width/3*1)))
        
        let rotateButton = UIButton(type: .system)
        rotateButton.frame = CGRect(x: buttonWidth * 2, y: height - view.safeAreaInsets.bottom - buttonWidth, width: buttonWidth, height: buttonWidth)
        rotateButton.addTarget(self, action: #selector(rotateButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(rotateButton)
        
        let captureButton = UIButton(type: .system)
        captureButton.frame = CGRect(x: buttonWidth, y: height - view.safeAreaInsets.bottom - buttonWidth, width: buttonWidth, height: buttonWidth)
        captureButton.addTarget(self, action: #selector(captureButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(captureButton)
    }
    
    @objc private func rotateButtonTapped(_ sender: UIButton) {
        camera.rotateCamera()
    }
    
    @objc private func captureButtonTapped(_ sender: UIButton) {
        camera.capturePhotoAsImageProcessedUp(toFilter: filter) { (image, error) in
            if let validImage = image {
                UIImageWriteToSavedPhotosAlbum(validImage, nil, nil, nil)
            }
        }
    }
}
