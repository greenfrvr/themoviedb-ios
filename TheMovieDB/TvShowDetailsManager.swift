//
//  TvShowDetailsManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class TvShowDetailsManager {
    let session: String
    let detailsDelegate: TvShowDetailsDelegate?
    let stateDelegate: TvShowStateChangeDelegate?
    
    init?(sessionId: String, detailsDelegate: TvShowDetailsDelegate?, stateDelegate: TvShowStateChangeDelegate?){
        self.session = sessionId
        self.detailsDelegate = detailsDelegate
        self.stateDelegate = stateDelegate
        
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
        let params = [
            "api_key": ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(String(format: ApiEndpoints.tvDetails, id), parameters: params,
            success: { operation, response in
                if let results = Mapper<TvShowInfo>().map(response) {
                    self.detailsDelegate?.tvshowDetailsLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.tvshowDetailsLoadingFailed(error)
        })
    }
    
    func loadState(id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session
        ]
        
        AFHTTPRequestOperationManager().GET(String(format: ApiEndpoints.tvState, id), parameters: params,
            success: { operation, response in
                if let results = Mapper<AccountState>().map(response) {
                    self.detailsDelegate?.tvshowStateLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.tvshowStateLoadingFailed(error)
        })
    }
    
    func changeFavoriteState(id: String, state: Bool){
        let newState = !state
        let body = Mapper<FavoriteBody>().toJSONString(FavoriteBody(tvShowId: Int(id), isFavorite: newState), prettyPrint: true)!
        
        let request = NSMutableURLRequest(URL: NSURL(string: String(format: ApiEndpoints.accountItemFavoriteState, id, session))!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.HTTPRequestOperationWithRequest(request,
            success: { operation, response in
                self.stateDelegate?.tvshowFavoriteStateChangedSuccessfully(newState)
            },
            failure: { operation, error in
                self.stateDelegate?.tvshowFavoriteStateChangesFailed(error)
        }).start()
    }
    
    func changeWatchlistState(id: String, state: Bool){
        let newState = !state
        let body = Mapper<WatchlistBody>().toJSONString(WatchlistBody(tvShowId: Int(id), isInWatchlist: newState), prettyPrint: true)!
        print(body)
        
        let request = NSMutableURLRequest(URL: NSURL(string: String(format: ApiEndpoints.accountItemWatchlistState, id, session))!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.HTTPRequestOperationWithRequest(request,
            success: { operation, response in
                self.stateDelegate?.tvshowWatchlistStateChangedSuccessfully(newState)
            },
            failure: { operation, error in
                self.stateDelegate?.tvshowWatchlistStateChangesFailed(error)
        }).start()
    }
    
    func loadImages(id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session
        ]
        
        AFHTTPRequestOperationManager().GET(String(format: ApiEndpoints.tvImages, id), parameters: params,
            success: { operation, response in
                if let results = Mapper<ImageInfoList>().map(response) {
                    self.detailsDelegate?.tvshowImagesLoadedSuccessully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.tvshowImagesLoadingFailed(error)
        })
    }
    
    func loadCredits(id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(String(format: ApiEndpoints.tvCredits, id), parameters: params,
            success: { operation, response in
                if let results = Mapper<Credits>().map(response) {
                    self.detailsDelegate?.tvshowCreditsLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.tvshowCreditsLoadingFailed(error) }
        )
    }
}

protocol TvShowDetailsDelegate {
    
    func tvshowDetailsLoadedSuccessfully(details: TvShowInfo) -> Void
    
    func tvshowDetailsLoadingFailed(error: NSError) -> Void
    
    func tvshowStateLoadedSuccessfully(state: AccountState) -> Void
    
    func tvshowStateLoadingFailed(error: NSError) -> Void
    
    func tvshowImagesLoadedSuccessully(images: ImageInfoList) -> Void
    
    func tvshowImagesLoadingFailed(error: NSError) -> Void
    
    func tvshowCreditsLoadedSuccessfully(credits: Credits) -> Void
    
    func tvshowCreditsLoadingFailed(error: NSError) -> Void
}

protocol TvShowStateChangeDelegate {
    
    func tvshowFavoriteStateChangedSuccessfully(isFavorite: Bool) -> Void
    
    func tvshowFavoriteStateChangesFailed(error: NSError) -> Void
    
    func tvshowWatchlistStateChangedSuccessfully(isInWatchlist: Bool) -> Void
    
    func tvshowWatchlistStateChangesFailed(error: NSError)
}