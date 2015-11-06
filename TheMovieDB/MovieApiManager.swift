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

//______________Authenication______________
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

//______________Account info______________
class AccountManager {
    var account: Account?
    let session: String
    let accountDelegate: AccountDelegate?
    let listsDelegate: ListsDelegate?
    
    init?(session: String, accountDelegate: AccountDelegate?, listsDelegate: ListsDelegate?){
        self.session = session
        self.accountDelegate = accountDelegate
        self.listsDelegate = listsDelegate
        
        if session.isEmpty {
            return nil
        }
    }
    
    convenience init?(sessionId id: String, accountDelegate delegate: AccountDelegate){
        self.init(session: id, accountDelegate: delegate, listsDelegate: nil)
    }
    
    convenience init?(sessionId id: String, listsDelegate delegate: ListsDelegate){
        self.init(session: id, accountDelegate: nil, listsDelegate: delegate)
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

//______________List details info______________
class ListDetailsManager {
    let session: String
    let detailsDelegate: ListDetailsDelegate?
    
    init?(sessionId: String, detailsDelegate delegate: ListDetailsDelegate){
        self.session = sessionId
        self.detailsDelegate = delegate
        
        if sessionId.isEmpty {
            return nil
        }
    }
    
    func listDetails(listId id: String){
        let params = [
            "api_key": ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.listDetails(id), parameters: params,
            success: { operation, response in
                if let details = Mapper<ListDetails>().map(response) {
                    self.detailsDelegate?.listDetailsLoadedSuccessfully(details)
                }
            },
            failure: { operation, error in self.detailsDelegate?.listDetailsLoadingFailed(error)
        })
    }
    
    func listDelete(listId id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session
        ]
        
        self.detailsDelegate?.listRemovedSuccessfully()
        AFHTTPRequestOperationManager().DELETE(ApiEndpoints.listDetails(id), parameters: params,
            success: { operation, response in
                self.detailsDelegate?.listRemovedSuccessfully()
            },
            failure: { operation, error in self.detailsDelegate?.listRemovingFailed(error)
        })
    }
}

protocol ListDetailsDelegate {
    
    func listDetailsLoadedSuccessfully(details: ListDetails) -> Void
    
    func listDetailsLoadingFailed(error: NSError) -> Void
    
    func listRemovedSuccessfully() -> Void
    
    func listRemovingFailed(error: NSError) -> Void
}

//______________Search______________
class SearchManager {
    
    let searchDelegate: SearchDelegate?
    
    init(delegate: SearchDelegate?){
        searchDelegate = delegate
    }
    
    func queryMovies(query: String, page: Int = 1){
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "query": query,
            "page": page
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.searchMovie, parameters: params,
            success: { operation, response in
                if let results = Mapper<SearchMovieResults>().map(response) {
                    self.searchDelegate?.searchMovieResuts(results)
                }
            },
            failure: { operation, error in self.searchDelegate?.searchNoMoviesFound(error)
        })
    }
    
    func queryTvShow(query: String, page: Int = 1){
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "query": query,
            "page": page
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.searchTvShow, parameters: params,
            success: { operation, response in
                if let results = Mapper<SearchTVResults>().map(response) {
                    self.searchDelegate?.searchTvShowResuts(results)
                }
            },
            failure: { operation, error in self.searchDelegate?.searchNoTvShowFound(error)
        })
    }
    
    func queryPerson(query: String, page: Int = 1){
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "query": query
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.searchPerson, parameters: params,
            success: { operation, response in
                if let results = Mapper<SearchPersonResults>().map(response) {
                    self.searchDelegate?.searchPersonResuts(results)
                }
            },
            failure: { operation, error in self.searchDelegate?.searchNoPersonFound(error)
        })
    }
    
}

protocol SearchDelegate {
    
    func searchMovieResuts(results: SearchMovieResults) -> Void
    
    func searchNoMoviesFound(error: NSError) -> Void
    
    func searchTvShowResuts(results: SearchTVResults) -> Void
    
    func searchNoTvShowFound(error: NSError) -> Void
    
    func searchPersonResuts(results: SearchPersonResults) -> Void
    
    func searchNoPersonFound(error: NSError) -> Void
}

class MovieDetailsManager {
    
    let delegate: MovieDetailsDelegate?
    
    init(delegate: MovieDetailsDelegate){
        self.delegate = delegate
    }
    
    func loadDetails(id: String){
        let params = [
            "api_key": ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.movieDetails(id), parameters: params,
            success: { operation, response in
                if let results = Mapper<MovieInfo>().map(response) {
                    self.delegate?.detailsLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.delegate?.detailsLoadingFailed(error)
        })

    }
    
}

protocol MovieDetailsDelegate {
    
    func detailsLoadedSuccessfully(details: MovieInfo) -> Void
    
    func detailsLoadingFailed(error: NSError) -> Void
    
}

//______________API configuration______________
class ApiEndpoints {
    
    static let apiKey = "2aa0c55316f571116e12e8911e17be97"
    static let baseApiUrl = "http://api.themoviedb.org/3"
    static let baseShareUrl = "https://www.themoviedb.org"
    static let baseImageUrl = "http://image.tmdb.org/t/p"
    
    //auth
    static let newToken = "\(baseApiUrl)/authentication/token/new"
    static let validateToken = "\(baseApiUrl)/authentication/token/validate_with_login"
    static let createNewSession = "\(baseApiUrl)/authentication/session/new"
    //account
    static let accountInfo = "\(baseApiUrl)/account"
    static let accountLists = { (id: Int) in "\(baseApiUrl)/account/\(id)/lists" }
    //list
    static let listDetails = { (id: String) in "\(baseApiUrl)/list/\(id)" }
    static let listShare = { (id: String) in "\(baseShareUrl)/list/\(id)"}
    //search
    static let searchMovie = "\(baseApiUrl)/search/movie"
    static let searchTvShow = "\(baseApiUrl)/search/tv"
    static let searchPerson = "\(baseApiUrl)/search/person"
    //details 
    static let movieDetails = { (id: String) in "\(baseApiUrl)/movie/\(id)" }
    
    //config
    static let posterSizes = [
        1 : "w92",
        2 : "w154",
        3 : "w185",
        4 : "w342",
        5 : "w500",
        6 : "w780",
        0 : "original"]
    static let profileSizes = [
        1 : "w45",
        2 : "w185",
        3 : "h632",
        0 : "original"
    ]
    //images
    static let poster = { (size: Int, path: String) in "\(baseImageUrl)/\(posterSizes[size]!)/\(path)?api_key=\(apiKey)"}
    
}