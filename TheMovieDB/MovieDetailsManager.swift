//
//  MovieDetailsManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class MovieDetailsManager {
    let session: String
    let detailsDelegate: MovieDetailsDelegate?
    let stateDelegate: MovieStateChangeDelegate?
    
    init?(sessionId: String, detailsDelegate: MovieDetailsDelegate?, stateDelegate: MovieStateChangeDelegate?){
        self.session = sessionId
        self.detailsDelegate = detailsDelegate
        self.stateDelegate = stateDelegate
        
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
        let params = [
            "api_key": ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(String(format: ApiEndpoints.movieDetails, id), parameters: params,
            success: { operation, response in
                if let results = Mapper<MovieInfo>().map(response) {
                    self.detailsDelegate?.movieDetailsLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.movieDetailsLoadingFailed(error)
        })
    }
    
    func loadState(id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session
        ]
        
        AFHTTPRequestOperationManager().GET(String(format: ApiEndpoints.movieState, id), parameters: params,
            success: { operation, response in
                if let results = Mapper<AccountState>().map(response) {
                    self.detailsDelegate?.movieStateLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.movieStateLoadingFailed(error)
        })
    }
    
    func changeFavoriteState(id: String, state: Bool){
        let newState = !state
        let body = Mapper<FavoriteBody>().toJSONString(FavoriteBody(movieId: Int(id), isFavorite: newState), prettyPrint: true)!
        
        let request = NSMutableURLRequest(URL: NSURL(string: String(format: ApiEndpoints.accountItemFavoriteState, id, session))!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.HTTPRequestOperationWithRequest(request,
            success: { operation, response in
                self.stateDelegate?.movieFavoriteStateChangedSuccessfully(newState)
            },
            failure: { operation, error in
                self.stateDelegate?.movieFavoriteStateChangesFailed(error)
        }).start()
    }
    
    func changeWatchlistState(id: String, state: Bool){
        let newState = !state
        let body = Mapper<WatchlistBody>().toJSONString(WatchlistBody(movieId: Int(id), isInWatchlist: newState), prettyPrint: true)!
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
                self.stateDelegate?.movieWatchlistStateChangedSuccessfully(newState)
            },
            failure: { operation, error in
                self.stateDelegate?.movieWatchlistStateChangesFailed(error)
        }).start()
    }
    
    func loadImages(id: String){
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session
        ]
        
        AFHTTPRequestOperationManager().GET(String(format: ApiEndpoints.movieImages, id), parameters: params,
            success: { operation, response in
                if let results = Mapper<ImageInfoList>().map(response) {
                    self.detailsDelegate?.movieImagesLoadedSuccessully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.movieImagesLoadingFailed(error)
        })
    }
    
    func loadCredits(id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(String(format: ApiEndpoints.movieCredits, id), parameters: params,
            success: { operation, response in
                if let results = Mapper<Credits>().map(response) {
                    self.detailsDelegate?.movieCreditsLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.movieCreditsLoadingFailed(error)
        })
    }
}

protocol MovieDetailsDelegate {
    
    func movieDetailsLoadedSuccessfully(details: MovieInfo) -> Void
    
    func movieDetailsLoadingFailed(error: NSError) -> Void
    
    func movieStateLoadedSuccessfully(state: AccountState) -> Void
    
    func movieStateLoadingFailed(error: NSError) -> Void
    
    func movieImagesLoadedSuccessully(images: ImageInfoList) -> Void
    
    func movieImagesLoadingFailed(error: NSError) -> Void
    
    func movieCreditsLoadedSuccessfully(credits: Credits) -> Void
    
    func movieCreditsLoadingFailed(error: NSError) -> Void
}

protocol MovieStateChangeDelegate {
    
    func movieFavoriteStateChangedSuccessfully(isFavorite: Bool) -> Void
    
    func movieFavoriteStateChangesFailed(error: NSError) -> Void
    
    func movieWatchlistStateChangedSuccessfully(isInWatchlist: Bool) -> Void
    
    func movieWatchlistStateChangesFailed(error: NSError)
}