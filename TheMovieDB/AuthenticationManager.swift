//
//  AuthenticationManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class AuthenticationManager {
    var requestToken: String?
    let delegate: AuthenticationDelegate
    
    init(delegate: AuthenticationDelegate){
        self.delegate = delegate
    }
    
    func loadRequestToken(){
        let params = ["api_key": ApiEndpoints.apiKey]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.newToken, parameters: params,
            success: { operation, response in
                if let token = Mapper<Token>().map(response) {
                    self.delegate.tokenLoadedSuccessfully(token)
                    self.requestToken = token.requestToken
                }
            },
            failure: { operation, error in self.delegate.tokenLoadingFailed(error)
        })
    }
    
    func validateRequestToken(login: String, _ password: String){
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "request_token": requestToken!,
            "username": login,
            "password": password
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.validateToken, parameters: params,
            success: { operation, response in
                if let token = Mapper<Token>().map(response) {
                    self.delegate.tokenValidatedSuccessfully(token)
                    self.requestToken = token.requestToken
                }
            },
            failure: { operation, error in self.delegate.tokenValidationFailed(error)
        })
    }
    
    func createSession(){
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "request_token": requestToken!,
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.createNewSession, parameters: params,
            success: { operation, response in
                if let session = Mapper<Session>().map(response) {
                    self.delegate.sessionCreatedSuccessfully(session)
                }
            },
            failure: { operation, error in self.delegate.sessionCreationFailed(error)
        })
    }
}

protocol AuthenticationDelegate {
    
    func tokenLoadedSuccessfully(response: Token) -> Void
    
    func tokenLoadingFailed(error: NSError) -> Void
    
    func tokenValidatedSuccessfully(response: Token) -> Void
    
    func tokenValidationFailed(error: NSError) -> Void
    
    func sessionCreatedSuccessfully(session: Session) -> Void
    
    func sessionCreationFailed(error: NSError) -> Void
}
