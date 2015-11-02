//
//  MovieApiManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import Foundation
import AFNetworking
import ObjectMapper

class MovieApiManager {
    
    static func loadToken(delegate: RequestTokenLoader){
        AFHTTPRequestOperationManager().GET(Api.newToken, parameters: ["api_key": Api.apiKey],
            success: { operation, response in
                if let token = Mapper<Token>().map(response) {
                    delegate.tokenLoadedSuccessfully(token)
                }
            },
            failure: { operation, error in delegate.tokenLoadingFailed(error)
        })
    }
    
}

protocol RequestTokenLoader {
    
    func tokenLoadedSuccessfully(response: Token) -> Void
    
    func tokenLoadingFailed(error: NSError) -> Void
}

class Api {
    
    static let apiKey = "2aa0c55316f571116e12e8911e17be97"
    static let baseUrl = "http://api.themoviedb.org/3/"
    static let newToken = "\(baseUrl)authentication/token/new"
    static let authorization = "\(baseUrl)authentication/token/validate_with_login"
    
}