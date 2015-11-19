//
//  ColorUtil.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/10/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgb(red: Float, _ green: Float, _ blue: Float) -> UIColor? {
        return UIColor(colorLiteralRed: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
    }
    
}

extension NSURL {
    
    convenience init?(imagePath: String?, size: Int = 3) {
        if let path = imagePath {
            self.init(string: ApiEndpoints.poster(size, path))
        } else {
            return nil
        }
    }
}

extension UIImage {
    
    static func placeholder() -> UIImage? {
        return UIImage(named: "defaultPhoto")
    }
}

extension UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UIScrollView {
    
    @IBInspectable var topInset: CGFloat {
        get {
            return self.topInset
        }
        set {
            self.contentInset.top = newValue
        }
    }
    
    @IBInspectable var bottomInset: CGFloat {
        get {
            return self.topInset
        }
        set {
            self.contentInset.bottom = newValue
        }
    }
    
}