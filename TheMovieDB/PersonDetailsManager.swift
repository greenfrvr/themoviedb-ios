//
//  PersonDetailsManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class PersonDetailsManager: ApiManager, LanguageRequired {
    var detailsDelegate: PersonDetailsDelegate?
    
    init(detailsDelegate: PersonDetailsDelegate?){
        self.detailsDelegate = detailsDelegate
        super.init()
    }
    
    func loadDetails(id: String) {
        get(urlDetails.withArgs(id), apiKey +> lang, detailsDelegate?.personDetailsLoadedSuccessfully, detailsDelegate?.personDetailsLoadingFailed)
    }
    
    func loadCredits(id: String) {
        get(urlCredits.withArgs(id), apiKey, detailsDelegate?.personCreditsLoadedScuccessfully, detailsDelegate?.personCreditsLoadingFailed)
    }
}

protocol PersonDetailsDelegate {
    
    func personDetailsLoadedSuccessfully(details: PersonInfo) -> Void
    
    func personDetailsLoadingFailed(error: NSError) -> Void
    
    func personCreditsLoadedScuccessfully(credits: PersonCredits) -> Void
    
    func personCreditsLoadingFailed(error: NSError) -> Void
}
