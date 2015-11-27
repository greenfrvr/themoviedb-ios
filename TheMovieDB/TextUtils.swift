//
//  TextUtils.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/27/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import Foundation

extension String {
    
    func withArgs(args: CVarArgType...) -> String {
        return String(format: self, arguments: args)
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
    
    convenience init?(docsFilePath path: String) {
        let docsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        self.init(string: path, relativeToURL: docsUrl)
        
        if path.isEmpty {
            return nil
        }
    }
}