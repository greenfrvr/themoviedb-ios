//
//  AccountManager.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//
import AFNetworking
import ObjectMapper

class AccountManager: ApiManager, SessionRequired {
    var sessionId: String
    var account: Account?
    let accountDelegate: AccountDelegate?
    let listsDelegate: ListsDelegate?
    
    init?(session: String, accountDelegate: AccountDelegate?, listsDelegate: ListsDelegate?){
        self.sessionId = session
        self.accountDelegate = accountDelegate
        self.listsDelegate = listsDelegate
        
        super.init()
        
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
            callback(account)
            return
        }
        
        get(urlAccount, apiKey +> session, callback, accountDelegate?.userLoadingFailed) { Cache.saveAccount($0) }
    }
    
    func loadSegment(type: AccountSegmentType, page: Int = 1){
        guard let userId = account?.userId else {
            print("Can't obtain user id")
            return
        }
        
        let url = type.requestUrl.withArgs(userId)
        switch type {
        case .List:
            get(url, apiKey +> session +> [ "page" : page ], listsDelegate?.userListsLoadedSuccessfully, listsDelegate?.userListsLoadingFailed)
        default:
            get(url, apiKey +> session +> [ "page" : page ], listsDelegate?.userSegmentLoadedSuccessfully, listsDelegate?.userSegmentLoadingFailed)
        }
    }
    
    func addToList(listId id: String, itemId: Int) {
        updateList(urlAddItem.withArgs(id, sessionId), itemId: itemId)
    }
    
    func removeFromList(listId id: String, itemId: Int) {
        updateList(urlDeleteItem.withArgs(id, sessionId), itemId: itemId)
    }
    
    private func updateList(url: String, itemId: Int){
        let body = CompilationDetails.UpdateBody(mediaId: itemId)
        post(url, body, listsDelegate?.listItemUpdatedSuccessfully, listsDelegate?.listItemUpdatingFailed)
    }
}

protocol AccountDelegate {
    
    func userLoadedSuccessfully(account: Account) -> Void
    
    func userLoadingFailed(error: NSError) -> Void
}

protocol ListsDelegate {
    
    func userListsLoadedSuccessfully(pages: CompilationInfoPages) -> Void
    
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