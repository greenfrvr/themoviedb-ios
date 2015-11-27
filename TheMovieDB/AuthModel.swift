//
//  AuthModel.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/27/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import ObjectMapper
import Locksmith

class Token: Mappable {
    var requestToken: String?
    var expireAt: String?
    var success: Bool?
    
    init?(token: String, expire: String?){
        requestToken = token
        expireAt = expire
        
        if token.isEmpty {
            return nil
        }
    }
    
    required init?(_ map: Map) {
    }
    
    func mapping(map: Map) {
        requestToken<-map["request_token"]
        expireAt<-map["expires_at"]
        success<-map["success"]
    }
}

class Session: Mappable, CreateableSecureStorable, GenericPasswordSecureStorable  {
    var sessionToken: String?
    var success: Bool?
    
    init?(session: String) {
        sessionToken = session
        if session.isEmpty {
            return nil
        }
    }
    
    required init?(_ map: Map) {}
    
    func mapping(map: Map) {
        sessionToken<-map["session_id"]
        success<-map["success"]
    }
    
    //MARK: Locksmith
    let service = Cache.serviceName
    var account: String { return Cache.userAccount }
    var data: [String: AnyObject] {
        if let token = sessionToken {
            return ["sessionId": token]
        }
        return [:]
    }
}