//
//  MovieApiManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class TrendsManager {
    
    let delegate: TrendsDelegate?
    
    init(delegate: TrendsDelegate?){
        self.delegate = delegate
    }
    
    func loadPopular(type: TrendsType, page: Int = 1){
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "page": page
        ]
        
        AFHTTPRequestOperationManager().GET(type.url(), parameters: params,
            success: { operation, response in
                switch type {
                case .MOVIE:
                    if let movies = Mapper<MovieTrendsList>().map(response) {
                        if let result = TrendsList(fromMovieList: movies) {
                            self.delegate?.trendsLoadedSuccessfully(result)
                        }
                    }
                case .TV:
                    if let tvshows = Mapper<TvTrendsList>().map(response) {
                        if let result = TrendsList(fromTvList: tvshows) {
                            self.delegate?.trendsLoadedSuccessfully(result)
                        }
                    }
                }  
            },
            failure: { operation, error in self.delegate?.trendsLoadingFailed(error)
        })
    }
}

protocol TrendsDelegate {

    func trendsLoadedSuccessfully(trends: TrendsList) -> Void
    
    func trendsLoadingFailed(error: NSError) -> Void
}