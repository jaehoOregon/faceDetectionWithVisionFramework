//
//  ViewController.swift
//  faceDetectionWithVisionFramework
//
//  Created by Jaeho Jung on 2023/01/18.
//
// reference: iOS Swift Tutorial: Face Detection with Vision Framework
// use DispatchQueue.main.async:  https://velog.io/@termblur/Vision-%ED%94%84%EB%A0%88%EC%9E%84%EC%9B%8C%ED%81%AC%EB%A1%9C-%EC%96%BC%EA%B5%B4-%EC%9D%B8%EC%8B%9D-%EA%B8%B0%EB%8A%A5-%EA%B5%AC%ED%98%84

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imageOrientation = CGImagePropertyOrientation(.up)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = UIImage(named: "group1") {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            imageOrientation = CGImagePropertyOrientation(image.imageOrientation)
            
            guard let cgImage = image.cgImage else {return}
            
            setupVision(image: cgImage)
        }
    }
    
    private func setupVision (image: CGImage) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleFaceDetectionRequest)
        faceDetectionRequest.usesCPUOnly = true
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: self.imageOrientation, options: [:])
        do {
            try imageRequestHandler.perform([faceDetectionRequest])
            
        } catch let error as NSError {
            print(error)
            return
        }
    }
    
    
    private func handleFaceDetectionRequest (request: VNRequest?, error: Error?) {
        if let requestError = error as NSError? {
            print(requestError)
            return
        }
        
        DispatchQueue.main.async { [self] in
            guard let image = imageView.image else {return}
            guard let cgImage = image.cgImage else {return}

            let imageRect = self.determineScale(cgImage: cgImage, imageViewFrame: imageView.frame)
                
            self.imageView.layer.sublayers = nil

            if let results = request?.results as? [VNFaceObservation] {
                for observation in results {
                    let faceRect = convertUnitToPoint(originalImageRect: imageRect, targetRect: observation.boundingBox)
                        
                    let emojiRect = CGRect(x: faceRect.origin.x,
                                            y: faceRect.origin.y,
                                            width: faceRect.size.width + 5,
                                            height: faceRect.size.height)
                        
                    let textLayer = CATextLayer()
                    textLayer.string = "😾"
                    textLayer.fontSize = faceRect.width
                    textLayer.frame = emojiRect
                    textLayer.contentsScale = UIScreen.main.scale
                        
                    self.imageView.layer.addSublayer(textLayer)
                }
            }
        }
    }
}


