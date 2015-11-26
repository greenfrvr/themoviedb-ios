//
//  UserListsController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/3/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import SDWebImage

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
    }
    
    func receiveResults(@autoclosure persistData: () -> Void, pages: PaginationLoading) {
        persistData()
        
        hasMoreItems = pages.hasMorePages
        nextPage = pages.nextPage
        
        tableView.reloadData()
        tableView.tableFooterView?.hidden = true
        stopRefreshing()
    }
    
    func userListsLoadedSuccessfully(results: ListInfoPages) {
        receiveResults(lists += results.resultsRepresentative!, pages: results)
    }
    
    func userSegmentLoadedSuccessfully(results: SegmentList) {
        receiveResults(lists += results.resultsRepresentative!, pages: results)
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
        cell.listImageView.sd_setImageWithURL(NSURL(string: item.representImage ?? ""), placeholderImage: UIImage.placeholder())
        
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
        accountManager?.loadSegment(currentType)
        updateRefreshingTitle()
    }
    
    func setupPullToRefreshControl() {
        let refresh = UIRefreshControl()
        refresh.backgroundColor = UIColor.rgb(22, 122, 110)
        refresh.tintColor = UIColor.whiteColor()
        refresh.addTarget(self, action: "loadInitPage", forControlEvents: UIControlEvents.ValueChanged)
        
        refreshControl = refresh
    }
    
    func stopRefreshing() {
            refreshControl?.endRefreshing()
    }
    
    func updateRefreshingTitle() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let title = String(format: NSLocalizedString("Last update:", comment: ""), formatter.stringFromDate(NSDate()))
        refreshControl?.attributedTitle = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
    }
}




