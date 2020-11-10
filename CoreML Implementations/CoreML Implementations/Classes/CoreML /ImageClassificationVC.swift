//
//  ImageClassificationVC.swift
//  CoreML Implementations
//
//  Created by Ivan Pedrero on 09/11/20.
//

import UIKit

class ImageClassificationVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var inView: UIView!
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var analyzeButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var imageChanged:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setRecognizers()
        
        inView.roundBorders(radius: 15)
        inView.drawShadow(radius: 10)
        outView.roundBorders(radius: 15)
        outView.drawShadow(radius: 10)
        analyzeButton.roundBorders(radius: 10)
    }
    
    // MARK:- Image tap methods
    
    private func setRecognizers(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onImageTap(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func onImageTap(tapGestureRecognizer: UITapGestureRecognizer) {
                
        if UIDevice.current.userInterfaceIdiom == .pad {
            showImageOptions(isIpad: true)
        }else{
            showImageOptions(isIpad: false)
        }
        
        
    }
    
    private func showImageOptions(isIpad: Bool){
        // Shown in iPad.
        if isIpad {
            let pictureAlert = UIAlertController(title: "Select picture from...", message: nil, preferredStyle: UIAlertController.Style.alert)

            pictureAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction!) in
                self.showCamera()
            }))

            pictureAlert.addAction(UIAlertAction(title: "Album", style: .default, handler: { (action: UIAlertAction!) in
                self.showAlbum()
            }))

            present(pictureAlert, animated: true, completion: nil)
        }
        // Shown in iPhone.
        else{
            let actionSheet = UIAlertController(title: "Select picture from...", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
                action in
                self.showCamera()
            }))
            actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: {
                action in
                self.showAlbum()
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    // MARK: - Photo delgate methods
    
    func showCamera(){
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum(){
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .savedPhotosAlbum
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            imageChanged = true
        }
        
        dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }
    
    
    // MARK:- Analyze methods
    
    @IBAction func analyzeAction(_ sender: Any) {
    
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
