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

    func loadSegment(type: AccountSegmentType, page: Int = 1){
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session,
            "page": page
        ]
        
        func segment(requestUrl: String) {
            AFHTTPRequestOperationManager().GET(requestUrl, parameters: params,
                success: { operation, response in
                    if let results = Mapper<SegmentList>().map(response) {
                        self.listsDelegate?.userSegmentLoadedSuccessfully(results)
                    }
                },
                failure: { operation, error in self.listsDelegate?.userSegmentLoadingFailed(error)
            })
        }
        
        func list() {
            AFHTTPRequestOperationManager().GET(ApiEndpoints.accountLists((account?.userId)!), parameters: params,
                success: { operation, response in
                    if let lists = Mapper<ListInfoPages>().map(response) {
                        self.listsDelegate?.userListsLoadedSuccessfully(lists)
                    }
                },
                failure: { operation, error in self.listsDelegate?.userListsLoadingFailed(error)
            })
        }
        
        let url: String?
        switch type {
        case .Favorite: url = ApiEndpoints.accountFavoriteMovies((account?.userId)!)
        case .Rated: url = ApiEndpoints.accountRatedMovies((account?.userId)!)
        case .Watchlist: url = ApiEndpoints.accountWatchlistMovies((account?.userId)!)
        case .List: url = nil
        }
    
        if let requestUrl = url {
            segment(requestUrl)
        } else {
            list()
        }
    }
    
    func addToList(listId id: String, itemId: Int) {
        updateList(ApiEndpoints.listAddItem(id, session), id: id, itemId: itemId)
    }
    
    func removeToList(listId id: String, itemId: Int) {
        updateList(ApiEndpoints.listDeleteItem(id, session), id: id, itemId: itemId)
    }
    
    private func updateList(url: String, id: String, itemId: Int){
        let body = Mapper<ListDetails.UpdateListBody>().toJSONString(ListDetails.UpdateListBody(mediaId: itemId), prettyPrint: true)!
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.HTTPRequestOperationWithRequest(request,
            success: { operation, response in
                self.listsDelegate?.listItemUpdatedSuccessfully()
            },
            failure: { operation, error in
                self.listsDelegate?.listItemUpdatingFailed(error)
        }).start()
    }
}

protocol AccountDelegate {
    
    func userLoadedSuccessfully(account: Account) -> Void
    
    func userLoadingFailed(error: NSError) -> Void
}

protocol ListsDelegate {
    
    func userListsLoadedSuccessfully(pages: ListInfoPages) -> Void
    
    func userListsLoadingFailed(error: NSError) -> Void
    
    func userSegmentLoadedSuccessfully(results: SegmentList) -> Void
    
    func userSegmentLoadingFailed(error: NSError) -> Void
    
    func userFetched() -> Void
    
    func listItemUpdatedSuccessfully() -> Void
    
    func listItemUpdatingFailed(error: NSError) -> Void

}

extension ListsDelegate {
    
    func listItemUpdatedSuccessfully() {}
    
    func listItemUpdatingFailed(error: NSError) {}
    
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
    
    func query(scope: SearchController.ScopeType, query: String, page: Int = 1){
        if scope == .ALL {
            self.query(.MOVIE, query: query, page: page)
            self.query(.TV, query: query, page: page)
            self.query(.PEOPLE, query: query, page: page)
            return
        }
        
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "query": query,
            "page": page
        ]
        
        AFHTTPRequestOperationManager().GET(scope.scopeRequestUrl(), parameters: params,
            success: { operation, response in
                switch scope {
                case .MOVIE:
                    if let results = Mapper<SearchMovieResults>().map(response) {
                        self.searchDelegate?.searchMovieResuts(results)
                    }
                case .TV:
                    if let results = Mapper<SearchTVResults>().map(response) {
                        self.searchDelegate?.searchTvShowResuts(results)
                    }
                case .PEOPLE:
                    if let results = Mapper<SearchPersonResults>().map(response) {
                        self.searchDelegate?.searchPersonResuts(results)
                    }
                case .ALL: break;
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
    let session: String
    let detailsDelegate: MovieDetailsDelegate?
    let stateDelegate: MovieStateChangeDelegate?
    
    init?(sessionId: String, detailsDelegate: MovieDetailsDelegate?, stateDelegate: MovieStateChangeDelegate?){
        self.session = sessionId
        self.detailsDelegate = detailsDelegate
        self.stateDelegate = stateDelegate
        
        if sessionId.isEmpty {
            return nil
        }
    }
    
    convenience init?(sessionId: String, detailsDelegate: MovieDetailsDelegate){
        self.init(sessionId: sessionId, detailsDelegate: detailsDelegate, stateDelegate: nil)
    }
    
    convenience init?(sessionId: String, stateDelegate: MovieStateChangeDelegate){
        self.init(sessionId: sessionId, detailsDelegate: nil, stateDelegate: stateDelegate)
    }
    
    func loadDetails(id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.movieDetails(id), parameters: params,
            success: { operation, response in
                if let results = Mapper<MovieInfo>().map(response) {
                    self.detailsDelegate?.movieDetailsLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.movieDetailsLoadingFailed(error)
        })
    }
    
    func loadState(id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.movieState(id), parameters: params,
            success: { operation, response in
                if let results = Mapper<AccountState>().map(response) {
                    self.detailsDelegate?.movieStateLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.movieStateLoadingFailed(error)
        })
    }
    
    func changeFavoriteState(id: String, state: Bool){
        let newState = !state
        let body = Mapper<FavoriteBody>().toJSONString(FavoriteBody(movieId: Int(id), isFavorite: newState), prettyPrint: true)!
        
        let request = NSMutableURLRequest(URL: NSURL(string: ApiEndpoints.accountItemFavoriteState(id, session))!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.HTTPRequestOperationWithRequest(request,
            success: { operation, response in
                self.stateDelegate?.movieFavoriteStateChangedSuccessfully(newState)
            },
            failure: { operation, error in
                self.stateDelegate?.movieFavoriteStateChangesFailed(error)
        }).start()
    }
    
    func changeWatchlistState(id: String, state: Bool){
        let newState = !state
        let body = Mapper<WatchlistBody>().toJSONString(WatchlistBody(movieId: Int(id), isInWatchlist: newState), prettyPrint: true)!
        print(body)
        
        let request = NSMutableURLRequest(URL: NSURL(string: ApiEndpoints.accountItemWatchlistState(id, session))!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.HTTPRequestOperationWithRequest(request,
            success: { operation, response in
                self.stateDelegate?.movieWatchlistStateChangedSuccessfully(newState)
            },
            failure: { operation, error in
                self.stateDelegate?.movieWatchlistStateChangesFailed(error)
        }).start()
    }
    
    func loadImages(id: String){
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.movieImages(id), parameters: params,
            success: { operation, response in
                if let results = Mapper<ImageInfoList>().map(response) {
                    self.detailsDelegate?.movieImagesLoadedSuccessully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.movieImagesLoadingFailed(error)
        })
    }
    
    func loadCredits(id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.movieCredits(id), parameters: params,
            success: { operation, response in
                if let results = Mapper<Credits>().map(response) {
                    self.detailsDelegate?.movieCreditsLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.movieCreditsLoadingFailed(error)
        })
    }
}

protocol MovieDetailsDelegate {
    
    func movieDetailsLoadedSuccessfully(details: MovieInfo) -> Void
    
    func movieDetailsLoadingFailed(error: NSError) -> Void
    
    func movieStateLoadedSuccessfully(state: AccountState) -> Void
    
    func movieStateLoadingFailed(error: NSError) -> Void
    
    func movieImagesLoadedSuccessully(images: ImageInfoList) -> Void
    
    func movieImagesLoadingFailed(error: NSError) -> Void
    
    func movieCreditsLoadedSuccessfully(credits: Credits) -> Void
    
    func movieCreditsLoadingFailed(error: NSError) -> Void
}

protocol MovieStateChangeDelegate {
    
    func movieFavoriteStateChangedSuccessfully(isFavorite: Bool) -> Void
    
    func movieFavoriteStateChangesFailed(error: NSError) -> Void
    
    func movieWatchlistStateChangedSuccessfully(isInWatchlist: Bool) -> Void
    
    func movieWatchlistStateChangesFailed(error: NSError)
}

class TvShowDetailsManager {
    let session: String
    let detailsDelegate: TvShowDetailsDelegate?
    let stateDelegate: TvShowStateChangeDelegate?
    
    init?(sessionId: String, detailsDelegate: TvShowDetailsDelegate?, stateDelegate: TvShowStateChangeDelegate?){
        self.session = sessionId
        self.detailsDelegate = detailsDelegate
        self.stateDelegate = stateDelegate
        
        if sessionId.isEmpty {
            return nil
        }
    }
    
    convenience init?(sessionId: String, detailsDelegate: TvShowDetailsDelegate){
        self.init(sessionId: sessionId, detailsDelegate: detailsDelegate, stateDelegate: nil)
    }
    
    convenience init?(sessionId: String, stateDelegate: TvShowStateChangeDelegate){
        self.init(sessionId: sessionId, detailsDelegate: nil, stateDelegate: stateDelegate)
    }
    
    func loadDetails(id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.tvDetails(id), parameters: params,
            success: { operation, response in
                if let results = Mapper<TvShowInfo>().map(response) {
                    self.detailsDelegate?.tvshowDetailsLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.tvshowDetailsLoadingFailed(error)
        })
    }
    
    func loadState(id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.tvState(id), parameters: params,
            success: { operation, response in
                if let results = Mapper<AccountState>().map(response) {
                    self.detailsDelegate?.tvshowStateLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.tvshowStateLoadingFailed(error)
        })
    }
    
    func changeFavoriteState(id: String, state: Bool){
        let newState = !state
        let body = Mapper<FavoriteBody>().toJSONString(FavoriteBody(tvShowId: Int(id), isFavorite: newState), prettyPrint: true)!
        
        let request = NSMutableURLRequest(URL: NSURL(string: ApiEndpoints.accountItemFavoriteState(id, session))!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.HTTPRequestOperationWithRequest(request,
            success: { operation, response in
                self.stateDelegate?.tvshowFavoriteStateChangedSuccessfully(newState)
            },
            failure: { operation, error in
                self.stateDelegate?.tvshowFavoriteStateChangesFailed(error)
        }).start()
    }
    
    func changeWatchlistState(id: String, state: Bool){
        let newState = !state
        let body = Mapper<WatchlistBody>().toJSONString(WatchlistBody(tvShowId: Int(id), isInWatchlist: newState), prettyPrint: true)!
        print(body)
        
        let request = NSMutableURLRequest(URL: NSURL(string: ApiEndpoints.accountItemWatchlistState(id, session))!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.HTTPRequestOperationWithRequest(request,
            success: { operation, response in
                self.stateDelegate?.tvshowWatchlistStateChangedSuccessfully(newState)
            },
            failure: { operation, error in
                self.stateDelegate?.tvshowWatchlistStateChangesFailed(error)
        }).start()
    }
    
    func loadImages(id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.tvImages(id), parameters: params,
            success: { operation, response in
                if let results = Mapper<ImageInfoList>().map(response) {
                    self.detailsDelegate?.tvshowImagesLoadedSuccessully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.tvshowImagesLoadingFailed(error)
        })
    }
    
    func loadCredits(id: String) {
        let params = [
            "api_key": ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.tvCredits(id), parameters: params,
            success: { operation, response in
                if let results = Mapper<Credits>().map(response) {
                    self.detailsDelegate?.tvshowCreditsLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.tvshowCreditsLoadingFailed(error) }
        )
    }
}

protocol TvShowDetailsDelegate {
    
    func tvshowDetailsLoadedSuccessfully(details: TvShowInfo) -> Void
    
    func tvshowDetailsLoadingFailed(error: NSError) -> Void
    
    func tvshowStateLoadedSuccessfully(state: AccountState) -> Void
    
    func tvshowStateLoadingFailed(error: NSError) -> Void
    
    func tvshowImagesLoadedSuccessully(images: ImageInfoList) -> Void
    
    func tvshowImagesLoadingFailed(error: NSError) -> Void
    
    func tvshowCreditsLoadedSuccessfully(credits: Credits) -> Void
    
    func tvshowCreditsLoadingFailed(error: NSError) -> Void
}

protocol TvShowStateChangeDelegate {
    
    func tvshowFavoriteStateChangedSuccessfully(isFavorite: Bool) -> Void
    
    func tvshowFavoriteStateChangesFailed(error: NSError) -> Void
    
    func tvshowWatchlistStateChangedSuccessfully(isInWatchlist: Bool) -> Void
    
    func tvshowWatchlistStateChangesFailed(error: NSError)
}

class PersonDetailsManager {
    
    var detailsDelegate: PersonDetailsDelegate?
    
    init(detailsDelegate: PersonDetailsDelegate?){
        self.detailsDelegate = detailsDelegate
    }
    
    func loadDetails(id: String) {
        let params = [
            "api_key" : ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.personDetails(id), parameters: params,
            success: { operation, response in
                if let results = Mapper<PersonInfo>().map(response) {
                    self.detailsDelegate?.personDetailsLoadedSuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.personDetailsLoadingFailed(error) }
        )
    }
    
    func loadCredits(id: String) {
        let params = [
            "api_key" : ApiEndpoints.apiKey
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.personCredits(id), parameters: params,
            success: { operation, response in
                if let results = Mapper<PersonCredits>().map(response) {
                    self.detailsDelegate?.personCreditsLoadedScuccessfully(results)
                }
            },
            failure: { operation, error in self.detailsDelegate?.personCreditsLoadingFailed(error) }
        )
    }
}

protocol PersonDetailsDelegate {

    func personDetailsLoadedSuccessfully(details: PersonInfo) -> Void
    
    func personDetailsLoadingFailed(error: NSError) -> Void
    
    func personCreditsLoadedScuccessfully(credits: PersonCredits) -> Void
    
    func personCreditsLoadingFailed(error: NSError) -> Void
}

class TrendsManager {
    
    let delegate: TrendsDelegate?
    
    init(delegate: TrendsDelegate?){
        self.delegate = delegate
    }
    
    func loadPopular(type: TrendsType, page: Int = 1){
        let params = [
            "api_key": ApiEndpoints.apiKey,
            "page": page
        ]
        
        AFHTTPRequestOperationManager().GET(type.url(), parameters: params,
            success: { operation, response in
                switch type {
                case .MOVIE:
                    if let movies = Mapper<MovieTrendsList>().map(response) {
                        if let result = TrendsList(fromMovieList: movies) {
                            self.delegate?.trendsLoadedSuccessfully(result)
                        }
                    }
                case .TV:
                    if let tvshows = Mapper<TvTrendsList>().map(response) {
                        if let result = TrendsList(fromTvList: tvshows) {
                            self.delegate?.trendsLoadedSuccessfully(result)
                        }
                    }
                }  
            },
            failure: { operation, error in self.delegate?.trendsLoadingFailed(error)
        })
    }
}

protocol TrendsDelegate {

    func trendsLoadedSuccessfully(trends: TrendsList) -> Void
    
    func trendsLoadingFailed(error: NSError) -> Void
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
    static let accountFavoriteMovies = { (id: Int) in "\(baseApiUrl)/account/\(id)/favorite/movies" }
    static let accountRatedMovies = { (id: Int) in "\(baseApiUrl)/account/\(id)/rated/movies" }
    static let accountWatchlistMovies = { (id: Int) in "\(baseApiUrl)/account/\(id)/watchlist/movies" }
    static let accountItemFavoriteState = { (id: String, session: String) in "\(baseApiUrl)/account/\(id)/favorite?api_key=\(apiKey)&session_id=\(session)" }
    static let accountItemWatchlistState = { (id: String, session: String) in "\(baseApiUrl)/account/\(id)/watchlist?api_key=\(apiKey)&session_id=\(session)" }
    //list
    static let listStatus = { (id: String) in "\(baseApiUrl)/list/\(id)/item_status" }
    static let listAddItem = { (id: String, session: String) in "\(baseApiUrl)/list/\(id)/add_item?api_key=\(apiKey)&session_id=\(session)" }
    static let listDeleteItem = { (id: String, session: String) in "\(baseApiUrl)/list/\(id)/remove_item?api_key=\(apiKey)&session_id=\(session)" }
    static let listDetails = { (id: String) in "\(baseApiUrl)/list/\(id)" }
    static let listShare = { (id: String) in "\(baseShareUrl)/list/\(id)"}
    //search
    static let searchMovie = "\(baseApiUrl)/search/movie"
    static let searchTvShow = "\(baseApiUrl)/search/tv"
    static let searchPerson = "\(baseApiUrl)/search/person"
    //details 
    static let movieDetails = { (id: String) in "\(baseApiUrl)/movie/\(id)" }
    static let movieImages = { (id: String) in "\(baseApiUrl)/movie/\(id)/images"}
    static let movieCredits = { (id: String) in "\(baseApiUrl)/movie/\(id)/credits"}
    static let movieState = { (id: String) in "\(baseApiUrl)/movie/\(id)/account_states" }
    static let movieShare  = "\(baseShareUrl)/movie"
    static let tvDetails = { (id: String) in "\(baseApiUrl)/tv/\(id)" }
    static let tvImages = { (id: String) in "\(baseApiUrl)/tv/\(id)/images"}
    static let tvCredits = { (id: String) in "\(baseApiUrl)/tv/\(id)/credits"}
    static let tvState = { (id: String) in "\(baseApiUrl)/tv/\(id)/account_states" }
    static let tvShare  = "\(baseShareUrl)/tv"
    
    static let personDetails = { (id: String) in "\(baseApiUrl)/person/\(id)" }
    static let personImages = { (id: String) in "\(baseApiUrl)/person/\(id)/images"}
    static let personCredits = { (id: String) in "\(baseApiUrl)/person/\(id)/combined_credits"}
    static let personState = { (id: String) in "\(baseApiUrl)/movie/\(id)/account_states" }
    static let personShare  = "\(baseShareUrl)/person"
    //trends
    static let popularMovies = "\(baseApiUrl)/movie/popular"
    static let popularTvShow = "\(baseApiUrl)/tv/popular"
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
    static let poster = { (size: Int, path: String) in "\(baseImageUrl)/\(posterSizes[size]!)\(path)?api_key=\(apiKey)"}
    
}