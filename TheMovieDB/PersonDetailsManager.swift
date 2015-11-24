//
//  PersonDetailsManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class PersonDetailsManager {
    
    var detailsDelegate: PersonDetailsDelegate?
    
    init(detailsDelegate: PersonDetailsDelegate?){
        self.detailsDelegate = detailsDelegate
    }
    
    func loadDetails(id: String) {
        let params = [
            "api_key" : ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(String(format: ApiEndpoints.personDetails, id), parameters: params,
            success: { operation, response in
                if let results = Mapper<PersonInfo>().map(response) {
                    self.detailsDelegate?.personDetailsLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.personDetailsLoadingFailed(error) }
        )
    }
    
    func loadCredits(id: String) {
        let params = [
            "api_key" : ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(String(format: ApiEndpoints.personCredits, id), parameters: params,
            success: { operation, response in
                if let results = Mapper<PersonCredits>().map(response) {
                    self.detailsDelegate?.personCreditsLoadedScuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.personCreditsLoadingFailed(error) }
        )
    }
}

protocol PersonDetailsDelegate {
    
    func personDetailsLoadedSuccessfully(details: PersonInfo) -> Void
    
    func personDetailsLoadingFailed(error: NSError) -> Void
    
    func personCreditsLoadedScuccessfully(credits: PersonCredits) -> Void
    
    func personCreditsLoadingFailed(error: NSError) -> Void
}
