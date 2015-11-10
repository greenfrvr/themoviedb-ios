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

    //MARK: Properties
    var nextPage: Int?
    var hasMoreItems = false
    var currentType = AccountManager.SegmentType.List
    var session: Session!
    var accountManager: AccountManager?
    var lists = [SegmentsRepresentation]()
    
    //MARK: Outlets
    @IBOutlet weak var paginationView: UIView!
    
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
        tableView.tableFooterView?.hidden = true
        refreshControl?.endRefreshing()
    }
    
    //MARK: ListsDelegate
    func userListsLoadedSuccessfully(results: ListInfoPages) {
        receiveResults(lists += results.resultsRepresentative!, pages: results)
    }
    
    func userSegmentLoadedSuccessfully(results: SegmentList) {
        receiveResults(lists += results.resultsRepresentative!, pages: results)
    }
    
    func receiveResults(@autoclosure persistData: () -> Void, pages: PaginationLoading) {
        persistData()
        
        hasMoreItems = pages.hasMorePages
        nextPage = pages.nextPage
        
        tableView.reloadData()
        tableView.tableFooterView?.hidden = true
        
        stopRefreshing()
        updateRefreshingTitle()
    }
    
    func userFetched(){
        accountManager?.loadSegment(currentType)
    }
    
    func userListsLoadingFailed(error: NSError) {
        print(error)
    }
    
    func userSegmentLoadingFailed(error: NSError) {
        print(error)
    }
    
    //MARK: UserSegmentsDelegate
    func loadLists() {
        currentType = .List
        loadData()
        print("load lists")
    }
    
    func loadFavorite() {
        currentType = .Favorite
        loadData()
        print("load favorites")
    }
    
    func loadRated() {
        currentType = .Rated
        loadData()
        print("load rated")
    }
    
    func loadWatchlist() {
        currentType = .Watchlist
        loadData()
        print("load watchlist")
    }
    
    func loadData(){
        lists.removeAll()
        accountManager?.loadSegment(currentType)
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
        
        cell.listTitleLabel.text = item.representTitle
        cell.listDescLabel.text = item.representDescription
        cell.listCounterLabel.text = item.representCounter
        cell.listImageView.sd_setImageWithURL(NSURL(string: ApiEndpoints.poster(3, item.representImage ?? "")), placeholderImage: UIImage(named: "defaultPhoto"))
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = lists[indexPath.row]
        
        switch currentType {
        case .List:
            print("list clicked")
            presentCollectionController(item.id)
        default:
            print("movie clicked")
            presentMovieController(item.id)
        }
    }
    
    func presentCollectionController(id: String?) {
        let navigationController = storyboard?.instantiateViewControllerWithIdentifier("CollectionNavigationController") as! UINavigationController
        let controller = navigationController.topViewController as! ListDetailsController
        controller.argListId = id
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func presentMovieController(id: String?) {
        let navigationController = storyboard?.instantiateViewControllerWithIdentifier("MovieNavigationController") as! UINavigationController
        let controller = navigationController.topViewController as! MovieDetailsController
        controller.movieId = id
        presentViewController(navigationController, animated: true, completion: nil)
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
    }
    
    //MARK: Pull-to-refresh
    func setupPullToRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.rgb(22, 122, 110)
        refreshControl?.tintColor = UIColor.whiteColor()
        refreshControl?.addTarget(self, action: Selector("loadInitPage"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func stopRefreshing() {
        if let refresh = refreshControl where refresh.refreshing {
            refresh.endRefreshing()
        }
    }
    
    func updateRefreshingTitle() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let title = "Last update: \(formatter.stringFromDate(NSDate()))"
        refreshControl?.attributedTitle = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
    }
//    
//    //MARK: Navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "ListDetails" {
//            let navigationViewController = segue.destinationViewController as! UINavigationController
//            let destinationViewController = navigationViewController.topViewController as! ListDetailsController
//            
//            if let cellSender = sender as? ListsTableViewCell {
//                let index = tableView.indexPathForCell(cellSender)!
//                let selectedList = lists[index.row]
//                destinationViewController.argList = selectedList as! ListInfo
//            }
//        }
//    }
}
