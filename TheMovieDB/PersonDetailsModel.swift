//
//  PersonDetailsModel.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/27/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import ObjectMapper

struct PersonInfo: Mappable {
    var personId: Int?
    var name: String?
    var biography: String?
    var birthday: String?
    var deathday: String?
    var birthplace: String?
    var profilePath: String?
    var homepage: String?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        personId<-map["id"]
        name<-map["name"]
        biography<-map["biography"]
        birthday<-map["birthday"]
        deathday<-map["deathday"]
        birthplace<-map["place_of_birth"]
        profilePath<-map["profile_path"]
        homepage<-map["homepage"]
    }
}

struct PersonCredits: Mappable {
    var id: Int?
    var cast: [Cast]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id<-map["id"]
        cast<-map["cast"]
    }
    
    struct Cast: Mappable {
        var itemId: Int?
        var creditId: String?
        var type: String?
        var title: String?
        var titleOriginal: String?
        var character: String?
        var releaseDate: String?
        var posterPath: String?
        
        init?(_ map: Map) {
        }
        
        mutating func mapping(map: Map) {
            itemId<-map["id"]
            creditId<-map["credit_id"]
            type<-map["media_type"]
            title<-map["title"]
            titleOriginal<-map["original_title"]
            character<-map["character"]
            releaseDate<-map["release_date"]
            posterPath<-map["poster_path"]
        }
    }
}