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

extension UIColor {
    
    static func rgb(red: Float, _ green: Float, _ blue: Float) -> UIColor {
        return UIColor(colorLiteralRed: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
    }
    
    static func transparent() -> UIColor {
        return UIColor.whiteColor().colorWithAlphaComponent(0)
    }
}

extension UIImage {
    
    static func placeholder() -> UIImage? {
        return UIImage(named: "defaultPhoto")
    }
}


