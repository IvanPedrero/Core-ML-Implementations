//
//  ImageClassificationVC.swift
//  CoreML Implementations
//
//  Created by Ivan Pedrero on 09/11/20.
//

import UIKit
import Vision
import AVFoundation

class ImageClassificationVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // UI variables.
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var resultTextView: UITextView!
    
    // Core ML model variables.
    let coreMLModel: MLModel = {
        do {
            let config = MLModelConfiguration()
            return try MobileNetV2(configuration: config).model
        } catch {
            fatalError("Couldn't create the model: \(error)")
        }
    }()
    
    // Video variables.
    var previewLayer:AVCaptureVideoPreviewLayer!
    
    
    // MARK:- View lyfe cycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Start the camera functions.
        setUpCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if previewLayer != nil {
            previewLayer.resizeSubview(with: videoPreview.bounds)
        }
        
    }
    
    // MARK:- View style methods.
    
    /**
     Give some style to the view.
     */
    func setUpView(){
        outView.roundBorders(radius: 15)
        outView.drawShadow(radius: 10)
        videoPreview.drawShadow(radius: 10)
    }
    
    // MARK:- Video capture methods.
    
    /**
     Use this function to initialize the capture sesssion and to add the preview layer to a view.
     */
    func setUpCamera(){
        // Create the capture session.
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        // Create the layer for the view.
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreview.layer.addSublayer(previewLayer)
        previewLayer.frame = videoPreview.frame
        previewLayer.resizeSubview(with: videoPreview.bounds)
        
        // Analyze what the camera is showing.
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    /**
     Notifies the delegate that a new video frame was written.
     */
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Get the image from the pixel buffer.
        guard let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Predict using the model.
        predictUsingModel(pixelBuffer: pixelBuffer)
    }
    
}

// MARK:- Machine learning using CoreML extension.

extension ImageClassificationVC {
    
    /**
     Function used to predict what an image will be using a core ml model.
     - Parameter pixelBuffer: The image saved in the session buffer.
     */
    func predictUsingModel(pixelBuffer:CVPixelBuffer) {
        // Get the Core ML model.
        guard let model = try? VNCoreMLModel(for: coreMLModel ) else { return }

        // Define the request handler.
        let request = VNCoreMLRequest(model: model) { (result, error) in
            
            // Manage the error.
            if error != nil {
                print("Error in the request: \(String(describing: error))")
                return
            }
            
            // Get the results.
            guard let results = result.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            
            // Show the results in the view.
            self.showResults(identifier: firstObservation.identifier, confidence: firstObservation.confidence)
        }
        
        // Perform the request.
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    /**
    This function will show the results in the view using the main thread to update the text.
     */
    func showResults(identifier:String, confidence: VNConfidence){
        DispatchQueue.main.async {
            self.resultTextView.text = """
            The object is a \(identifier)


            % \(confidence) confidence
            """
        }
    }
}
