//
//  SearchManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class SearchManager: ApiManager, LanguageRequired {
    let searchDelegate: SearchDelegate?
    
    init(delegate: SearchDelegate?){
        searchDelegate = delegate
    }
    
    func query(scope: SearchController.ScopeType, query: String, page: Int = 1){
        switch scope {
        case .MOVIE:
            get(scope.requestUrl, apiKey +> lang +> [ "query": query, "page": page ], searchDelegate?.searchMovieResuts, searchDelegate?.searchNoPersonFound)
        case .TV:
            get(scope.requestUrl, apiKey +> lang +> [ "query": query, "page": page ], searchDelegate?.searchTvShowResuts, searchDelegate?.searchNoPersonFound)
        case .PEOPLE:
            get(scope.requestUrl, apiKey +> lang +> [ "query": query, "page": page ], searchDelegate?.searchPersonResuts, searchDelegate?.searchNoPersonFound)
        case .ALL:
            self.query(.MOVIE, query: query, page: page)
            self.query(.TV, query: query, page: page)
            self.query(.PEOPLE, query: query, page: page)
        return;
        }
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