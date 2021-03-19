//
//  UIView+Ext.swift
//  OpenWaypoint
//
//  Created by Jeff on 2021/3/16.
//

import UIKit


extension UIView {
    
    func startDragging(_ yOffset: CGFloat = -20) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layer.opacity = 0.8
            
            self.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(1.5, 1.5, 1.0), 0, yOffset, yOffset)
        }, completion: nil)
        
        // Initialize haptic feedback generator and give the user a light thud.
        if #available(iOS 10.0, *) {
            let iFeedback = UIImpactFeedbackGenerator(style: .light)
            iFeedback.impactOccurred()
        }
    }

    func endDragging() {

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layer.opacity = 1
            self.layer.transform = CATransform3DIdentity
        }, completion: nil)
        
        // Give the user more haptic feedback when they drop the annotation.
        if #available(iOS 10.0, *) {
            let iFeedback = UIImpactFeedbackGenerator(style: .light)
            iFeedback.impactOccurred()
        }
    }
}
