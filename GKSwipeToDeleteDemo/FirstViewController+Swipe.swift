//
//  FirstViewController+Swipe.swift
//  GKSwipeToDeleteDemo
//
//  Created by Gaurav on 16/08/16.
//  Copyright © 2016 Hexagonal Loop. All rights reserved.
//

import Foundation
import UIKit
extension FirstViewController{
    
    
    
    //MARK:- Convenience methods
    func snapshopOfCell(inputView: UIView) -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 12.0
        cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        cellSnapshot.alpha = 0.7
        return cellSnapshot
    }
    
    //MARK:- Mathematics methods
    func scaleForOffset(x: CGFloat) -> CGFloat{
        if -0.5 ... 0.5 ~= x{
            return 1
        }
        let a = abs(x)
        let k = 1 - ( a / (a + 50))
        return max(min(k, 1.0), 0.2)
    }
    
    //MARK:- Gesture methods
    func handlePanGesture(pan: UILongPressGestureRecognizer) {
        let state = pan.state
        let locationInView = pan.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(locationInView)
        
        struct Cello {
            static var initialIndexPath : NSIndexPath? = nil
            
            static var isAnimating : Bool = false
            static var needToShow  : Bool = false
            static var snapshot    : UIView? = nil
            
            static var item     : String? = nil
            static var color    : UIColor? = nil
            
            static func clean(){
                Cello.initialIndexPath = nil
                Cello.snapshot?.removeFromSuperview()
                Cello.snapshot = nil
                Cello.item = nil
                Cello.color = nil
            }
        }
        struct Offset{
            static var x: CGFloat = 0
            static var y: CGFloat = 0
            static var trackX: CGFloat = 0
            
            static func centerFromPoint(c: CGPoint) -> CGPoint{
                var  center = c
                center.x -= Offset.x
                center.y -= Offset.y
                return center
            }
        }
        
        switch state {
        //MARK:- BEGAN PAN
        case.Began:
            guard indexPath != nil else{
                break;
            }
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
            /// Preseve Offset so that the view doesn't jumps to touch center
            Offset.x = locationInView.x - cell.center.x
            Offset.y = locationInView.y - cell.center.y
            
            /// Preserve the cell indexpath
            Cello.initialIndexPath = indexPath
            
            /// Take a screenshot of the cell
            Cello.snapshot = self.snapshopOfCell((cell as! DemoCell).label) // RISKY 🏹
            Cello.snapshot?.center = cell.center
            Cello.snapshot?.alpha = 0.0
            if Cello.snapshot != nil{
                self.tableView.addSubview(Cello.snapshot! )
            }
            
            /// Make the like dislike tray visible
            //            self.togglePreferenceTrays()
            
            /// Remove and preserve the content of this cell.
            Cello.color = colors.removeAtIndex(Cello.initialIndexPath!.row)
            Cello.item =  numbers.removeAtIndex(Cello.initialIndexPath!.row)
            tableView.deleteRowsAtIndexPaths([Cello.initialIndexPath!], withRowAnimation:.Automatic )
            
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                Cello.isAnimating = true
                Cello.snapshot?.alpha = 0.98
                cell.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        Cello.isAnimating = false
                        if Cello.needToShow{
                            Cello.needToShow = false
                            UIView.animateWithDuration(0.25, animations: {
                                cell.alpha = 1
                            })
                        }else{
                            cell.hidden = true
                        }
                    }
            })
            break
            
        case .Changed:
            //MARK:- CHANGE PAN
            
            Cello.snapshot?.center = Offset.centerFromPoint(locationInView)
            let diff = self.tableView.center.x - locationInView.x + Offset.x
            self.togglePreferenceTraysForOffset(diff)
            /// Scale the snapshot such that it reduces in size as it mooves away from center
            let t = scaleForOffset(diff)
            Cello.snapshot?.transform = CGAffineTransformMakeScale(t,t)
            break
        case .Ended: /// Cancelled
            //MARK:- END PAN =================================================================
            fallthrough
        default:
            self.togglePreferenceTrays(shouldShow: false) // hide them
            if self.checkCollision(Cello.snapshot){
                
            }else if let it = Cello.item, let ip = Cello.initialIndexPath, let col = Cello.color{
                numbers.insert(it, atIndex: ip.row)
                colors.insert(col, atIndex: ip.row)
                self.tableView.insertRowsAtIndexPaths([ip], withRowAnimation: .Fade)
            }
            Cello.clean()
            
            break
        }
    }
    
    
    func togglePreferenceTraysForOffset(difference: CGFloat){
        if difference > -1 {
            self.likeVCenterConstraint.active = false
            self.dislikeVCenterConstraint.active = true
            
        }else if difference < 1 {
            self.likeVCenterConstraint.active = true
            self.dislikeVCenterConstraint.active = false
            
        }else{
            self.likeVCenterConstraint.active = false
            self.dislikeVCenterConstraint.active = false
        }
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutSubviews()
        })
    }
    
    func togglePreferenceTrays(shouldShow show: Bool = true){
        self.likeVCenterConstraint.active = show
        self.dislikeVCenterConstraint.active = show
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutSubviews()
        })
    }
    
    
    func checkCollision(testView: UIView?) -> Bool{
        guard let view = testView else{
            return false
        }
        let rect1 = self.btnLikeTray.frame
        let rect2 = self.btnDislikeTray.frame
        let rect3 = view.frame //view.convertRect(view.frame, toView: self.btnLikeTray.superview)
        
        var flag = CGRectIntersectsRect(rect3, rect1)
        flag = flag ||  CGRectIntersectsRect(rect3, rect2)
        
        print("__-INTERSECTING : \(flag) ___")
        
        return flag
    }
    
}

