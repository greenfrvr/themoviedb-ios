//
//  ViewUtils.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/27/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

extension UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UIScrollView {
    
    @IBInspectable var topInset: CGFloat {
        get { return self.topInset }
        set { self.contentInset.top = newValue }
    }
    
    @IBInspectable var bottomInset: CGFloat {
        get { return self.topInset }
        set { self.contentInset.bottom = newValue }
    }
    
    @IBInspectable var leftInset: CGFloat {
        get { return self.leftInset }
        set { self.contentInset.left = newValue }
    }
    
    @IBInspectable var rightInset: CGFloat {
        get { return self.rightInset }
        set { self.contentInset.right = newValue }
    }
}

extension UIView {
    static func animateWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, animations: () -> Void) {
        self.animateWithDuration(duration, delay: delay, options: [], animations: animations, completion: nil)
    }
}