//
//  DemoCell.swift
//  GKSwipeToDeleteDemo
//
//  Created by Gaurav on 15/08/16.
//  Copyright © 2016 Hexagonal Loop. All rights reserved.
//

import UIKit
enum DemoCellAction: Int {
    case like = 1024, dislike = 1025
    
}
protocol DemoCellDelegate: class{
    func demoCell(cell: DemoCell, performAction: DemoCellAction)
}
class DemoCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var btnLike: UIButton!{
        didSet{
            self.btnLike.tag = DemoCellAction.like.rawValue
        }
    }
    @IBOutlet weak var btnDislike: UIButton!{
        didSet{
            self.btnDislike.tag = DemoCellAction.dislike.rawValue
        }
    }
    
    weak var delegate: DemoCellDelegate? = nil
    
    
    @IBAction func handleAction(sender:UIButton){
        self.delegate?.demoCell(self, performAction: DemoCellAction(rawValue: sender.tag)!)
    }
}
