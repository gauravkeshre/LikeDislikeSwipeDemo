//
//  FirstViewController.swift
//  GKSwipeToDeleteDemo
//
//  Created by Gaurav on 15/08/16.
//  Copyright © 2016 Hexagonal Loop. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var btnLikeTray: UIButton!
    @IBOutlet weak var btnDislikeTray: UIButton!
    
    @IBOutlet var likeVCenterConstraint: NSLayoutConstraint!
    @IBOutlet var dislikeVCenterConstraint: NSLayoutConstraint!
    
    var numbers =  [String]()
    var colors =  [UIColor]()
    
    private lazy var allColors: [UIColor] = {
        var arr = [UIColor]()
        for i in 0 ... 9{
            arr.append(UIColor.randomColor)
        }
        return arr
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UILongPressGestureRecognizer(target: self, action: #selector(FirstViewController.handlePanGesture(_:)))
        self.tableView.addGestureRecognizer(panGesture)
        
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
        return 250 //self.view.frame.height - 44.0 - 20 - 64
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    //MARK:- UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numbers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DemoCell", forIndexPath: indexPath) as! DemoCell
        cell.label.text = self.numbers[indexPath.row]
        cell.label.backgroundColor = self.colors[indexPath.row]
        return cell
    }
}

