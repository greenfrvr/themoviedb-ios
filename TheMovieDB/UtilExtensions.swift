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
