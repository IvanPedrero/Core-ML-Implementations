//
//  WordTaggerViewController.swift
//  CoreML Implementations
//
//  Created by Ivan Pedrero on 17/01/21.
//

import UIKit
import CoreML

class WordTaggerViewController: UIViewController {
    
    @IBOutlet weak var inView: UIView!
    @IBOutlet weak var outView: UIView!
    
    @IBOutlet weak var predictButton: UIButton!
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var outputTextView: UITextView!
    
    // Core ML model variables.
    let coreMlModel = WordTagger()

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
        
        predictButton.roundBorders(radius: 10)
    }
    
    @IBAction func predictText(_ sender: Any) {
                
        if inputTextField.text?.isEmpty == true {
            outputTextView.text = "Enter a valid phrase..."
            return
        }
        
        let input = inputTextField.text
        
        var tokens = [String]()
        var labels = [String]()
        (tokens, labels) = predictData(input: input!)
        
        showResults(tokens: tokens, labels: labels)
        
    }
    
    
    // MARK: - CoreML Methods
    
    func predictData(input:String) -> ([String], [String]) {
        // Create the input.
        let wordTaggerInput = WordTaggerInput(text: input)
        
        // Generate the prediction.
        if let prediction = try? coreMlModel.prediction(input: wordTaggerInput) {
            return (prediction.tokens, prediction.labels)
        }
        
        // Failed, return empty arrays.
        return ([], [])
    }
    
    
    // MARK: - Output Methods
    
    func showResults(tokens:[String], labels:[String]) {
        var outputString = ""
        var productCount = 0
                
        for i in 0...labels.count - 1 {
            if labels[i] != "NONE"{
                outputString += "'\(tokens[i])' - refers to an Apple product \n\n"
                productCount += 1
            }
        }
        outputString += "--- \n\n"
        
        let productWordPercentage = (productCount * 100) / labels.count
        outputString += "Apple products appearance rate: \(productWordPercentage)%"
        
        outputTextView.text = outputString
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
