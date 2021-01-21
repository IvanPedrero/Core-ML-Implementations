import UIKit
import SoundAnalysis

class SoundClassifierViewController: UIViewController, SNResultsObserving {
    
    // UI Variables.
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var predictButton: UIButton!
    
    // Core ML model variables.
    let coreMlModel = SoundClassifier()
    
    // Audio variables.
    var audioEngine: AVAudioEngine?
    var inputBus: AVAudioNodeBus?
    var inputFormat: AVAudioFormat?
    var streamAnalyzer: SNAudioStreamAnalyzer?
    
    // Private variables.
    private var isRecording: Bool = false
    
    // Constants.
    private let BUFFER_8K:UInt32 = 8192
    private let NOT_RECORDING_LABEL = "Not recording..."
    private let START_RECORDING_LABEL = "Start recording"
    private let STOP_RECORDING_LABEL = "Stop recording"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpView()
        
        initAudioEngine()
        initRecordingPrediction()
        stopRecording()
    }
    
    /**
     Give some style to the view.
     */
    func setUpView(){
        outView.roundBorders(radius: 15)
        outView.drawShadow(radius: 10)
        
        predictButton.roundBorders(radius: 10)
    }
    
    
    // MARK:- Recording Button Methods

    @IBAction func startRecording(_ sender: Any) {
        if !isRecording {
            startRecording()
        }else{
            stopRecording()
        }
    }
    
    func startRecording() {
        predictButton.setTitle(STOP_RECORDING_LABEL, for: .normal)
        isRecording = true
    }
    
    func stopRecording() {
        predictButton.setTitle(START_RECORDING_LABEL, for: .normal)
        self.outputTextView.text = NOT_RECORDING_LABEL
        isRecording = false
    }
    
    // MARK:- Init Methods
    
    func initAudioEngine(){
        // Create the input variables.
        audioEngine = AVAudioEngine()
        inputBus = AVAudioNodeBus(0)
        inputFormat = audioEngine?.inputNode.inputFormat(forBus: inputBus!)
        
        // Try to create a new stream analyzer.
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat!)
        do {
            try audioEngine?.start()
        } catch {
            print("Unable to start AVAudioEngine: \(error.localizedDescription)")
        }
    }
    
    func initRecordingPrediction() {
        do {
            // Prepare a the request and the core ml model.
            let request = try SNClassifySoundRequest(mlModel: coreMlModel.model)
            try streamAnalyzer?.add(request, withObserver: self)
            
            // Serial dispatch queue used to analyze incoming audio buffers.
            let soundClassifierQueue = DispatchQueue(label: "com.apple.SoundClassifierQueue")
            
            // Install an audio tap on the audio engine's input node.
            audioEngine!.inputNode.installTap(onBus: inputBus!, bufferSize: BUFFER_8K, format: inputFormat) { buffer, time in
                // Analyze the current audio buffer.
                soundClassifierQueue.async {
                    self.streamAnalyzer!.analyze(buffer, atAudioFramePosition: time.sampleTime)
                }
            }
        } catch {
            print("Unable to prepare the request: \(error.localizedDescription)")
            return
        }
    }
    

    // MARK:- SNRequest Results
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        
        // Don't analyze anything if not recording.
        if !isRecording { return }
        
        // Show the results.
        showResults(result: result)
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The the analyzis failed: \(error.localizedDescription)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully, ready to analyze...")
    }
    
    
    // MARK: - Output Methods
    
    func showResults(result: SNResult){
        // Get the first classification.
        guard let result = result as? SNClassificationResult,
            let classification = result.classifications.first else { return }

        // Get the confidence.
        let label = classification.identifier
        let confidence = classification.confidence.formatConfidence()

        // Output string.
        var output = "Instrument detected: \(label) \(label.getEmojiInstrument()) \n\n"
        output += "Confidence: \(confidence)%"
        
        // Show the results within the main thread.
        DispatchQueue.main.async {
            self.outputTextView.text = output
        }
    }
}
