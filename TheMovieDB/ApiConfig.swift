//
//  ApiConfig.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import Foundation

class ApiEndpoints {
    
    static let apiKey = "2aa0c55316f571116e12e8911e17be97"
    static let baseApiUrl = "http://api.themoviedb.org/3"
    static let baseShareUrl = "https://www.themoviedb.org"
    
    //auth
    static let newToken = "\(baseApiUrl)/authentication/token/new"
    static let validateToken = "\(baseApiUrl)/authentication/token/validate_with_login"
    static let createNewSession = "\(baseApiUrl)/authentication/session/new"
    
    //account
    static let accountInfo = "\(baseApiUrl)/account"
    static let accountLists = "\(baseApiUrl)/account/%d/lists"
    static let accountFavoriteMovies = "\(baseApiUrl)/account/%d/favorite/movies"
    static let accountRatedMovies = "\(baseApiUrl)/account/%d/rated/movies"
    static let accountWatchlistMovies = "\(baseApiUrl)/account/%d/watchlist/movies"
    static let accountItemFavoriteState = "\(baseApiUrl)/account/%@/favorite?api_key=\(apiKey)&session_id=%@"
    static let accountItemWatchlistState = "\(baseApiUrl)/account/%@/watchlist?api_key=\(apiKey)&session_id=%@"
    
    //list
    static let listStatus = "\(baseApiUrl)/list/%@/item_status"
    static let listAddItem = "\(baseApiUrl)/list/%@/add_item?api_key=\(apiKey)&session_id=%@"
    static let listDeleteItem = "\(baseApiUrl)/list/%@/remove_item?api_key=\(apiKey)&session_id=%@"
    static let listDetails = "\(baseApiUrl)/list/%@"
    static let listShare = "\(baseShareUrl)/list/%@"
    
    //search
    static let searchMovie = "\(baseApiUrl)/search/movie"
    static let searchTvShow = "\(baseApiUrl)/search/tv"
    static let searchPerson = "\(baseApiUrl)/search/person"
    
    //movie details
    static let movieDetails = "\(baseApiUrl)/movie/%@"
    static let movieImages = "\(baseApiUrl)/movie/%@/images"
    static let movieCredits = "\(baseApiUrl)/movie/%@/credits"
    static let movieState = "\(baseApiUrl)/movie/%@/account_states"
    static let movieShare  = "\(baseShareUrl)/movie"

    //tv show details
    static let tvDetails = "\(baseApiUrl)/tv/%@"
    static let tvImages = "\(baseApiUrl)/tv/%@/images"
    static let tvCredits = "\(baseApiUrl)/tv/%@/credits"
    static let tvState = "\(baseApiUrl)/tv/%@/account_states"
    static let tvShare  = "\(baseShareUrl)/tv"
    
    //person details
    static let personDetails = "\(baseApiUrl)/person/%@"
    static let personImages = "\(baseApiUrl)/person/%@/images"
    static let personCredits = "\(baseApiUrl)/person/%@/combined_credits"
    static let personState = "\(baseApiUrl)/movie/%@/account_states"
    static let personShare  = "\(baseShareUrl)/person"
    
    //trends
    static let popularMovies = "\(baseApiUrl)/movie/popular"
    static let topMovies = "\(baseApiUrl)/movie/top_rated"
    static let popularTvShow = "\(baseApiUrl)/tv/popular"
    static let topTvShow = "\(baseApiUrl)/tv/top_rated"

}

extension String {
    
    func withArgs(args: CVarArgType...) -> String {
        return String(format: self, arguments: args)
    }
    
}

class ImagesConfig {
    static let baseImageUrl = "http://image.tmdb.org/t/p"
    
    static let posterSizes = NSDictionary(contentsOfURL: NSBundle.posterSizes())
    static let profileSizes = NSDictionary(contentsOfURL: NSBundle.profileSizes())
    static let backdropSizes = NSDictionary(contentsOfURL: NSBundle.backdropSizes())
    
    //images
    static let poster = { (index: Int, path: String) -> String in
        if let sizes = posterSizes {
            let size = sizes[String(index)] as? String ?? "w154"
            return "\(baseImageUrl)/\(size)\(path)?api_key=\(ApiEndpoints.apiKey)"
        }
        return ""
    }
    
    static let profile = { (index: Int, path: String) -> String in
        if let sizes = profileSizes {
            let size = sizes[String(index)] as? String ?? "w180"
            return "\(baseImageUrl)/\(size)\(path)?api_key=\(ApiEndpoints.apiKey)"
        }
        return ""
    }
    
    static let backdrop = { (index: Int, path: String) -> String in
        if let sizes = backdropSizes {
            let size = sizes[String(index)] as? String ?? "w300"
            return "\(baseImageUrl)/\(size)\(path)?api_key=\(ApiEndpoints.apiKey)"
        }
        return ""
    }

}