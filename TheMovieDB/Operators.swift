//
//  Operators.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/25/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import Foundation

infix operator +> { associativity left precedence 140 }

func +> (left: [String : String], right: [String : String]) -> ([String : String]) {
    var res = right
    for (key, value) in left {
        res[key] = value
    }
    return res
}

func +> (left: [String : String], right: NSMutableDictionary) -> (NSDictionary) {
    let res = right
    for (key, value) in left {
        res.setObject(value, forKey: key)
    }
    return res
}