//
//  PersonDetailsManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class PersonDetailsManager: ApiManager {
    var detailsDelegate: PersonDetailsDelegate?
    
    init(detailsDelegate: PersonDetailsDelegate?){
        self.detailsDelegate = detailsDelegate
        super.init()
    }
    
    func loadDetails(id: String) {
        let url = ApiEndpoints.personDetails.withArgs(id)
        get(url, apiKey, detailsDelegate?.personDetailsLoadedSuccessfully, detailsDelegate?.personDetailsLoadingFailed)
    }
    
    func loadCredits(id: String) {
        let url = ApiEndpoints.personCredits.withArgs(id)
        get(url, apiKey, detailsDelegate?.personCreditsLoadedScuccessfully, detailsDelegate?.personCreditsLoadingFailed)
    }
}

protocol PersonDetailsDelegate {
    
    func personDetailsLoadedSuccessfully(details: PersonInfo) -> Void
    
    func personDetailsLoadingFailed(error: NSError) -> Void
    
    func personCreditsLoadedScuccessfully(credits: PersonCredits) -> Void
    
    func personCreditsLoadingFailed(error: NSError) -> Void
}
