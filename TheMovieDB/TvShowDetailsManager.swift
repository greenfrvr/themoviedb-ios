//
//  TvShowDetailsManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class TvShowDetailsManager: ApiManager, SessionRequired, LanguageRequired {
    var sessionId: String
    let detailsDelegate: TvShowDetailsDelegate?
    let stateDelegate: TvShowStateChangeDelegate?
    
    init?(sessionId: String, detailsDelegate: TvShowDetailsDelegate?, stateDelegate: TvShowStateChangeDelegate?){
        self.sessionId = sessionId
        self.detailsDelegate = detailsDelegate
        self.stateDelegate = stateDelegate
        
        super.init()
        
        if sessionId.isEmpty {
            return nil
        }
    }
    
    convenience init?(sessionId: String, detailsDelegate: TvShowDetailsDelegate){
        self.init(sessionId: sessionId, detailsDelegate: detailsDelegate, stateDelegate: nil)
    }
    
    convenience init?(sessionId: String, stateDelegate: TvShowStateChangeDelegate){
        self.init(sessionId: sessionId, detailsDelegate: nil, stateDelegate: stateDelegate)
    }
    
    func loadDetails(id: String) {
        get(urlDetails.withArgs(id), apiKey +> lang, detailsDelegate?.tvshowDetailsLoadedSuccessfully, detailsDelegate?.tvshowDetailsLoadingFailed)
    }
    
    func loadState(id: String) {
        get(urlState.withArgs(id), apiKey +> session, detailsDelegate?.tvshowStateLoadedSuccessfully, detailsDelegate?.tvshowStateLoadingFailed)
    }
    
    func loadImages(id: String) {
        get(urlImages.withArgs(id), apiKey +> session, detailsDelegate?.tvshowImagesLoadedSuccessully, detailsDelegate?.tvshowImagesLoadingFailed)
    }
    
    func loadCredits(id: String) {
        get(urlCredits.withArgs(id), apiKey, detailsDelegate?.tvshowCreditsLoadedSuccessfully, detailsDelegate?.tvshowCreditsLoadingFailed)
    }
    
    func changeFavoriteState(id: String, state: Bool){
        let newState = !state
        let body = FavoriteBody(tvShowId: Int(id), isFavorite: newState)
        let url = urlItemFavoriteState.withArgs(id, sessionId)
        
        post(url, body, { [unowned self] in self.stateDelegate?.tvshowFavoriteStateChangedSuccessfully(newState) }, stateDelegate?.tvshowFavoriteStateChangesFailed)
    }
    
    func changeWatchlistState(id: String, state: Bool){
        let newState = !state
        let body = WatchlistBody(tvShowId: Int(id), isInWatchlist: newState)
        let url = urlItemWatchlistState.withArgs(id, sessionId)
        
        post(url, body, { [unowned self] in self.stateDelegate?.tvshowWatchlistStateChangedSuccessfully(newState) }, stateDelegate?.tvshowWatchlistStateChangesFailed)
    }
}

protocol TvShowDetailsDelegate {
    
    func tvshowDetailsLoadedSuccessfully(details: TvShowInfo) -> Void
    
    func tvshowDetailsLoadingFailed(error: NSError) -> Void
    
    func tvshowStateLoadedSuccessfully(state: AccountState) -> Void
    
    func tvshowStateLoadingFailed(error: NSError) -> Void
    
    func tvshowImagesLoadedSuccessully(images: ImageInfoList) -> Void
    
    func tvshowImagesLoadingFailed(error: NSError) -> Void
    
    func tvshowCreditsLoadedSuccessfully(credits: MovieCredits) -> Void
    
    func tvshowCreditsLoadingFailed(error: NSError) -> Void
}

protocol TvShowStateChangeDelegate {
    
    func tvshowFavoriteStateChangedSuccessfully(isFavorite: Bool) -> Void
    
    func tvshowFavoriteStateChangesFailed(error: NSError) -> Void
    
    func tvshowWatchlistStateChangedSuccessfully(isInWatchlist: Bool) -> Void
    
    func tvshowWatchlistStateChangesFailed(error: NSError)
}