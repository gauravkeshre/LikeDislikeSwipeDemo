//
//  FirstViewController.swift
//  GKSwipeToDeleteDemo
//
//  Created by Gaurav on 15/08/16.
//  Copyright © 2016 Hexagonal Loop. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var btnLikeTray: UIButton!
    @IBOutlet weak var btnDislikeTray: UIButton!
    
    @IBOutlet var likeVCenterConstraint: NSLayoutConstraint!
    @IBOutlet var dislikeVCenterConstraint: NSLayoutConstraint!
    
    var numbers =  [String]()
    var colors =  [UIColor]()
    var panInProgress: Bool = false
    private lazy var allColors: [UIColor] = {
        var arr = [UIColor]()
        for i in 0 ... 9{
            arr.append(UIColor.randomColor)
        }
        return arr
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(FirstViewController.handlePanGesture(_:)))
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture)
        
        self.view.bringSubviewToFront(self.btnLikeTray)
        self.view.bringSubviewToFront(self.btnDislikeTray)
        self.btnLikeTray.layer.cornerRadius = self.btnLikeTray.frame.size.height/2
        self.btnDislikeTray.layer.cornerRadius = self.btnDislikeTray.frame.size.height/2
        
        ////Prepare Like unlike tray
        self.togglePreferenceTrays(shouldShow: false)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.numbers.removeAll()
        self.numbers.appendContentsOf(["One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten"])
        
        self.colors.removeAll()
        self.colors.appendContentsOf(allColors)
        
        self.tableView.reloadData()
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableViewDelegate methods
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.height - 44.0 - 20 - 64
    }
    
    //MARK:- UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numbers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DemoCell", forIndexPath: indexPath) as! DemoCell
        cell.label.text = self.numbers[indexPath.row]
        cell.label.backgroundColor = self.colors[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    //MARK:- UIGestureRecognizerDelegate methods

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer.classForCoder()) {
            let point =  (gestureRecognizer as! UIPanGestureRecognizer).translationInView(tableView)
            return ((fabs(point.x) / fabs(point.y))) > 1 ? true : false
        }
        return false
    }
    
    func autoDrop(fromIndexPath indexPath: NSIndexPath, cell: DemoCell,  action: DemoCellAction){
        
        /// Take Screensho
        self.togglePreferenceTrays(shouldShow: true)
        let snapshot = self.snapshopOfCell(cell.label) // RISKY 🏹
        snapshot.center = cell.center
        //        snapshot.alpha = 0.0
        print("BEGAN: adding snapshot")
        
        /// Place Screensho
        self.tableView.addSubview(snapshot)
        self.tableView.bringSubviewToFront(snapshot)
        cell.hidden = true
        
        /// Remove and preserve the content of this cell.
        self.colors.removeAtIndex(indexPath.row)
        self.numbers.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Automatic)
        
        ///StartAnimation
        let destinTrayView = (action == .like) ? self.btnLikeTray : self.btnDislikeTray
        
        let prct = self.btnDislikeTray.superview!.convertRect(destinTrayView.frame, toView: self.tableView)
        let destinCenter = CGPointMake(CGRectGetMidX(prct), CGRectGetMidY(prct))
        
        UIView.animateWithDuration(0.3, animations: {
            ///Move
            snapshot.center = destinCenter
            /// Scale the snapshot such that it reduces in size as it mooves away from center
            snapshot.transform = CGAffineTransformMakeScale(0.1,0.1)
            
        }) { (finished) in
            if finished{
                // clean
                snapshot.removeFromSuperview()
                self.togglePreferenceTrays(shouldShow: false)
            }
        }
    }
    
    
}


extension FirstViewController: DemoCellDelegate{
    func demoCell(cell: DemoCell, performAction: DemoCellAction){
        if let ip = self.tableView.indexPathForCell(cell){
            self.autoDrop(fromIndexPath:ip, cell: cell, action: performAction)
        }
    }
}
