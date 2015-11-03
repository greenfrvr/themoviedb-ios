//
//  UserListsController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/3/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class UserListsTableController: UITableViewController, ListsDelegate {

    //MARK: Properties
    var lastLoadedPage: Int = 1
    var pagesTotal: Int = 1
    var session: Session!
    var accountManager: AccountManager?
    var lists: [ListInfo] = []
    
    //MARK: Controller lifecycle
    override func viewDidLoad() {
        session = SessionCache.restoreSession()!
        accountManager = AccountManager(sessionId: session.sessionToken!, listsDelegate: self)
        accountManager?.loadAccountData()
    }
    
    //MARK: ListsDelegate
    func userListsLoadedSuccessfully(pages: ListInfoPages) {
        pagesTotal = pages.pagesTotal!
        lastLoadedPage = pages.page!
        lists = pages.results!
        print("Pages loaded, total count is \(pages.resultsTotal!)")
        tableView.reloadData()
    }
    
    func userListsLoadingFailed(error: NSError) {
        print(error)
    }
    
    func userFetched(){
        print("Fetched")
        accountManager?.loadLists()
    }
    
    //MARK: TableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ListsTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ListsTableViewCell
        
        let list = lists[indexPath.row]
        
        cell.listTitleLabel.text = list.listName
        cell.listDescLabel.text = list.listDesc
        cell.listCounterLabel.text = list.itemsCount
        
        return cell

    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ListDetails" {
            let navigationViewController = segue.destinationViewController as! UINavigationController
            let destinationViewController = navigationViewController.topViewController as! ListInfoController
            
            if let mealCellSender = sender as? ListsTableViewCell {
                let index = tableView.indexPathForCell(mealCellSender)!
                let selectedList = lists[index.row]
                destinationViewController.argList = selectedList
            }
        }
    }
}
