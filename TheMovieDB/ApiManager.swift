//
//  Manager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/25/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class ApiManager {
    
    final let apiKey = [ "api_key": ApiEndpoints.apiKey ]
    
    init() {}
    
    func get<T: Mappable>(url: String, _ params: AnyObject?, _ callback: ((T) -> Void)?, _ handler: ((NSError) -> Void)? = nil, _ optional: ((T) -> Void)? = nil) {
        AFHTTPRequestOperationManager().GET(url, parameters: params,
            success: {
                operation, response in
                if let result = Mapper<T>().map(response) {
                    optional?(result)
                    callback?(result)
                }
            },
            failure: { operation, error in handler?(error) })
    }
    
    func delete(url: String, _ params: AnyObject?, _ callback: (() -> Void)?, _ handler: ((NSError) -> Void)? = nil) {
        AFHTTPRequestOperationManager().DELETE(url, parameters: params,
            success: { operation, response in callback?() },
            failure: { operation, error in handler?(error) })
    }
    
    func post<T: Mappable>(url: String, _ body: T, _ callback: (() -> Void)?, _ handler: ((NSError) -> Void)? = nil) {
        guard let body = Mapper<T>().toJSONString(body, prettyPrint: true) else {
            print("Cannot parse request body")
            return
        }
        
        guard let url = NSURL(string: url) else {
            print("Wrong request url")
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.HTTPRequestOperationWithRequest(request,
            success: { operation, response in callback?() },
            failure: { operation, error in handler?(error)
        }).start()
    }
}

protocol SessionRequired {

    var sessionId: String { get set }
    
}

extension SessionRequired {
    
    var session: [String: String] { return [ "session_id": sessionId ] }

}

protocol TokenRequired {
    
    var tokenId: String? { get set }
    
}

extension TokenRequired {

    var token: [String: String] { return [ "request_token": tokenId ?? "" ] }
    
}