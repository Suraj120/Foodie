//
//  ViewController.swift
//  Foodie
//
//  Created by Bibhuti Anand on 9/7/18.
//  Copyright © 2018 SurajKumar. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = userPickedImage
            //Need to convert the user image to core image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            
            guard let ciImage = CIImage(image: userPickedImage)
                else {
                    fatalError("could not convert to ciimage")
            }
             detect(image: ciImage)
        }
        
    }
    
    
    func detect(image: CIImage) {
        
            guard let model = try? VNCoreMLModel(for: Inceptionv3().model)
        else {
            fatalError("loading coreML model failed")
        }
        let request = VNCoreMLRequest(model:model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed tpo process image!!!")
            }
            print("results are:\(results)")
            
//            if let firsResult = results.first {
//
//                if !firsResult.identifier.isEmpty{
//                    self.navigationItem.title = firsResult.identifier
//                } else {
//                    self.navigationItem.title = "Un-Ambiguous!"
//                }
//
//            }
            
            let topResult = results.first!
            if (topResult.identifier.contains("hotdog")) {
                DispatchQueue.main.async {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                    self.navigationController?.navigationBar.isTranslucent = false
                    
                    
                }
            }
            else {
                DispatchQueue.main.async {
                    
                    self.navigationItem.title = "Not Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                    self.navigationController?.navigationBar.isTranslucent = false
                    
                }
            }
        
        }
        
        let handler = VNImageRequestHandler(ciImage:image)
        do {
        try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
}

