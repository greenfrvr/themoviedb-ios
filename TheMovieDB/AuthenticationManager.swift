//
//  AuthenticationManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import AFNetworking
import ObjectMapper

class AuthenticationManager: ApiManager, TokenRequired {
    var tokenId: String?
    var delegate: AuthenticationDelegate?
    
    func loadRequestToken(){
        get(ApiEndpoints.newToken, apiKey, delegate?.tokenLoadedSuccessfully, delegate?.tokenLoadingFailed) { [unowned self] in self.tokenId = $0.requestToken }
    }
    
    func validateRequestToken(login: String, _ password: String){
        let params = wrapAuth(login, password)
        get(ApiEndpoints.validateToken, apiKey +> token +> params, delegate?.tokenValidatedSuccessfully, delegate?.tokenValidationFailed) { [unowned self] in self.tokenId = $0.requestToken }
    }
    
    func createSession(){
        get(ApiEndpoints.createNewSession, apiKey +> token, delegate?.sessionCreatedSuccessfully, delegate?.sessionCreationFailed) { Cache.saveSession($0) }
    }
    
    private func wrapAuth(login: String, _ password: String) -> [String : String] {
        return [ "username": login, "password": password]
    }
}

protocol AuthenticationDelegate {
    
    func tokenLoadedSuccessfully(response: Token)
    
    func tokenValidatedSuccessfully(response: Token)
    
    func sessionCreatedSuccessfully(session: Session)
    
    func tokenLoadingFailed(error: NSError)
    
    func tokenValidationFailed(error: NSError)
    
    func sessionCreationFailed(error: NSError)
}
