//
//  ListDetailsManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class ListDetailsManager: ApiManager, SessionRequired {
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
        let url = ApiEndpoints.listDetails.withArgs(id)
        get(url, apiKey, detailsDelegate?.listDetailsLoadedSuccessfully, detailsDelegate?.listDetailsLoadingFailed)
    }
    
    func listDelete(listId id: String) {
        let url = ApiEndpoints.listDetails.withArgs(id)
        delete(url, apiKey, detailsDelegate?.listRemovedSuccessfully, detailsDelegate?.listRemovingFailed)
    }
}

protocol ListDetailsDelegate {
    
    func listDetailsLoadedSuccessfully(details: ListDetails) -> Void
    
    func listDetailsLoadingFailed(error: NSError) -> Void
    
    func listRemovedSuccessfully() -> Void
    
    func listRemovingFailed(error: NSError) -> Void
    
}