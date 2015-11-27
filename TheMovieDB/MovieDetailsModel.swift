//
//  MovieDetailsModel.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/27/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import ObjectMapper

struct MovieInfo: Mappable {
    var movieId: Int?
    var imdbId: String?
    var title: String?
    var tagline: String?
    var overview: String?
    var genres: [Genre]?
    var runtime: Int?
    var voteAverage: Double?
    var voteCount: Int?
    var releaseDate: String?
    var budget: Int?
    var revenue: Int?
    var posterPath: String?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        movieId<-map["id"]
        imdbId<-map["imdb_id"]
        title<-map["title"]
        tagline<-map["tagline"]
        overview<-map["overview"]
        genres<-map["genres"]
        runtime<-map["runtime"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        releaseDate<-map["release_date"]
        budget<-map["budget"]
        revenue<-map["revenue"]
        posterPath<-map["poster_path"]
    }
    
    struct Genre: Mappable {
        var id: String?
        var name: String?
        
        init?(_ map: Map) {
        }
        
        mutating func mapping(map: Map) {
            id<-map["id"]
            name<-map["name"]
        }
    }
}

struct TvShowInfo: Mappable {
    var tvShowId: Int?
    var name: String?
    var homepage: String?
    var overview: String?
    var numberOfSeasons: Int?
    var numberOfEpisodes: Int?
    var lastAirDate: String?
    var posterPath: String?
    var voteAverage: Double?
    var voteCount: Int?
    var seasons: [Season]?
    var createdBy: [Creator]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        tvShowId<-map["id"]
        name<-map["name"]
        homepage<-map["homepage"]
        overview<-map["overview"]
        numberOfSeasons<-map["number_of_seasons"]
        numberOfEpisodes<-map["number_of_episodes"]
        lastAirDate<-map["last_air_date"]
        posterPath<-map["poster_path"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        seasons<-map["seasons"]
        createdBy<-map["created_by"]
    }
    
    struct Season: Mappable {
        var id: Int?
        var seasonNumber: Int?
        var episodeCount: Int?
        var airDate: String?
        var posterPath: String?
        
        init?(_ map: Map) {
        }
        
        mutating func mapping(map: Map) {
            id<-map["id"]
            seasonNumber<-map["season_number"]
            episodeCount<-map["episode_count"]
            airDate<-map["air_date"]
            posterPath<-map["poster_path"]
        }
    }
    
    struct Creator: Mappable {
        var id: Int?
        var name: String?
        var profilePath: String?
        
        init?(_ map: Map) {
        }
        
        mutating func mapping(map: Map) {
            id<-map["id"]
            name<-map["name"]
            profilePath<-map["profile_path"]
        }
    }
}

struct MovieCredits: Mappable {
    var id: Int?
    var casts: [Cast]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id<-map["id"]
        casts<-map["cast"]
    }
    
    struct Cast: Mappable {
        var id: Int?
        var castId: Int?
        var creditId: String?
        var name: String?
        var character: String?
        var profilePath: String?
        var order: Int?
        
        init?(_ map: Map) {
        }
        
        mutating func mapping(map: Map) {
            id<-map["id"]
            castId<-map["cast_id"]
            creditId<-map["credit_id"]
            name<-map["name"]
            character<-map["character"]
            profilePath<-map["profile_path"]
            order<-map["order"]
        }
    }
}
