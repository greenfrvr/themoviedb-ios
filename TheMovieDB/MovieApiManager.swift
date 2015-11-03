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

class AccountManager {
    var account: Account?
    let session: String
    let accountDelegate: AccountDelegate?
    let listsDelegate: ListsDelegate?
    
    init?(sessionId session: String, accountDelegate delegate: AccountDelegate){
        self.session = session
        self.accountDelegate = delegate
        self.listsDelegate = nil
        
        if session.isEmpty {
            return nil
        }
    }
    
    init?(sessionId session: String, listsDelegate delegate: ListsDelegate){
        self.session = session
        self.listsDelegate = delegate
        self.accountDelegate = nil
        
        if session.isEmpty {
            return nil
        }
    }
    
    func loadAccountData(){
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session,
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.accountInfo, parameters: params,
            success: { operation, response in
                if let account = Mapper<Account>().map(response) {
                    self.account = account
                    self.accountDelegate?.userLoadedSuccessfully(account)
                    self.listsDelegate?.userFetched()
                }
            },
            failure: { operation, error in self.accountDelegate?.userLoadingFailed(error)
        })

    }
    
    func loadLists(){
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session,
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.accountLists((self.account?.userId)!), parameters: params,
            success: { operation, response in
                if let lists = Mapper<ListInfoPages>().map(response) {
                    self.listsDelegate?.userListsLoadedSuccessfully(lists)
                }
            },
            failure: { operation, error in self.listsDelegate?.userListsLoadingFailed(error)
        })

    }
    
}

protocol AccountDelegate {
    
    func userLoadedSuccessfully(account: Account) -> Void
    
    func userLoadingFailed(error: NSError) -> Void
}

protocol ListsDelegate {
    
    func userListsLoadedSuccessfully(pages: ListInfoPages) -> Void
    
    func userListsLoadingFailed(error: NSError) -> Void
    
    func userFetched() -> Void
}

class ApiEndpoints {
    
    static let apiKey = "2aa0c55316f571116e12e8911e17be97"
    static let baseUrl = "http://api.themoviedb.org/3/"
    //auth
    static let newToken = "\(baseUrl)authentication/token/new"
    static let validateToken = "\(baseUrl)authentication/token/validate_with_login"
    static let createNewSession = "\(baseUrl)authentication/session/new"
    //account
    static let accountInfo = "\(baseUrl)account"
    static let accountLists = { (id: Int) in "\(baseUrl)account/\(id)/lists" }
    
}