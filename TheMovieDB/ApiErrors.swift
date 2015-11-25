//
//  ApiErrors.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/25/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import ObjectMapper
import AFNetworking

struct ApiError: Mappable {
    var statusCode: Int?
    var statusMessage: String?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        statusCode <- map["status_code"]
        statusMessage <- map["status_message"]
    }
    
    func printError() {
        if let code = statusCode, message = statusMessage {
            print("Error with code \(code) appeared. There is a message it contains:\n \(message)")
        }
    }
}
extension NSError {
    var apiError: ApiError? {
        if let data = self.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]! as? NSData {
            let json = String(data: data, encoding: NSUTF8StringEncoding)
            return Mapper<ApiError>().map(json)
        }
        return nil
    }
}