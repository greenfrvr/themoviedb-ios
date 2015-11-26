//
//  FileCache.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/26/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import Foundation

class FileCache {
    
    static func queryDataURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent("search_query.plist")
        return fileURL
    }
    
    static func restoreLastQueryParams() -> (String, Int)? {
        let fileURL = queryDataURL()
        guard let path = fileURL.path where NSFileManager.defaultManager().fileExistsAtPath(path) else {
            return nil
        }
        
        guard let params = NSDictionary(contentsOfURL: fileURL),
            let query = params["query"] as? String, let scope = params["scope"] as? Int else {
            return nil
        }
        
        print("Restoring params: \(query) and \(scope)")
        return (query: query, scope: scope)
    }
    
    static func saveLastQueryParams(query: String?, _ scope: Int) {
        print("Saving params: \(query) and \(scope)")
        let params: NSDictionary = [ "query" : query ?? "", "scope" : scope ]
        params.writeToURL(queryDataURL(), atomically: true)
    }

}