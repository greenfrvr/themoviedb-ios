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
    var session: Session!
    var accountManager: AccountManager?
    var lists: [ListInfo] = []
    
    //MARK: Actions
    @IBAction func unwindItemRemoved(segue: UIStoryboardSegue){
        if let selectedIndex = tableView.indexPathForSelectedRow {
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
    func userListsLoadedSuccessfully(results: ListInfoPages) {
        lists = results.results!
        
        tableView.reloadData()
        refreshControl?.endRefreshing()
        updateRefreshingTitle()
    }
   
    func userFetched(){
        accountManager?.loadLists()
    }
    
    func userListsLoadingFailed(error: NSError) {
        print(error)
    }
    
    //MARK: TableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ListsTableViewCell.identifier, forIndexPath: indexPath) as! ListsTableViewCell
        let item = lists[indexPath.row]
        
        cell.listTitleLabel.text = item.listName
        cell.listDescLabel.text = item.listDesc
        cell.listCounterLabel.text = item.itemsCount
        
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
        refreshControl?.attributedTitle = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
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
