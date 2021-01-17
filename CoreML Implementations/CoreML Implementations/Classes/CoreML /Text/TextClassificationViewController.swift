//
//  TextClassificationViewController.swift
//  CoreML Implementations
//
//  Created by Ivan Pedrero on 16/01/21.
//

import UIKit
import CoreML

class TextClassificationViewController: UIViewController {
    
    @IBOutlet weak var inView: UIView!
    @IBOutlet weak var outView: UIView!
    
    @IBOutlet weak var dataSourceButton: UIButton!
    @IBOutlet weak var predictButton: UIButton!
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var outputTextView: UITextView!
    
    // (0 = negative, 2 = neutral, 4 = positive)
    let NEGATIVE_SENTIMENT = "0"
    let NEUTRAL_SENTIMENT = "1"
    let POSITIVE_SENTIMENT = "4"
    let DATASET_URL = "http://help.sentiment140.com/"
    
    
    // Core ML model variables.
    let coreMLModel = TextClassifier()

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
        inView.roundBorders(radius: 15)
        inView.drawShadow(radius: 10)
        
        dataSourceButton.roundBorders(radius: 10)
        predictButton.roundBorders(radius: 10)
    }
    
    
    @IBAction func predictText(_ sender: Any) {
        
        var output = "Neutral sentiment detected 😶"
        
        if inputTextField.text?.isEmpty == true {
            outputTextView.text = output
            return
        }
        
        let prediction = predictData(input: inputTextField.text!)
        
        
        if prediction == NEGATIVE_SENTIMENT{
            output = "Negative sentiment detected 😠"
        }
        else if prediction == NEUTRAL_SENTIMENT {
            output = "Neutral sentiment detected 😶"
        }
        else if prediction == POSITIVE_SENTIMENT {
            output = "Positive sentiment detected 😄"
        }
         
        outputTextView.text = output
    }
    
    
    @IBAction func openDataSources(_ sender: Any) {
        openWebsite(site: DATASET_URL)
    }
    
    
    
    // MARK: - CoreML Methods
    
    func predictData(input:String) -> String {
        // Generate the prediction.
        if let prediction = try? coreMLModel.prediction(text: input) {
            return prediction.label
        }
        return ""
    }
    
    
    // MARK: - Data Sources Link Methods
    
    func openWebsite(site:String){
        if let url = URL(string: site) { UIApplication.shared.open(url) }
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
