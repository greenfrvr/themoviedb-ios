//
//  MovieApiManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class TrendsManager: ApiManager, LanguageRequired {
    let delegate: TrendsDelegate?
    
    init(delegate: TrendsDelegate?){
        self.delegate = delegate
        super.init()
    }
    
    func loadPopular(type: TrendsType, popular: Bool = true, page: Int = 1) {
        let url = popular ? type.popularUrl : type.topUrl
        
        switch type {
        case .MOVIE:
            get(url, apiKey +> lang +> [ "page": page ], { (res: MovieTrendsList) -> Void in }, delegate?.trendsLoadingFailed) {
                [unowned self] in
                self.delegate?.trendsLoadedSuccessfully(TrendsList(list: $0))
            }
        case .TV:
            get(url, apiKey +> lang +> [ "page": page ], { (res: TvTrendsList) -> Void in }, delegate?.trendsLoadingFailed) {
                [unowned self] in
                self.delegate?.trendsLoadedSuccessfully(TrendsList(list: $0))
            }
        }
    }
}

protocol TrendsDelegate {
    
    func trendsLoadedSuccessfully(trends: TrendsList) -> Void
    
    func trendsLoadingFailed(error: NSError) -> Void
}