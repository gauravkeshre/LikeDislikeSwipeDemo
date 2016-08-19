//
//  FirstViewController+Swipe.swift
//  GKSwipeToDeleteDemo
//
//  Created by Gaurav on 16/08/16.
//  Copyright © 2016 Hexagonal Loop. All rights reserved.
//

import Foundation
import UIKit
enum CollisionTest {
    case like, dislike, none
}
extension FirstViewController{
    
    
    
    //MARK:- Convenience methods
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        let container : UIView = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        container.backgroundColor = UIColor.clearColor()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = true
        cellSnapshot.layer.cornerRadius = 12.0
        container.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        container.layer.shadowRadius = 8.0
        container.layer.shadowOpacity = 0.5
        container.alpha = 0.7
        container.addSubview(cellSnapshot)
        return container
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
    func handlePanGesture(pan: UIPanGestureRecognizer) {
        let state = pan.state
        guard self.numbers.count > 0 || self.panInProgress == true else{
            return
        }
        
        let locationInView = pan.locationInView(self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(locationInView)
        
        //print("😎 IndexPath Detected [Row]: \(indexPath!.row)")
        
        struct Path {
            static var initialIndexPath : NSIndexPath? = nil
        }
        struct Cello {
            //            static var initialIndexPath : NSIndexPath? = nil
            static var snapshot : UIView?   = nil
            static var item     : String?   = nil
            static var color    : UIColor?  = nil
            static var snapshotSize    : CGSize?  = nil
            
            static func clean(){
                Cello.snapshot!.removeFromSuperview()
                Cello.snapshot = nil
                Cello.item = nil
                Cello.color = nil
                Cello.snapshotSize = nil
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
            panInProgress = true
            print("BEGAN:..")
            guard indexPath != nil else{
                print("BEGAN: index path is nil. Returning..")
                break;
            }
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
            
            /// Preseve Offset so that the view doesn't jumps to touch center
            Offset.x = locationInView.x - cell.center.x
            Offset.y = locationInView.y - cell.center.y
            
            /// Preserve the cell indexpath
            Path.initialIndexPath = indexPath
            
            /// Take a screenshot of the cell
            Cello.snapshot = self.snapshopOfCell(cell) // RISKY 🏹
            Cello.snapshotSize = Cello.snapshot?.frame.size
            Cello.snapshot?.center = cell.center
            Cello.snapshot?.alpha = 0.0
            if Cello.snapshot != nil{
                print("BEGAN: adding snapshot")
                self.tableView!.addSubview(Cello.snapshot! )
                self.tableView.bringSubviewToFront(Cello.snapshot!)
            }else{
                print("BEGAN: snapshot is nil. Returning..")
                Cello.clean()
                return
            }
            
            Cello.snapshot?.alpha = 0.8
            cell.hidden = true
            
            /// Remove and preserve the content of this cell.
            Cello.color = colors.removeAtIndex(Path.initialIndexPath!.row)
            Cello.item =  numbers.removeAtIndex(Path.initialIndexPath!.row)
            self.tableView.deleteRowsAtIndexPaths([Path.initialIndexPath!], withRowAnimation:.Automatic)
            break
            
        case .Changed:
            //MARK:- CHANGE PAN
            
            Cello.snapshot?.center = Offset.centerFromPoint(locationInView)
            let diff = self.tableView.center.x - locationInView.x + Offset.x
            self.togglePreferenceTraysForOffset(diff)
            /// Scale the snapshot such that it reduces in size as it mooves away from center
            let aspect = Cello.snapshotSize!.width / Cello.snapshotSize!.height
            
            
            let t = scaleForOffset(diff)
            Cello.snapshot?.transform = CGAffineTransformMakeScale(t,t*aspect)
            
            break
        case .Cancelled:
            fallthrough
        case .Ended:
            fallthrough
        default: /// Ended OR Cancelled
            //MARK:- END PAN =================================================================
            panInProgress = false
            switch self.checkCollision(Cello.snapshot) {
            case .like:
                fallthrough
            case .dislike:
                print("🎯")
                /// Remove and preserve the content of this cell.
                //                Cello.color = colors.removeAtIndex(Path.initialIndexPath!.row)
                //                Cello.item =  numbers.removeAtIndex(Path.initialIndexPath!.row)
                //                self.tableView.deleteRowsAtIndexPaths([Path.initialIndexPath!], withRowAnimation:.Automatic)
                
                break
            case .none:
                if let it = Cello.item,
                    let ip = Path.initialIndexPath,
                    let col = Cello.color
                {
                    self.numbers.insert(it, atIndex: ip.row)
                    self.colors.insert(col, atIndex: ip.row)
                    self.tableView.insertRowsAtIndexPaths([ip], withRowAnimation: .None)
                }else{
                    print("it, ip, col one of them is nil");
                }
                break
            }
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                Cello.snapshot!.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        Cello.clean()
                        self.togglePreferenceTrays(shouldShow: false) // hide them
                    }
            })
            break
        }
    }
    
    
    func togglePreferenceTraysForOffset(difference: CGFloat){
        if difference > 1 {
            self.likeVCenterConstraint.active = false
            self.dislikeVCenterConstraint.active = true
            
        }else if difference < -1 {
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
    
    
    func checkCollision(testView: UIView?) -> CollisionTest{
        guard let view = testView else{
            return .none
        }
        let rect1 = self.btnLikeTray.frame
        let rect2 = self.btnDislikeTray.frame
        
        let snapshotRect = self.tableView.convertRect(view.frame, toView: self.btnLikeTray.superview)
        
        let like = CGRectIntersectsRect(snapshotRect, rect1)
        let dislike =  CGRectIntersectsRect(snapshotRect, rect2)
        
        if like{
            print("Collision happened at LiKE");
            return .like
        }
        
        if dislike{
            print("Collision happened at DIS-LiKE");
            return .dislike
        }
        return .none
    }
}

