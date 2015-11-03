//
//  Cache.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import Foundation

class SessionCache {
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("movie-db")
    
    static func save(data: AnyObject) {
        let isSuccessfullSave = NSKeyedArchiver.archiveRootObject(data, toFile: ArchiveURL.path!)
        
        if !isSuccessfullSave {
            print("Saving failed")
        }
    }
    
    static func restoreSession() -> Session? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(ArchiveURL.path!) as? Session
    }

    static func restoreUser() -> Account? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(ArchiveURL.path!) as? Account
    }
    
}