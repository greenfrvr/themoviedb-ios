//
//  AccountModel.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/27/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import ObjectMapper

class Account: NSObject, NSCoding, Mappable {
    var userId: Int?
    var username: String?
    var fullName: String?
    var langCode: String?
    var countryCode: String?
    var includeAdult: Bool?
    var gravatarHash: String?
    var gravatar: String {
        guard let hash = gravatarHash else { return "" }
        
        return Endpoints.gravatarUrl.withArgs(hash)
    }
    
    required init?(_ map: Map) {
    }
    
    required init?(coder decoder: NSCoder) {
        userId = decoder.decodeObjectForKey("userId") as! Int?
        username = decoder.decodeObjectForKey("username") as! String?
        fullName = decoder.decodeObjectForKey("fullname") as! String?
        langCode = decoder.decodeObjectForKey("lang") as! String?
        countryCode = decoder.decodeObjectForKey("country") as! String?
        includeAdult = decoder.decodeObjectForKey("adult") as! Bool?
        gravatarHash = decoder.decodeObjectForKey("gravatar") as! String?
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(userId, forKey: "userId")
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(fullName, forKey: "fullname")
        aCoder.encodeObject(langCode, forKey: "lang")
        aCoder.encodeObject(countryCode, forKey: "country")
        aCoder.encodeObject(includeAdult, forKey: "adult")
        aCoder.encodeObject(gravatarHash, forKey: "gravatar")
    }
    
    func mapping(map: Map) {
        userId<-map["id"]
        username<-map["username"]
        fullName<-map["name"]
        gravatarHash<-map["avatar.gravatar.hash"]
        langCode<-map["iso_639_1"]
        countryCode<-map["iso_3166_1"]
        includeAdult<-map["include_adult"]
    }
}

struct AccountState: Mappable {
    var movieId: Int?
    var favorite: Bool?
    var watchlist: Bool?
    var ratedValue: Double?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        movieId<-map["id"]
        favorite<-map["favorite"]
        watchlist<-map["watchlist"]
        ratedValue<-map["rated.value"]
    }
}
