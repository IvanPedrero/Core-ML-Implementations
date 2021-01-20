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
    
    // Core ML model variables.
    let coreMlModel = SoundClassifier()
    
    // Saved variables from analyzing.
    var classificationLabel: String = ""
    var classificationConfidence: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        // Determine the time of this result.
        let confidence = classification.confidence * 100.0
        let formattedConfidence = String(format: "%.2f%%", confidence)
        
        // Save the latest results, as the request will continue until finished the audio.
        classificationLabel = classification.identifier
        classificationConfidence = formattedConfidence
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
        var output = "Instrument detected: \(label) \n"
        output += "Confidence: \(confidence)%"
        
        // Show the results within the main thread.
        DispatchQueue.main.async {
            //self.activityLabel.text = output
        }
        print(output)
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

