//
//  MovieApiManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class TrendsManager: ApiManager {
    let delegate: TrendsDelegate?
    
    init(delegate: TrendsDelegate?){
        self.delegate = delegate
        super.init()
    }
    
    func loadPopular(type: TrendsType, page: Int = 1) {
        switch type {
        case .MOVIE:
            get(type.url(), apiKey +> [ "page": page ], { (res: MovieTrendsList) -> Void in }, delegate?.trendsLoadingFailed) {
                [unowned self] in
                if let result = TrendsList(fromMovieList: $0) {
                    self.delegate?.trendsLoadedSuccessfully(result)
                }
            }
        case .TV:
            get(type.url(), apiKey +> [ "page": page ], { (res: TvTrendsList) -> Void in }, delegate?.trendsLoadingFailed) {
                [unowned self] in
                if let result = TrendsList(fromTvList: $0) {
                    self.delegate?.trendsLoadedSuccessfully(result)
                }
            }
        }
    }
}

protocol TrendsDelegate {

    func trendsLoadedSuccessfully(trends: TrendsList) -> Void
    
    func trendsLoadingFailed(error: NSError) -> Void
}