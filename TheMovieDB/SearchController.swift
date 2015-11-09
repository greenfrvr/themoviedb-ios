//
//  SearchController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/3/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import SDWebImage

class SearchController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, SearchDelegate  {
    
    //MARK: Properties
    var scopeIndex = 0
    var nextPage: Int?
    var hasMoreItems = false
    var query: String?
    var searchManager: SearchManager?
    var resultsMovies = [SearchMovieItem]()
    var resultsTvShow = [SearchTVItem]()
    var resultsPerson = [SearchPersonItem]()
    var totalItemsForType = [0, 0, 0]
    
    //MARK: Outlets
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pagintationView: UIView!
    @IBOutlet weak var pagintationIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pagintationLabel: UILabel!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchManager = SearchManager(delegate: self)
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchTableView.tableFooterView?.hidden = true
    }
    
    //MARK: Data
    func receiveResults(@autoclosure persistData: () -> Void, pages: PaginationLoading) {
        persistData()
        
        hasMoreItems = scopeIndex > 0 && pages.hasMorePages
        nextPage = pages.nextPage
        
        loadingIndicator.stopAnimating()
        searchTableView.reloadData()
        searchTableView.tableFooterView?.hidden = true
    }
    
    func executeQuery() {
        print("Searching for: \(searchBar.text!)")
        if let queryString = query where !queryString.isEmpty {
            loadingIndicator.startAnimating()
            switch scopeIndex {
            case 0:
                searchManager?.queryMovies(queryString)
                searchManager?.queryTvShow(queryString)
                searchManager?.queryPerson(queryString)
            case 1:
                searchManager?.queryMovies(queryString)
            case 2:
                searchManager?.queryTvShow(queryString)
            case 3:
                searchManager?.queryPerson(queryString)
            default: return
            }
        }
    }
    
    func loadNextPage(){
        searchTableView.tableFooterView?.hidden = false
        if let page = nextPage {
            if scopeIndex == 1 {
                searchManager?.queryMovies(query!, page: page)
            }
            if scopeIndex == 2 {
                searchManager?.queryTvShow(query!, page: page)
            }
            if scopeIndex == 3 {
                searchManager?.queryPerson(query!, page: page)
            }
        }
        hasMoreItems = false
    }
    
    func clearResutls(){
        resultsMovies.removeAll()
        resultsTvShow.removeAll()
        resultsPerson.removeAll()
        searchTableView.reloadData()
        searchTableView.tableFooterView?.hidden = true
    }

    
    //MARK: SearchDelegate
    func searchMovieResuts(searchResults: SearchMovieResults) {
        receiveResults(self.resultsMovies += searchResults.results!, pages: searchResults)
        print("\(searchResults.results!.count) movies loaded out of \(searchResults.totalItems!)")
        totalItemsForType[0] = searchResults.results?.count ?? 0
    }
    
    func searchTvShowResuts(searchResults: SearchTVResults) {
        receiveResults(self.resultsTvShow += searchResults.results!, pages: searchResults)
        print("\(searchResults.results!.count) tv shows loaded out of \(searchResults.totalItems!)")
        totalItemsForType[1] = searchResults.results?.count ?? 0
    }
    
    func searchPersonResuts(searchResults: SearchPersonResults) {
        receiveResults(self.resultsPerson += searchResults.results!, pages: searchResults)
        print("\(searchResults.results!.count) psersons loaded out of \(searchResults.totalItems!)")
        totalItemsForType[2] = searchResults.results?.count ?? 0
    }
    
    func searchNoMoviesFound(error: NSError) {
        print(error)
        loadingIndicator.stopAnimating()
    }
    
    func searchNoTvShowFound(error: NSError) {
        print(error)
        loadingIndicator.stopAnimating()
    }
    
    func searchNoPersonFound(error: NSError) {
        print(error)
        loadingIndicator.stopAnimating()
    }
    
    //MARK: TableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return scopeIndex == 0 ? 3 : 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SearchViewCell.identifier, forIndexPath: indexPath) as! SearchViewCell
        let item = extractDataForRepresentation(row: indexPath.row, section: indexPath.section)
        
        cell.cellTitle.text = item?.representTitle
        cell.cellDate.text = item?.representDate
        cell.cellDescription.text = item?.representDescription
        cell.cellImage.sd_setImageWithURL(NSURL(string: item?.representImage ?? ""), placeholderImage: UIImage(named: "defaultPhoto"))
        
        return cell
    }
    
    func extractDataForRepresentation(row row: Int, section: Int) -> SearchViewRepresentation? {
        if (scopeIndex == 0 && section == 0) || scopeIndex == 1 {
            return resultsMovies[row]
        }
        else if (scopeIndex == 0 && section == 1) || scopeIndex == 2 {
            return resultsTvShow[row]
        }
        else if (scopeIndex == 0 && section == 2) || scopeIndex == 3{
            return resultsPerson[row]
        }
        return nil
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionIndex = section
        if scopeIndex != 0 {
            sectionIndex = scopeIndex - 1
        }
        
        let title: String?
        switch sectionIndex {
        case 0: title = "Movies"
        case 1: title = "TV Show"
        case 2: title = "People"
        default: title = nil
        }
        return title
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (scopeIndex == 0 && section == 0) || scopeIndex == 1 {
            return resultsMovies.count
        }
        else if (scopeIndex == 0 && section == 1) || scopeIndex == 2 {
            return resultsTvShow.count
        }
        else if (scopeIndex == 0 && section == 2) || scopeIndex == 3 {
            return resultsPerson.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (scopeIndex == 0 && indexPath.section == 0) || scopeIndex == 1 {
            let navigationController = storyboard?.instantiateViewControllerWithIdentifier("MovieNavigationController") as! UINavigationController
            let controller = navigationController.topViewController as! MovieDetailsController
            let movie = resultsMovies[indexPath.row]
            controller.movieId = String(movie.movieId!)
            presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 && hasMoreItems {
            loadNextPage()
        }
    }
    
    //MARK: SearchBarDelegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        query = searchBar.text!
        scopeIndex = selectedScope
        clearResutls()
        executeQuery()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        query = searchBar.text!
        clearResutls()
        executeQuery()
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}






