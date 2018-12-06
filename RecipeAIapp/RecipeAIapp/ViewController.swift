//
//  ViewController.swift
//  RecipeAIapp
//
//  Created by Sajan on 12/4/18.
//  Copyright © 2018 Sajan. All rights reserved.
//


import UIKit
import AVKit

class ViewController: UIViewController, FrameExtractorDelegate{
    
    var frameExtractor: FrameExtractor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*let captureSession = AVCaptureSession()
         captureSession.sessionPreset = .photo
         
         guard let captureDevice = AVCaptureDevice.default(for: .video) else{return}
         
         guard let input = try? AVCaptureDeviceInput(device: captureDevice) else{return}
         
         captureSession.addInput(input)
         
         captureSession.startRunning()
         
         let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
         
         view.layer.addSublayer(previewLayer)
         previewLayer.frame = view.frame
         
         */
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
    }
    
    
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    func captured(image: UIImage) {
        imageView.image = image
    }
    
    
    
    
}


