
//
//  PhotoLibViewController.swift
//  RecipeAIapp
//
//  Created by Sajan on 12/5/18.
//  Copyright © 2018 Sajan. All rights reserved.
//


import UIKit
import AVKit
import Firebase
import FirebaseMLVision
import FirebaseMLModelInterpreter

class PhotoLibViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var ResultLbl: UILabel!
    
    // models
    var interpreter: ModelInterpreter!
    var labels: [String]!
    var img: UIImage!
    var ioOptions: ModelInputOutputOptions!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modelSetup()
        // Do any additional setup after loading the view.
    }
    
    func modelSetup() {
        
        //Cloud modeling
        let conditions = ModelDownloadConditions(isWiFiRequired: true, canDownloadInBackground: true)
        let cloudModelSource = CloudModelSource(
            modelName: "vegetables",
            enableModelUpdates: true,
            initialConditions: conditions,
            updateConditions: conditions
        )
        _ = ModelManager.modelManager().register(cloudModelSource)
        
        
        //Local Modeling
        guard let modelPath = Bundle.main.path(forResource: "graph", ofType: "tflite") else {
            return
        }
        let localModelSource = LocalModelSource(modelName: "graph", path: modelPath)
        
        
        ModelManager.modelManager().register(localModelSource)
        
        let options = ModelOptions(
            cloudModelName: "vegetables",
            localModelName: "graph"
        )
        interpreter = ModelInterpreter.modelInterpreter(options: options)
        
        ioOptions = ModelInputOutputOptions()
        do {
            try ioOptions.setInputFormat(index: 0, type: ModelElementType.uInt8, dimensions: [1, 224, 224, 3])
            try ioOptions.setOutputFormat(index: 0, type: ModelElementType.uInt8, dimensions: [1, 1000])
        } catch let error as NSError {
            print("Failed to set input or output format with error: \(error.localizedDescription)")
        }
    }
    
    
    @IBAction func accessPhotos(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        imageDisplay.image = image
        img = image
        
        picker.dismiss(animated: true, completion: nil)
        LookUp()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func LookUp() {
        
        let vision = Vision.vision() 
        let labelDetectorObj = vision.labelDetector()
        let visionImageObj = VisionImage(image: img)
        
        labelDetectorObj.detect(in: visionImageObj) { (labels, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // This will check highest confidence label
            let predictionLabel = labels!.max { lhs, rhs in
                return lhs.confidence < rhs.confidence
            }
            
            for label in labels! {
                print("\(label.label) has confidence \(label.confidence)")
                self.ResultLbl.text = predictionLabel?.label
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
