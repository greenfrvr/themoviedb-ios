//
//  UILabelWithPadding.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/4/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class UILabelWithPadding: UILabel {

    var paddingLeft = 0
    var paddingRight = 0
    var padding: Int {
        get {
            return paddingLeft
        }
        set {
            paddingLeft = newValue
            paddingRight = newValue
        }
    }
    
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets.init(top: CGFloat(0), left: CGFloat(paddingLeft), bottom: CGFloat(0), right: CGFloat(paddingRight))
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
}
