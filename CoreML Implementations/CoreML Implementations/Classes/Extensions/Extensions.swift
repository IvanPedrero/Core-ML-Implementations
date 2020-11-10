//
//  Extensions.swift
//  CoreML Implementations
//
//  Created by Ivan Pedrero on 09/11/20.
//

import UIKit

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
