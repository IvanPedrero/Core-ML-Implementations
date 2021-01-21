//
//  Extensions.swift
//  CoreML Implementations
//
//  Created by Ivan Pedrero on 09/11/20.
//

import UIKit
import AVFoundation

extension UIView {
    func roundBorders(radius:CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func drawShadow(radius:CGFloat){
        self.layer.shadowRadius = radius
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = .zero
    }
}

extension AVCaptureVideoPreviewLayer {
    func resizeSubview(with bounds:CGRect){
        self.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.bounds = bounds
        self.position = CGPoint(x: bounds.midX, y: bounds.midY)
        self.contentsGravity = CALayerContentsGravity.resize
    }
}

extension Double {
    func formatConfidence() -> String {
        let perCentConfidence = self * 100.0
        return String(format: "%.2f%%", perCentConfidence)
    }
}

extension String {
    func getEmojiInstrument() -> String {
        switch self {
        case "drums":
            return "🥁"
        case "guitar":
            return "🎸"
        case "piano":
            return "🎹"
        case "sax":
            return "🎷"
        case "vio":
            return  "🎻"
        default:
            return ""
        }
    }
}
