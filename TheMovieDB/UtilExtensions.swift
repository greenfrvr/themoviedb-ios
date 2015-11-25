//
//  ColorUtil.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/10/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(titleKey: String, _ messageKey: String, _ cancelKey: String) {
        let title = NSLocalizedString(titleKey, comment: "")
        let message = NSLocalizedString(messageKey, comment: "")
        let cancel = NSLocalizedString(cancelKey, comment: "")
        
        UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancel).show()
    }
    
}

extension NSBundle {
    static func posterSizes() -> NSURL {
        return NSBundle.mainBundle().URLForResource("PosterSizes", withExtension: "plist")!
    }
    
    static func profileSizes() -> NSURL {
        return NSBundle.mainBundle().URLForResource("ProfileSizes", withExtension: "plist")!
    }
    
    static func backdropSizes() -> NSURL {
        return NSBundle.mainBundle().URLForResource("BackdropSizes", withExtension: "plist")!
    }
}

extension UIView {
    static func animateWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, animations: () -> Void) {
        self.animateWithDuration(duration, delay: delay, options: [], animations: animations, completion: nil)
    }
}

extension UIColor {
    
    static func rgb(red: Float, _ green: Float, _ blue: Float) -> UIColor {
        return UIColor(colorLiteralRed: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
    }
    
    static func transparent() -> UIColor {
        return UIColor.whiteColor().colorWithAlphaComponent(0)
    }
}

extension NSURL {
    
    convenience init?(posterPath: String?, size: Int = 1) {
        if let path = posterPath {
            self.init(string: ImagesConfig.poster(size, path))
        } else {
            return nil
        }
    }
    
    convenience init?(profilePath: String?, size: Int = 1) {
        if let path = profilePath {
            self.init(string: ImagesConfig.profile(size, path))
        } else {
            return nil
        }
    }
    
    convenience init?(backdropPath: String?, size: Int = 1) {
        if let path = backdropPath {
            self.init(string: ImagesConfig.backdrop(size, path))
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
    
    @IBInspectable var leftInset: CGFloat {
        get {
            return self.leftInset
        }
        set {
            self.contentInset.left = newValue
        }
    }
    
    @IBInspectable var rightInset: CGFloat {
        get {
            return self.rightInset
        }
        set {
            self.contentInset.right = newValue
        }
    }
}
