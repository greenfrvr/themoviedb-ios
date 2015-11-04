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
    
    @IBAction func unwindItemRemoved(segue: UIStoryboardSegue){
        if let selectedIndex = tableView.indexPathForSelectedRow {
            print("selected index found")
            lists.removeAtIndex(selectedIndex.row)
            tableView.deleteRowsAtIndexPaths([selectedIndex], withRowAnimation: .Fade)
        }
    }
    
    //MARK: Controller lifecycle
    override func viewDidLoad() {
        session = SessionCache.restoreSession()!
        accountManager = AccountManager(sessionId: session.sessionToken!, listsDelegate: self)
        accountManager?.loadAccountData()
    
        setupPullToRefreshControl()
    }
    
    //MARK: ListsDelegate
    func userListsLoadedSuccessfully(pages: ListInfoPages) {
        pagesTotal = pages.pagesTotal!
        lastLoadedPage = pages.page!
        lists = pages.results!
        
        print("Pages loaded, total count is \(pages.resultsTotal!)")
        
        tableView.reloadData()
        refreshControl?.endRefreshing()
        updateRefreshingTitle()
    }
    
    func userListsLoadingFailed(error: NSError) {
        print(error)
    }
    
    func userFetched(){
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
    
    //MARK: Pull-to-refresh
    func setupPullToRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor(colorLiteralRed: 22/255.0, green: 122/255.0, blue: 110/255.0, alpha: 1)
        refreshControl?.tintColor = UIColor.whiteColor()
        refreshControl?.addTarget(self, action: Selector("userFetched"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func updateRefreshingTitle() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let title = "Last update: \(formatter.stringFromDate(NSDate()))"
        refreshControl?.attributedTitle = NSAttributedString.init(string: title, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ListDetails" {
            let navigationViewController = segue.destinationViewController as! UINavigationController
            let destinationViewController = navigationViewController.topViewController as! ListDetailsController
            
            if let cellSender = sender as? ListsTableViewCell {
                let index = tableView.indexPathForCell(cellSender)!
                let selectedList = lists[index.row]
                destinationViewController.argList = selectedList
            }
        }
    }
}
