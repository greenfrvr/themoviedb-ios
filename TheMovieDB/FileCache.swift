//
//  FileCache.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/26/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import Foundation

class FileCache {
    
    static func restoreLastQueryParams() -> (String, Int)? {
        guard let url = NSURL(docsFilePath: "search_query.plist") else {
            print("Cannot create url for last search query")
            return nil
        }
        
        guard let params = NSDictionary(contentsOfURL: url),
            let query = params["query"] as? String, let scope = params["scope"] as? Int else {
            print("Looks like there is nothing to retreive")
            return nil
        }
        
        return (query: query, scope: scope)
    }
    
    static func saveLastQueryParams(query: String?, _ scope: Int) {
        guard let url = NSURL(docsFilePath: "search_query.plist") else {
            print("Cannot create url for last search query")
            return
        }
        
        let params: NSDictionary = [ "query" : query ?? "", "scope" : scope ]
        params.writeToURL(url, atomically: true)
    }
    
}