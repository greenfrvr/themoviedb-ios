//
//  AccountManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//
import AFNetworking
import ObjectMapper

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
    
    func loadAccountData() {
        func callback(account: Account) {
            self.account = account
            self.accountDelegate?.userLoadedSuccessfully(account)
            self.listsDelegate?.userFetched()
        }
        
        if let account = Cache.restoreAccount() {
            print("Loaded from device")
            callback(account)
            return
        }

        let params = [
            "api_key": ApiEndpoints.apiKey,
            "session_id": session,
        ]
        
        AFHTTPRequestOperationManager().GET(ApiEndpoints.accountInfo, parameters: params,
            success: { operation, response in
                if let account = Mapper<Account>().map(response) {
                    print("Loaded from network")
                    Cache.saveAccount(account)
                    callback(account)
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
            AFHTTPRequestOperationManager().GET(String(format: ApiEndpoints.accountLists, (account?.userId)!), parameters: params,
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
        case .Favorite: url = String(format: ApiEndpoints.accountFavoriteMovies, (account?.userId)!)
        case .Rated: url = String(format: ApiEndpoints.accountRatedMovies, (account?.userId)!)
        case .Watchlist: url = String(format: ApiEndpoints.accountWatchlistMovies, (account?.userId)!)
        case .List: url = nil
        }
        
        if let requestUrl = url {
            segment(requestUrl)
        } else {
            list()
        }
    }
    
    func addToList(listId id: String, itemId: Int) {
        updateList(String(format: ApiEndpoints.listAddItem, id, session), id: id, itemId: itemId)
    }
    
    func removeFromList(listId id: String, itemId: Int) {
        updateList(String(format: ApiEndpoints.listDeleteItem, id, session), id: id, itemId: itemId)
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