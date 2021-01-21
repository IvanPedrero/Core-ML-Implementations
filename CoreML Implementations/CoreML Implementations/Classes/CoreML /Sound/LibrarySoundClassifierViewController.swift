//
//  LibrarySoundClassifierViewController.swift
//  CoreML Implementations
//
//  Created by Ivan Pedrero on 19/01/21.
//

import UIKit
import MediaPlayer
import CoreML
import SoundAnalysis

class LibrarySoundClassifierViewController: UIViewController, MPMediaPickerControllerDelegate, SNResultsObserving {
    
    // UI Variables.
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var predictButton: UIButton!
    
    
    // Core ML model variables.
    let coreMlModel = SoundClassifier()
    
    // Saved variables from analyzing.
    var classificationLabel: String = ""
    var classificationConfidence: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpView()
    }
    
    /**
     Give some style to the view.
     */
    func setUpView(){
        outView.roundBorders(radius: 15)
        outView.drawShadow(radius: 10)
        
        predictButton.roundBorders(radius: 10)
    }
    
    @IBAction func loadAudio(_ sender: Any) {
        openMediaPicker()
    }
    
    
    // MARK: - Media Picker Methods
    
    
    func openMediaPicker(){
        let controller = MPMediaPickerController(mediaTypes: .anyAudio)
        controller.allowsPickingMultipleItems = false
        controller.showsCloudItems = false
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let mediaItems = mediaItemCollection.items
        predictData(items: mediaItems)
        self.dismiss(animated: true, completion: nil)
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
    }
    
    
    // MARK: - SNRequest Results
    
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        // Get the top classification.
        guard let result = result as? SNClassificationResult,
            let classification = result.classifications.first else { return }
        
        // Save the latest results, as the request will continue until finished the audio.
        classificationLabel = classification.identifier
        classificationConfidence = classification.confidence.formatConfidence()
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The the analysis failed: \(error.localizedDescription)")
        // TODO: Manage error.
        showError(error: error.localizedDescription)
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
        // This code will be executed when finished analyzing. Then show the results.
        showResults(label: classificationLabel, confidence: classificationConfidence)
    }
    
    
    // MARK: - CoreML Methods
    
    
    func predictData(items: [MPMediaItem]){
        // Get the first item, as only one song is allowed.
        guard let item = items.first else { return }
        
        // Get the song url.
        if let path: NSURL = item.assetURL as NSURL? {
            do {
                // Create an analyzer with the url of the file.
                let audioFileAnalyzer = try SNAudioFileAnalyzer(url: path as URL)
                
                // Prepare a new request for the trained model.
                do {
                    let request = try SNClassifySoundRequest(mlModel: coreMlModel.model)
                    try audioFileAnalyzer.add(request, withObserver: self)

                } catch {
                    print(error)
                }
                
                // Analyze the audio data.
                audioFileAnalyzer.analyze()
            } catch {
                showError(error: "There was an error in the prediction...")
            }
        }
    }
    
    
    // MARK: - Output Methods
    
    
    func showResults(label: String, confidence: String){
        // Output string.
        var output = "Instrument detected: \(label) \(label.getEmojiInstrument()) \n\n"
        output += "Confidence: \(confidence)%"
        
        // Show the results within the main thread.
        DispatchQueue.main.async {
            self.outputTextView.text = output
        }
    }
    
    func showError(error:String) {
        print(error)
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

