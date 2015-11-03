//
//  Models.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import Foundation
import ObjectMapper

class Token: NSObject, NSCoding, Mappable {
    
    var requestToken: String?
    var expireAt: String?
    var success: Bool?
    
    init?(token: String, expire: String?){
        requestToken = token
        expireAt = expire
        
        super.init()
        
        if token.isEmpty {
            return nil
        }
    }
    
    //MARK: Mappable protocol
    required init?(_ map: Map) {
        
    }

    func mapping(map: Map) {
        requestToken<-map["request_token"]
        expireAt<-map["expires_at"]
        success<-map["success"]
    }

    //MARK: NSCoding protocol
    required convenience init?(coder aDecoder: NSCoder) {
        let token = aDecoder.decodeObjectForKey("token") as? String
        let expire = aDecoder.decodeObjectForKey("expire") as? String
        
        self.init(token: token ?? "", expire: expire)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(requestToken, forKey: "token")
        aCoder.encodeObject(expireAt, forKey: "expire")
    }
}

class Session: NSObject, NSCoding, Mappable {
    
    var sessionToken: String?
    var success: Bool?
    
    init?(session: String) {
        sessionToken = session
        
        super.init()
        
        if session.isEmpty {
            return nil
        }
    }
    
    //MARK: Mappable protocol
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        sessionToken<-map["session_id"]
        success<-map["success"]
    }
    
    //MARK: NSCoding protocol
    required convenience init?(coder aDecoder: NSCoder) {
        let session = aDecoder.decodeObjectForKey("session_id") as? String
        
        self.init(session: session ?? "")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(sessionToken, forKey: "session_id")
    }
}

class Account: NSObject, Mappable {
    var userId: Int?
    var username: String?
    var fullName: String?
    var langCode: String?
    var countryCode: String?
    var includeAdult: Bool?
    var gravatarHash: String?
    var gravatar: String {
        return "http://www.gravatar.com/avatar/\(gravatarHash!)"
    }
    
    //MARK: Mappable protocol
    required init?(_ map: Map) {
        
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

class ListInfo: Mappable {
    var listId: String?
    var listName: String?
    var poster: String?
    var listDesc: String?
    var itemsInList: Int?
    var favoriteCount: Int?
    var listType: String?
    var langCode: String?
    var itemsCount: String {
        let count = itemsInList ?? 0
        return "\(count > 0 ? String(count) : "no") item\(count != 1 ? "s" : "")"
    }
    
    //MARK: Mappable protocol
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        listId<-map["id"]
        listName<-map["name"]
        poster<-map["poster_path"]
        listDesc<-map["description"]
        itemsInList<-map["item_count"]
        favoriteCount<-map["favorite_count"]
        listType<-map["list_type"]
        langCode<-map["iso_639_1"]
    }
}

class ListInfoPages: Mappable {
    var page: Int?
    var pagesTotal: Int?
    var resultsTotal: Int?
    var results: [ListInfo]?
    
    //MARK: Mappable protocol
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        page<-map["page"]
        pagesTotal<-map["total_pages"]
        resultsTotal<-map["total_results"]
        results<-map["results"]
    }

}
