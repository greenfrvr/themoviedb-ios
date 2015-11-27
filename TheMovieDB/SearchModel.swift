//
//  SearchModel.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/27/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import ObjectMapper

struct SearchMovieItem: Mappable, SearchCellRepresentation {
    var movieId: Int?
    var title: String?
    var titleOriginal: String?
    var overview: String?
    var genres: [Int]?
    var backdropPath: String?
    var posterPath: String?
    var releaseDate: String?
    var popularity: Double?
    var voteAverage: Double?
    var voteCount: Int?
    var originalLanguage: String?
    var video: Bool?
    var adult: Bool?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        movieId<-map["id"]
        title<-map["title"]
        titleOriginal<-map["original_title"]
        overview<-map["overview"]
        genres<-map["genre_ids"]
        backdropPath<-map["backdrop_path"]
        posterPath<-map["poster_path"]
        releaseDate<-map["release_date"]
        popularity<-map["popularity"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        originalLanguage<-map["original_language"]
        video<-map["video"]
        adult<-map["adult"]
    }
    
    //MARK: SearchViewRepresentation
    var representImage: String? {
        if let path = posterPath {
            return ImagesConfig.poster(2, path)
        }
        return nil
    }
    var representTitle: String? {
        return title
    }
    var representDate: String? {
        return releaseDate
    }
    var representDescription: String? {
        return overview
    }
}

struct SearchMovieResults: Mappable, PaginationLoading {
    var page: Int?
    var totalPages: Int?
    var totalResults: Int?
    var results: [SearchMovieItem]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        totalPages<-map["total_pages"]
        totalResults<-map["total_results"]
        results<-map["results"]
    }
}

struct SearchTVItem: Mappable, SearchCellRepresentation {
    var showId: Int?
    var name: String?
    var nameOriginal: String?
    var overview: String?
    var genres: [Int]?
    var backdropPath: String?
    var posterPath: String?
    var firstAirDate: String?
    var popularity: Double?
    var voteAverage: Double?
    var voteCount: Int?
    var originalLanguage: String?
    var originCountry: [String]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        showId<-map["id"]
        name<-map["name"]
        nameOriginal<-map["original_name"]
        overview<-map["overview"]
        genres<-map["genre_ids"]
        backdropPath<-map["backdrop_path"]
        posterPath<-map["poster_path"]
        firstAirDate<-map["first_air_date"]
        popularity<-map["popularity"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        originalLanguage<-map["original_language"]
        originCountry<-map["origin_country"]
    }
    
    //MARK: SearchViewRepresentation
    var representImage: String? {
        if let path = posterPath {
            return ImagesConfig.poster(2, path)
        }
        return nil
    }
    var representTitle: String? {
        return name
    }
    var representDate: String? {
        return firstAirDate
    }
    var representDescription: String? {
        return overview
    }
}

struct SearchTVResults: Mappable, PaginationLoading {
    var page: Int?
    var totalPages: Int?
    var totalResults: Int?
    var results: [SearchTVItem]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        totalPages<-map["total_pages"]
        totalResults<-map["total_results"]
        results<-map["results"]
    }
}

struct SearchPersonItem: Mappable, SearchCellRepresentation {
    var personId: Int?
    var name: String?
    var profilePath: String?
    var popularity: Double?
    var adult: Bool?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        personId<-map["id"]
        name<-map["name"]
        popularity<-map["popularity"]
        profilePath<-map["profile_path"]
        adult<-map["adult"]
    }
    
    //MARK: SearchViewRepresentation
    var representImage: String? {
        if let path = profilePath {
            return ImagesConfig.profile(2, path)
        }
        return nil
    }
    var representTitle: String? {
        return name
    }
}

struct SearchPersonResults: Mappable, PaginationLoading {
    var page: Int?
    var totalPages: Int?
    var totalResults: Int?
    var results: [SearchPersonItem]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        totalPages<-map["total_pages"]
        totalResults<-map["total_results"]
        results<-map["results"]
    }
}