//
//  SecondViewController.swift
//  GKSwipeToDeleteDemo
//
//  Created by Gaurav on 15/08/16.
//  Copyright © 2016 Hexagonal Loop. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet var labelView: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(FirstViewController.handlePanGesture(_:)))
        self.labelView.addGestureRecognizer(panGesture)
        self.view.bringSubviewToFront(self.labelView)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- Pan methods
    func handlePanGesture(pan: UIPanGestureRecognizer) {
        let state = pan.state
        let locationInView = pan.locationInView(self.view)
        struct Offset{
            static var x: CGFloat = 0
            static var y: CGFloat = 0
        }
        
        switch state {
        case.Began:
            Offset.x = locationInView.x - self.labelView.center.x
            Offset.y = locationInView.y - self.labelView.center.y
            
            self.labelView.layer.borderColor = UIColor.redColor().CGColor
            self.labelView.layer.borderWidth = 2.0
            
            break
        case .Changed:
            var center = locationInView
            center.x -= Offset.x
            center.y -= Offset.y
            self.labelView.center = center
            break
        case .Ended:
            fallthrough
        default:
            self.labelView.layer.borderColor = UIColor.clearColor().CGColor
            self.labelView.layer.borderWidth = 0.0
            
            break
            
        }
        
        
        
        
    }
    
}

