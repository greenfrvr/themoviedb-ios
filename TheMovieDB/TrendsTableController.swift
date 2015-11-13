//
//  TrendsTableController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/12/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import SDWebImage
import Dollar

class TrendsTableController: UITableViewController, UIPosterViewDelegate, TrendsDelegate {
    
    //MARK: Properties
    var hasMoreItems = false
    var nextPage: Int?
    var totalItems = 0
    var trendsType = TrendsType.MOVIE
    var trendsManager: TrendsManager?
    var items = [[SegmentListItem]]()
    
    //MARK: Outlets
    @IBOutlet weak var typeSegmentControl: UISegmentedControl!
    @IBOutlet weak var pagintationIndicator: UIView!
    
    //MARK: Actions
    @IBAction func typeChanged(sender: UISegmentedControl) {
        print("Type changed to \(sender.selectedSegmentIndex)")
        trendsType = TrendsType(rawValue: sender.selectedSegmentIndex)!
        loadInitPage()
    }
    
    @IBAction func criteriaChanged(sender: UISegmentedControl) {
        print("Criteria changed to \(sender.selectedSegmentIndex)")
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        trendsManager = TrendsManager(delegate: self)
        trendsManager?.loadPopular(trendsType)
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.tableFooterView?.hidden = true
    }
    
    //MARK: TrendsDelegate
    func trendsLoadedSuccessfully(results: SegmentList) {
        if var results = results.results {
            var r = (3 - totalItems % 3) % 3
            totalItems += results.count
            
            while r-- > 0 {
                items[items.endIndex.predecessor()].append(results.removeFirst())
            }
            
            let sets = $.chunk(results, size: 3)
            for chunk in sets {
                items.append(chunk)
            }
        }
        
        hasMoreItems = results.hasMorePages
        nextPage = results.nextPage
        
        tableView.tableFooterView?.hidden = true
        tableView.reloadData()
    }
    
    func loadInitPage(){
        nextPage = 1
        totalItems = 0
        items.removeAll()
        trendsManager?.loadPopular(trendsType, page: nextPage!)
    }
    
    func loadNextPage() {
        tableView.tableFooterView?.hidden = false
        if let page = nextPage {
            trendsManager?.loadPopular(trendsType, page: page)
        }
        hasMoreItems = false
    }
    
    func trendsLoadingFailed(error: NSError) {
        print(error)
    }
    
    //MARK: PosterDelegate
    func posterTapped(itemId: Int?) {
        print("Item with id \(itemId!) was tapped")
        switch trendsType {
        case .MOVIE:
            MovieDetailsController.performMovieController(self, id: String(itemId!))
        case .TV: print("TV show details not ready")
        }
    }
    
    //MARK: TableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TrendsTableViewCell.identifier, forIndexPath: indexPath) as! TrendsTableViewCell
        let item = $.shuffle(items[indexPath.row])
        
        cell.setupDelegate(self)
        
        cell.leftPoster.sd_setImageWithURL(NSURL(string: ApiEndpoints.poster(3, item[0].posterPath ?? "")))
        cell.leftPoster.itemId = item[0].itemId
        
        cell.middlePoster.sd_setImageWithURL(NSURL(string: ApiEndpoints.poster(3, item[1].posterPath ?? "")))
        cell.middlePoster.itemId = item[1].itemId
        
        cell.rightPoster.itemId = item[2].itemId
        cell.rightPoster.sd_setImageWithURL(NSURL(string: ApiEndpoints.poster(5, item[2].backdropPath ?? ""))) { (image, error, cacheType, url) -> Void in
            cell.detailsBackground.image = cell.rightPoster.image
        }
        cell.titleLabel.text = item[2].representTitle
        cell.rateLabel.text = String(item[2].representCounter!)
        cell.descriptionLabel.text = item[2].representDescription
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count - (totalItems % 3 == 0 ? 0 : 1)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - view.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 && hasMoreItems {
            loadNextPage()
        }
    }
}

enum TrendsType: Int {
    case MOVIE = 0, TV
    
    func url() -> String {
        switch self {
        case .MOVIE: return ApiEndpoints.popularMovies
        case .TV: return ApiEndpoints.popularTvShow
        }
    }
}
