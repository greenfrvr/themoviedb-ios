//
//  ListDetailsManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class ListDetailsManager {
    let session: String
    let detailsDelegate: ListDetailsDelegate?
    
    init?(sessionId: String, detailsDelegate delegate: ListDetailsDelegate){
        self.session = sessionId
        self.detailsDelegate = delegate
        
        if sessionId.isEmpty {
            return nil
        }
    }
    
    func listDetails(listId id: String){
        let params = [
            "api_key": ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(String(format: ApiEndpoints.listDetails, id), parameters: params,
            success: { operation, response in
                if let details = Mapper<ListDetails>().map(response) {
                    self.detailsDelegate?.listDetailsLoadedSuccessfully(details)
                }
            },
            failure: { operation, error in self.detailsDelegate?.listDetailsLoadingFailed(error)
        })
    }
    
    func listDelete(listId id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session
        ]
        
        AFHTTPRequestOperationManager().DELETE(String(format: ApiEndpoints.listDetails, id), parameters: params,
            success: { operation, response in
                self.detailsDelegate?.listRemovedSuccessfully()
            },
            failure: { operation, error in self.detailsDelegate?.listRemovingFailed(error)
        })
    }
}

protocol ListDetailsDelegate {
    
    func listDetailsLoadedSuccessfully(details: ListDetails) -> Void
    
    func listDetailsLoadingFailed(error: NSError) -> Void
    
    func listRemovedSuccessfully() -> Void
    
    func listRemovingFailed(error: NSError) -> Void
    
}