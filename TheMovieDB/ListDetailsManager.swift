//
//  ListDetailsManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class ListDetailsManager: ApiManager, SessionRequired, LanguageRequired {
    var sessionId: String
    let detailsDelegate: ListDetailsDelegate?
    
    init?(sessionId: String, detailsDelegate delegate: ListDetailsDelegate){
        self.sessionId = sessionId
        self.detailsDelegate = delegate
        
        super.init()
        
        if sessionId.isEmpty {
            return nil
        }
    }
    
    func listDetails(listId id: String){
        get(urlDetails.withArgs(id), apiKey +> lang, detailsDelegate?.listDetailsLoadedSuccessfully, detailsDelegate?.listDetailsLoadingFailed)
    }
    
    func listDelete(listId id: String) {
        delete(urlDetails.withArgs(id), apiKey +> lang, detailsDelegate?.listRemovedSuccessfully, detailsDelegate?.listRemovingFailed)
    }
}

protocol ListDetailsDelegate {
    
    func listDetailsLoadedSuccessfully(details: CompilationDetails) -> Void
    
    func listDetailsLoadingFailed(error: NSError) -> Void
    
    func listRemovedSuccessfully() -> Void
    
    func listRemovingFailed(error: NSError) -> Void
    
}