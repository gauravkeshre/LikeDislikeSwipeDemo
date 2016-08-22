//
//  SecondViewController+Ripple.swift
//  GKSwipeToDeleteDemo
//
//  Created by Gaurav on 21/08/16.
//  Copyright © 2016 Hexagonal Loop. All rights reserved.
//

import Foundation
import UIKit
extension SecondViewController{
    
    //    #2b4661,#1fcde0,#3981bd,#FFFFFF,#227880,#FFFFFF,#ebe238,#41f276
    
    
    @IBAction func handleTapGesture(tap: UITapGestureRecognizer){
        let locationInView = tap.locationInView(self.view)
        
        let frame = CGRect(x: 0, y: 0, width: 12, height: 12)
        let circle = UIView(frame: frame)
        circle.userInteractionEnabled = false
        circle.layer.cornerRadius = (circle.frame.size.width / 2)
        circle.backgroundColor = UIColor(red: 97/255, green: 199/255, blue: 199/255, alpha: 1)
        self.view.addSubview(circle)
        self.view.bringSubviewToFront(circle)
        circle.alpha = 0.1

        circle.center = locationInView
        UIView .animateKeyframesWithDuration(0.5, delay: 0.0, options: .CalculationModeCubic, animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.3, animations: {
                    circle.alpha = 0.6
                    circle.transform = CGAffineTransformScale(CGAffineTransformIdentity, 7.0, 7.0)
                })
            UIView.addKeyframeWithRelativeStartTime(0.3, relativeDuration: 0.2, animations: {
                circle.alpha = 1.0
                circle.transform = CGAffineTransformScale(CGAffineTransformIdentity, 11.0, 11.0)
            })

            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.3, animations: {
                circle.alpha = 0.6
                circle.transform = CGAffineTransformScale(CGAffineTransformIdentity, 7.0, 7.0)
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.8, relativeDuration: 1.0, animations: {
                circle.alpha = 0.2
                circle.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
            })

            }) { (finished) in
                if finished{
                    circle.removeFromSuperview()
                }
        }
    }
}