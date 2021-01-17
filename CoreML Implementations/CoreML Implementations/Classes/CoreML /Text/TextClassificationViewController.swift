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
    
    
    let SPAM_ID = "spam"
    let SPAM_OUT_TEXT = "The input text was detected as spam!"
    let NOT_SPAM_OUT_TEXT = "The input text is a safe message..."
    
    
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
        
        if inputTextField.text?.isEmpty == true {
            // Show alert.
            return
        }
        
        let prediction = predictData(input: inputTextField.text!)
        
        let output = prediction == SPAM_ID ? SPAM_OUT_TEXT : NOT_SPAM_OUT_TEXT
        
        outputTextView.text = output
    }
    
    
    
    // MARK: - CoreML Methods
    
    func predictData(input:String) -> String {
        // Generate the prediction.
        if let prediction = try? coreMLModel.prediction(text: input) {
            return prediction.label
        }
        return ""
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
