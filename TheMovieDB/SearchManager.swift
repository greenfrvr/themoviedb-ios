//
//  SearchManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class SearchManager {
    
    let searchDelegate: SearchDelegate?
    
    init(delegate: SearchDelegate?){
        searchDelegate = delegate
    }
    
    func query(scope: SearchController.ScopeType, query: String, page: Int = 1){
        if scope == .ALL {
            self.query(.MOVIE, query: query, page: page)
            self.query(.TV, query: query, page: page)
            self.query(.PEOPLE, query: query, page: page)
            return
        }
        
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "query": query,
            "page": page
        ]
        
        AFHTTPRequestOperationManager().GET(scope.scopeRequestUrl(), parameters: params,
            success: { operation, response in
                switch scope {
                case .MOVIE:
                    if let results = Mapper<SearchMovieResults>().map(response) {
                        self.searchDelegate?.searchMovieResuts(results)
                    }
                case .TV:
                    if let results = Mapper<SearchTVResults>().map(response) {
                        self.searchDelegate?.searchTvShowResuts(results)
                    }
                case .PEOPLE:
                    if let results = Mapper<SearchPersonResults>().map(response) {
                        self.searchDelegate?.searchPersonResuts(results)
                    }
                case .ALL: break;
                }
                
            },
            failure: { operation, error in self.searchDelegate?.searchNoPersonFound(error)
        })
    }
}

protocol SearchDelegate {
    
    func searchMovieResuts(results: SearchMovieResults) -> Void
    
    func searchNoMoviesFound(error: NSError) -> Void
    
    func searchTvShowResuts(results: SearchTVResults) -> Void
    
    func searchNoTvShowFound(error: NSError) -> Void
    
    func searchPersonResuts(results: SearchPersonResults) -> Void
    
    func searchNoPersonFound(error: NSError) -> Void
}