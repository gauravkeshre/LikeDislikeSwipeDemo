//
//  UIColor+Random.swift
//  GKSwipeToDeleteDemo
//
//  Created by Gaurav on 15/08/16.
//  Copyright © 2016 Hexagonal Loop. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    static var randomColor: UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}
