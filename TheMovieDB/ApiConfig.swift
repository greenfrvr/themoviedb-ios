//
//  ApiConfig.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import Foundation

class Endpoints {
    static let apiKey = "2aa0c55316f571116e12e8911e17be97"
    static let baseApiUrl = "http://api.themoviedb.org/3"
    static let baseShareUrl = "https://www.themoviedb.org"
    static let baseImageUrl = "http://image.tmdb.org/t/p"
    static let gravatarUrl = "http://www.gravatar.com/avatar/%@?s=150"
}

extension AuthenticationManager {
    var urlGetToken: String { return "\(urlApi)/authentication/token/new" }
    var urlValidateToken: String { return "\(urlApi)/authentication/token/validate_with_login" }
    var urlCreateSession: String { return "\(urlApi)/authentication/session/new" }
}

extension AccountManager {
    static var urlCompilations: String { return "\(Endpoints.baseApiUrl)/account/%d/lists" }
    static var urlFavoriteMovies: String { return "\(Endpoints.baseApiUrl)/account/%d/favorite/\(urlTypePath)" }
    static var urlRatedMovies: String { return "\(Endpoints.baseApiUrl)/account/%d/rated/\(urlTypePath)" }
    static var urlWatchlistMovies: String { return "\(Endpoints.baseApiUrl)/account/%d/watchlist/\(urlTypePath)" }
    
    var urlAccount: String { return "\(urlApi)/account" }
    var urlAddItem: String { return "\(urlApi)/list/%@/add_item?api_key=\(key)&session_id=%@" }
    var urlDeleteItem: String { return "\(urlApi)/list/%@/remove_item?api_key=\(key)&session_id=%@" }
}

extension ListDetailsManager {
    static var urlShare: String { return "\(Endpoints.baseShareUrl)/list/%@" }
    
    var urlDetails: String { return "\(urlApi)/list/%@" }
}

extension SearchManager {
    static var urlSearchMovie: String { return "\(Endpoints.baseApiUrl)/search/movie" }
    static var urlSearchTv: String { return "\(Endpoints.baseApiUrl)/search/tv" }
    static var urlSearchPeople: String { return "\(Endpoints.baseApiUrl)/search/person" }
}

extension MovieDetailsManager: ItemStateChange {
    static var urlShare: String { return "\(Endpoints.baseShareUrl)/movie" }

    var urlDetails: String { return "\(urlApi)/movie/%@" }
    var urlImages: String { return "\(urlApi)/movie/%@/images" }
    var urlCredits: String { return "\(urlApi)/movie/%@/credits" }
    var urlState: String { return "\(urlApi)/movie/%@/account_states" }
}

extension TvShowDetailsManager: ItemStateChange {
    static  var urlShare: String { return "\(Endpoints.baseShareUrl)/tv" }
    
    var urlDetails: String { return "\(urlApi)/tv/%@" }
    var urlImages: String { return "\(urlApi)/tv/%@/images" }
    var urlCredits: String { return "\(urlApi)/tv/%@/credits" }
    var urlState: String { return "\(urlApi)/tv/%@/account_states" }
}

extension PersonDetailsManager: ItemStateChange {
    static var urlShare: String { return "\(Endpoints.baseShareUrl)/person" }
    
    var urlDetails: String { return "\(urlApi)/person/%@" }
    var urlImages: String { return "\(urlApi)/person/%@/images" }
    var urlCredits: String { return "\(urlApi)/person/%@/combined_credits" }
}

protocol ItemStateChange {
    var urlItemFavoriteState: String { get }
    var urlItemWatchlistState: String { get }
}

extension ItemStateChange {
    var urlItemFavoriteState: String { return "\(Endpoints.baseApiUrl)/account/%@/favorite?api_key=\(Endpoints.apiKey)&session_id=%@" }
    var urlItemWatchlistState: String { return "\(Endpoints.baseApiUrl)/account/%@/watchlist?api_key=\(Endpoints.apiKey)&session_id=%@" }
}

extension TrendsManager {
    static var urlPopMovies: String { return "\(Endpoints.baseApiUrl)/movie/popular" }
    static var urlPopTv: String { return "\(Endpoints.baseApiUrl)/tv/popular" }
    static var urlTopMovies: String { return "\(Endpoints.baseApiUrl)/movie/top_rated" }
    static var urlTopTv: String { return "\(Endpoints.baseApiUrl)/tv/top_rated" }
}

class ImagesConfig {
    static let posterSizes = NSDictionary(contentsOfURL: NSBundle.posterSizes())
    static let profileSizes = NSDictionary(contentsOfURL: NSBundle.profileSizes())
    static let backdropSizes = NSDictionary(contentsOfURL: NSBundle.backdropSizes())
    
    static let poster = { (index: Int, path: String) -> String in
        if let sizes = posterSizes {
            let size = sizes[String(index)] as? String ?? "w154"
            return "\(Endpoints.baseImageUrl)/\(size)\(path)?api_key=\(Endpoints.apiKey)"
        }
        return ""
    }
    
    static let profile = { (index: Int, path: String) -> String in
        if let sizes = profileSizes {
            let size = sizes[String(index)] as? String ?? "w180"
            return "\(Endpoints.baseImageUrl)/\(size)\(path)?api_key=\(Endpoints.apiKey)"
        }
        return ""
    }
    
    static let backdrop = { (index: Int, path: String) -> String in
        if let sizes = backdropSizes {
            let size = sizes[String(index)] as? String ?? "w300"
            return "\(Endpoints.baseImageUrl)/\(size)\(path)?api_key=\(Endpoints.apiKey)"
        }
        return ""
    }
}