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
    
    var hasMoreItems = false
    var nextPage: Int?
    var totalItems = 0
    var popularTrends: Bool = true
    var trendsType = TrendsType.MOVIE
    var trendsManager: TrendsManager?
    var items = [[TrendsRepresentation]]()
    
    @IBOutlet weak var typeSegmentControl: UISegmentedControl!
    @IBOutlet weak var pagintationIndicator: UIView!
    
    @IBAction func typeChanged(sender: UISegmentedControl) {
        trendsType = TrendsType(rawValue: sender.selectedSegmentIndex)!
        loadInitPage()
    }
    
    @IBAction func criteriaChanged(sender: UISegmentedControl) {
        popularTrends = sender.selectedSegmentIndex == 0
        loadInitPage()
    }
    
    override func viewDidLoad() {
        trendsManager = TrendsManager(delegate: self)
        trendsManager?.loadPopular(trendsType)
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.tableFooterView?.hidden = true
    }
    
    func trendsLoadedSuccessfully(trends: TrendsList) {
        chunkResults(trends.results!)
        
        hasMoreItems = trends.hasMorePages
        nextPage = trends.nextPage
        
        tableView.tableFooterView?.hidden = true
        tableView.reloadData()
    }
    
    func chunkResults(var results: [TrendsRepresentation]) {
        if !results.isEmpty {
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
    }
    
    func loadInitPage(){
        nextPage = 1
        totalItems = 0
        items.removeAll()
        trendsManager?.loadPopular(trendsType, popular: popularTrends, page: nextPage!)
    }
    
    func loadNextPage() {
        tableView.tableFooterView?.hidden = false
        if let page = nextPage {
            trendsManager?.loadPopular(trendsType, popular: popularTrends, page: page)
        }
        hasMoreItems = false
    }
    
    func trendsLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func posterTapped(itemId: Int?) {
        switch trendsType {
        case .MOVIE:
            MovieDetailsController.presentControllerWithNavigation(self, id: String(itemId!))
        case .TV:
            TvShowDetailsController.presentControllerWithNavigation(self, id: String(itemId!))
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TrendsTableViewCell.identifier, forIndexPath: indexPath) as! TrendsTableViewCell
        let item = $.shuffle(items[indexPath.row])
        
        cell.setupDelegate(self)
        
        cell.leftPoster.itemId = item[0].id
        cell.leftPoster.sd_setImageWithURL(NSURL(posterPath: item[0].poster, size: 2))
        
        cell.middlePoster.itemId = item[1].id
        cell.middlePoster.sd_setImageWithURL(NSURL(posterPath: item[1].poster, size: 2))
        
        cell.rightPoster.itemId = item[2].id
        cell.rightPoster.sd_setImageWithURL(NSURL(backdropPath: item[2].backdrop, size: 1))
            { (image, error, cacheType, url) -> Void in cell.detailsBackground.image = cell.rightPoster.image }
        
        cell.titleLabel.text = item[2].title
        cell.rateLabel.text = item[2].rate
        cell.descriptionLabel.text = item[2].desc
        
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

protocol TrendsRepresentation {
    var id: Int? { get }
    var title: String? { get }
    var poster: String? { get }
    var backdrop: String? { get }
    var desc: String? { get }
    var rate: String? { get }
}

enum TrendsType: Int {
    case MOVIE = 0, TV
    
    var popularUrl: String {
        switch self {
        case .MOVIE: return TrendsManager.urlPopMovies
        case .TV: return TrendsManager.urlPopTv
        }
    }
    
    var topUrl: String {
        switch self {
        case .MOVIE: return TrendsManager.urlTopMovies
        case .TV: return TrendsManager.urlTopTv
        }
    }
}
