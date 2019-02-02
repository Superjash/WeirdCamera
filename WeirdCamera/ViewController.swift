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
    private var camera: GPUImageVideoCamera!
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
        previewImageView = GPUImageView(frame: view.bounds)
        view.addSubview(previewImageView)
        
        camera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.hd1920x1080.rawValue, cameraPosition: AVCaptureDevice.Position.back)
        camera.rotateCamera()
        camera.outputImageOrientation = .portrait
        camera.addTarget(filter)
        
        filter = GPUImageFilter(fragmentShaderFromFile: "CustomShader")
        filter.addTarget(previewImageView)
        
        camera.startCapture()
    }
}
