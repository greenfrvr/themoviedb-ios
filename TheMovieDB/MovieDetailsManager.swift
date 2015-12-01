//
//  MovieDetailsManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class MovieDetailsManager: ApiManager, SessionRequired, LanguageRequired {
    var sessionId: String
    let detailsDelegate: MovieDetailsDelegate?
    let stateDelegate: MovieStateChangeDelegate?
    
    init?(sessionId: String, detailsDelegate: MovieDetailsDelegate?, stateDelegate: MovieStateChangeDelegate?){
        self.sessionId = sessionId
        self.detailsDelegate = detailsDelegate
        self.stateDelegate = stateDelegate
        
        super.init()
        
        if sessionId.isEmpty {
            return nil
        }
    }
    
    convenience init?(sessionId: String, detailsDelegate: MovieDetailsDelegate){
        self.init(sessionId: sessionId, detailsDelegate: detailsDelegate, stateDelegate: nil)
    }
    
    convenience init?(sessionId: String, stateDelegate: MovieStateChangeDelegate){
        self.init(sessionId: sessionId, detailsDelegate: nil, stateDelegate: stateDelegate)
    }
    
    func loadDetails(id: String) {
        get(urlDetails.withArgs(id), apiKey +> lang, detailsDelegate?.movieDetailsLoadedSuccessfully, detailsDelegate?.movieDetailsLoadingFailed)
    }
    
    func loadState(id: String) {
        get(urlState.withArgs(id), apiKey +> session, detailsDelegate?.movieStateLoadedSuccessfully, detailsDelegate?.movieStateLoadingFailed)
    }
    
    func loadImages(id: String){
        get(urlImages.withArgs(id), apiKey +> session, detailsDelegate?.movieImagesLoadedSuccessully, detailsDelegate?.movieImagesLoadingFailed)
    }
    
    func loadCredits(id: String) {
        get(urlCredits.withArgs(id), apiKey, detailsDelegate?.movieCreditsLoadedSuccessfully, detailsDelegate?.movieCreditsLoadingFailed)
    }
    
    func loadSimilar(id: String, page: Int = 1) {
        get(urlSimilar.withArgs(id), apiKey +> lang +> ["page" : page], detailsDelegate?.movieSimilarLoadedSuccessfully, detailsDelegate?.movieSimilarLoadingFailed)
    }
    
    func changeFavoriteState(id: String, state: Bool){
        let newState = !state
        let body = FavoriteBody(movieId: Int(id), isFavorite: newState)
        let url = urlItemFavoriteState.withArgs(id, sessionId)
        
        post(url, body, { [unowned self] in self.stateDelegate?.movieFavoriteStateChangedSuccessfully(newState) }, stateDelegate?.movieFavoriteStateChangesFailed)
    }
    
    func changeWatchlistState(id: String, state: Bool){
        let newState = !state
        let body = WatchlistBody(movieId: Int(id), isInWatchlist: newState)
        let url = urlItemWatchlistState.withArgs(id, sessionId)
        
        post(url, body, { [unowned self] in self.stateDelegate?.movieWatchlistStateChangedSuccessfully(newState) }, stateDelegate?.movieWatchlistStateChangesFailed)
    }
}

protocol MovieDetailsDelegate {
    
    func movieDetailsLoadedSuccessfully(details: MovieInfo) -> Void
    
    func movieDetailsLoadingFailed(error: NSError) -> Void
    
    func movieStateLoadedSuccessfully(state: AccountState) -> Void
    
    func movieStateLoadingFailed(error: NSError) -> Void
    
    func movieImagesLoadedSuccessully(images: ImageInfoList) -> Void
    
    func movieImagesLoadingFailed(error: NSError) -> Void
    
    func movieCreditsLoadedSuccessfully(credits: MovieCredits) -> Void
    
    func movieCreditsLoadingFailed(error: NSError) -> Void
    
    func movieSimilarLoadedSuccessfully(similar: SegmentList) -> Void
    
    func movieSimilarLoadingFailed(error: NSError) -> Void
}

protocol MovieStateChangeDelegate {
    
    func movieFavoriteStateChangedSuccessfully(isFavorite: Bool) -> Void
    
    func movieFavoriteStateChangesFailed(error: NSError) -> Void
    
    func movieWatchlistStateChangedSuccessfully(isInWatchlist: Bool) -> Void
    
    func movieWatchlistStateChangesFailed(error: NSError)
}