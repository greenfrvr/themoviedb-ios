//
//  UserListsController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/3/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import SDWebImage
import Dollar

class AccountTableController: UITableViewController, ListsDelegate, UserSegmentsDelegate {

    var nextPage: Int?
    var hasMoreItems = false
    var currentType = AccountSegmentType.List
    var accountManager: AccountManager?
    var lists = [SegmentsRepresentation]()
    
    @IBOutlet weak var paginationView: UIView!
    
    @IBAction func unwindItemRemoved(segue: UIStoryboardSegue){
        if let selectedIndex = tableView.indexPathForSelectedRow {
            lists.removeAtIndex(selectedIndex.row)
            tableView.deleteRowsAtIndexPaths([selectedIndex], withRowAnimation: .Fade)
        }
    }
    
    override func viewDidLoad() {
        if let session = Cache.restoreSession() {
            accountManager = AccountManager(sessionId: session, listsDelegate: self)
            accountManager?.loadAccountData()
        }
    
        setupPullToRefreshControl()
        tableView.tableFooterView?.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveListUpdate:", name: Notify.ListUpdate.rawValue, object: nil)
    }
    
    func receiveListUpdate(notification: NSNotification) {
        guard let dict = notification.userInfo, list = dict["listId"] as? String else {
            print("Received notification with no data")
            return
        }
    
        let ind = $.findIndex(lists) {
            guard let id = $0.id else { return false }
            return id == list
        }
        
        guard let index = ind else { return }
        
        var item = lists[index]
        item.increaseCounter()
        lists[index] = item
        
        tableView.reloadData()
    }
    
    func receiveResults<T: PaginationLoading>(@autoclosure persistData: () -> Void, pages: T) {
        clearIfNeeded()
        persistData()
        
        hasMoreItems = pages.hasMorePages
        nextPage = pages.nextPage
        
        tableView.reloadData()
        tableView.tableFooterView?.hidden = true
        stopRefreshing()
    }
    
    func userListsLoadedSuccessfully(results: CompilationInfoPages) {
        loadingIndicatorVisible(false)
        guard let list = results.resultsRepresentative else { return }
        
        receiveResults(lists += list, pages: results)
    }
    
    func userSegmentLoadedSuccessfully(results: SegmentList) {
        loadingIndicatorVisible(false)
        guard let list = results.resultsRepresentative else { return }

        receiveResults(lists += list, pages: results)
    }
    
    func userFetched(){
        accountManager?.loadSegment(currentType)
    }
    
    func userListsLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func userSegmentLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func loadSelectedSegment(segment: AccountSegmentType) {
        currentType = segment
        loadInitPage()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ListsTableViewCell.identifier, forIndexPath: indexPath) as! ListsTableViewCell
        let item = lists[indexPath.row]
        
        cell.listTitleLabel.text = item.representTitle
        cell.listDescLabel.text = item.representDescription
        cell.listCounterLabel.text = item.representCounter
        cell.listImageView.sd_setImageWithURL(NSURL(string: item.representImage ?? ""), placeholderImage:  UIImage(res: .Placeholder))
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = lists[indexPath.row]
        
        switch currentType {
        case .List: ListDetailsController.presentControllerWithNavigation(self, id: item.id)
        default: MovieDetailsController.presentControllerWithNavigation(self, id: item.id)
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 && hasMoreItems {
            loadPage()
        }
    }
    
    func loadPage() {
        self.tableView.tableFooterView?.hidden = false
        if let page = nextPage {
            accountManager?.loadSegment(currentType, page: page)
        }
        hasMoreItems = false
    }
    
    func loadInitPage(){
        lists.removeAll()
        tableView.reloadData()
        loadingIndicatorVisible(true)
        accountManager?.loadSegment(currentType)
    }
    
    func refreshInitPage(){
        accountManager?.loadSegment(currentType)
    }
    
    func loadingIndicatorVisible(start: Bool) {
        if let parent = self.parentViewController as? AccountController {
            if start {
                parent.loadingIndicator.startAnimating()
            } else {
                parent.loadingIndicator.stopAnimating()
            }
        }
    }
    
    func setupPullToRefreshControl() {
        let refresh = UIRefreshControl()
        refresh.backgroundColor = view.backgroundColor
        refresh.tintColor = UIColor.rgb(6, 117, 255)
        refresh.addTarget(self, action: "refreshInitPage", forControlEvents: UIControlEvents.ValueChanged)
        
        refreshControl = refresh
    }
    
    func stopRefreshing() {
        if let control = refreshControl where control.refreshing {
            control.endRefreshing()
        }
    }
    
    func clearIfNeeded() {
        if let control = refreshControl where control.refreshing {
            lists.removeAll()
        }
    }
    
}




