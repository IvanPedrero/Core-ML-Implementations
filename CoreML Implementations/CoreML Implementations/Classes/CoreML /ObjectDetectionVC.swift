//
//  ImageClassificationVC.swift
//  CoreML Implementations
//
//  Created by Ivan Pedrero on 09/11/20.
//

import UIKit
import Vision
import AVFoundation

class ObjectDetectionVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // UI variables.
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var resultTextView: UITextView!
    
    // Core ML model variables.
    let coreMLModel: MLModel = {
        do {
            let config = MLModelConfiguration()
            return try YOLOv3Tiny(configuration: config).model
        } catch {
            fatalError("Couldn't create the model: \(error)")
        }
    }()
    private var requests = [VNRequest]()
    
    // Video variables.
    var previewLayer:AVCaptureVideoPreviewLayer!
    var bufferSize: CGSize = .zero
    private var detectionOverlay: CALayer! = nil
    
    
    // MARK:- View lyfe cycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Start the camera functions.
        setUpCamera()
        setupLayers()
        updateLayerGeometry()
        setupVision()
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
    
    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: previewLayer.bounds.midX, y: previewLayer.bounds.midY)
        previewLayer.addSublayer(detectionOverlay)
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
        
        do {
            try captureDevice.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((captureDevice.activeFormat.formatDescription))
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            captureDevice.unlockForConfiguration()
        } catch {
            print(error)
        }
        
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

extension ObjectDetectionVC {
    
    /**
     Function used to predict what an image will be using a core ml model.
     - Parameter pixelBuffer: The image saved in the session buffer.
     */
    func predictUsingModel(pixelBuffer:CVPixelBuffer) {
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    /**
     Function used to set up the core ml model.
     */
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil
        

        do {
            guard let model = try? VNCoreMLModel(for: coreMLModel ) else { return NSError() }
            let objectRecognition = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
            self.requests = [objectRecognition]
        }
        
        return error
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            showResults(identifier: topLabelObservation.identifier, confidence: topLabelObservation.confidence)
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
            view.layer.addSublayer(detectionOverlay)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
    
    func updateLayerGeometry() {
        let bounds = previewLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
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
