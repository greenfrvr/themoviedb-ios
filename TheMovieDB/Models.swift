//
//  Models.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import ObjectMapper
import Locksmith

protocol PaginationLoading {
    typealias Item
    var page: Int? { get set }
    var totalPages: Int? { get set }
    var totalResults: Int? { get set }
    var results: [Item]? { get set }
    
    var hasMorePages: Bool { get }
    var nextPage: Int? { get }
}

extension PaginationLoading {
    
    var hasMorePages: Bool { return page < totalPages }
    
    var nextPage: Int? { return hasMorePages ? page! + 1 : nil }
}

protocol SegmentsRepresentation {
    var id: String? { get }
    var representImage: String? { get }
    var representTitle: String? { get }
    var representDescription: String? { get }
    var representCounter: String? { get }
    mutating func increaseCounter()
}

extension SegmentsRepresentation {
    mutating func increaseCounter() {}
}

protocol SearchCellRepresentation {
    var representImage: String? { get }
    var representTitle: String? { get }
    var representDate: String? { get }
    var representDescription: String? { get }
}

extension SearchCellRepresentation {
    var representDate: String? { return "" }
    var representDescription: String? { return "" }
}

struct FavoriteBody: Mappable {
    var mediaId: Int?
    var mediaType: String?
    var favorite: Bool?
    
    init(id: Int?, type: String?, favorite: Bool?){
        self.mediaId = id
        self.mediaType = type
        self.favorite = favorite
    }
    
    init(movieId id: Int?, isFavorite: Bool?) {
        self.init(id: id, type: "movie", favorite: isFavorite)
    }

    init(tvShowId id: Int?, isFavorite: Bool?) {
        self.init(id: id, type: "tv", favorite: isFavorite)
    }
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        mediaId<-map["media_id"]
        mediaType<-map["media_type"]
        favorite<-map["favorite"]
    }
}

struct WatchlistBody: Mappable {
    var mediaId: Int?
    var mediaType: String?
    var watchlist: Bool?
    
    init(id: Int?, type: String?, watchlist: Bool?){
        self.mediaId = id
        self.mediaType = type
        self.watchlist = watchlist
    }
    
    init(movieId id: Int?, isInWatchlist: Bool?) {
        self.init(id: id, type: "movie", watchlist: isInWatchlist)
    }
    
    init(tvShowId id: Int?, isInWatchlist: Bool?) {
        self.init(id: id, type: "tv", watchlist: isInWatchlist)
    }
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        mediaId<-map["media_id"]
        mediaType<-map["media_type"]
        watchlist<-map["watchlist"]
    }
}

