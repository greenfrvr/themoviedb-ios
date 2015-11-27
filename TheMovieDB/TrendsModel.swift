//
//  TrendsModel.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/27/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import ObjectMapper

struct MovieTrendsItem: Mappable, TrendsRepresentation {
    var itemId: Int?
    var movieTitle: String?
    var titleOriginal: String?
    var releaseDate: String?
    var posterPath: String?
    var backdropPath: String?
    var voteAverage: Double?
    var voteCount: Int?
    var rating: Int?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        itemId<-map["id"]
        movieTitle<-map["title"]
        titleOriginal<-map["original_title"]
        releaseDate<-map["release_date"]
        posterPath<-map["poster_path"]
        backdropPath<-map["backdrop_path"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        rating<-map["rating"]
    }
    
    var id: Int? { return itemId }
    var title: String? { return movieTitle }
    var poster: String? { return posterPath }
    var backdrop: String? { return backdropPath }
    var desc: String? { return releaseDate?.stringByReplacingOccurrencesOfString("-", withString: "/") }
    var rate: String? { return "\(voteAverage!) (\(voteCount!))" }
}

struct TvTrendsItem: Mappable, TrendsRepresentation {
    var itemId: Int?
    var name: String?
    var nameOriginal: String?
    var overview: String?
    var firstAirDate: String?
    var posterPath: String?
    var backdropPath: String?
    var voteAverage: Double?
    var voteCount: Int?
    var rating: Int?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        itemId<-map["id"]
        name<-map["name"]
        nameOriginal<-map["original_name"]
        overview<-map["overview"]
        firstAirDate<-map["first_air_date"]
        posterPath<-map["poster_path"]
        backdropPath<-map["backdrop_path"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        rating<-map["rating"]
    }
    
    var id: Int? { return itemId }
    var title: String? { return name }
    var poster: String? { return posterPath }
    var backdrop: String? { return backdropPath }
    var desc: String? { return overview }
    var rate: String? { return "\(voteAverage!) (\(voteCount!))" }
}

struct MovieTrendsList: Mappable, PaginationLoading {
    var page: Int?
    var totalPages: Int?
    var totalResults: Int?
    var results: [MovieTrendsItem]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        totalPages<-map["total_pages"]
        totalResults<-map["total_results"]
        results<-map["results"]
    }
}

struct TvTrendsList: Mappable, PaginationLoading {
    var page: Int?
    var totalPages: Int?
    var totalResults: Int?
    var results: [TvTrendsItem]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        totalPages<-map["total_pages"]
        totalResults<-map["total_results"]
        results<-map["results"]
    }
}

struct TrendsList: PaginationLoading {
    var page: Int?
    var totalPages: Int?
    var totalResults: Int?
    var results: [TrendsRepresentation]?
    
    init<T: PaginationLoading>(list: T) {
        self.results = [TrendsRepresentation]()
        self.page = list.page
        self.totalPages = list.totalPages
        self.totalResults = list.totalResults
        if let data = list.results {
            for item in data {
                self.results?.append(item as! TrendsRepresentation)
            }
        }
    }
}