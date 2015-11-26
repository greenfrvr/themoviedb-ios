//
//  SearchController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/3/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import SDWebImage

class SearchController: UIViewController, UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, SearchDelegate  {
    
    let sectionTitles = [
        0 : NSLocalizedString("Movie", comment: ""),
        1 : NSLocalizedString("TV Show", comment: ""),
        2 : NSLocalizedString("People", comment: "")
    ]
    var scopeIndex = 0
    var nextPage: Int?
    var hasMoreItems = false
    var queryString: String?
    var searchManager: SearchManager?
    var resultsMovies = [SearchMovieItem]()
    var resultsTvShow = [SearchTVItem]()
    var resultsPerson = [SearchPersonItem]()
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pagintationView: UIView!
    @IBOutlet weak var pagintationIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pagintationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        
        searchManager = SearchManager(delegate: self)
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchTableView.tableFooterView?.hidden = true
        
        restoreLastSearch()
    }
    
    override func viewWillAppear(animated: Bool) {
        let app = UIApplication.sharedApplication()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveSearchParams", name: UIApplicationWillResignActiveNotification, object: app)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func restoreLastSearch() {
        guard let (query, scope) = FileCache.restoreLastQueryParams() where !query.isEmpty else {
            return
        }
        
        (queryString, scopeIndex) = (query, scope)
        searchBar.text = queryString
        searchBar.selectedScopeButtonIndex = scopeIndex
        clearResutls()
        executeQuery()
    }
    
    func saveSearchParams() {
        FileCache.saveLastQueryParams(queryString, scopeIndex)
    }
    
    func receiveResults(@autoclosure persistData: () -> Void, pages: PaginationLoading) {
        persistData()
        
        hasMoreItems = scopeIndex > 0 && pages.hasMorePages
        nextPage = pages.nextPage
        
        loadingIndicator.stopAnimating()
        searchTableView.reloadData()
        searchTableView.tableFooterView?.hidden = true
    }
    
    func executeQuery() {
        if let query = queryString where !query.isEmpty {
            loadingIndicator.startAnimating()
            searchManager?.query(ScopeType(scopeIndex), query: query)
        }
    }
    
    func loadNextPage(){
        searchTableView.tableFooterView?.hidden = false
        if let page = nextPage, query = queryString {
            let scope = ScopeType(scopeIndex)
            searchManager?.query(scope, query: query, page: page)
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
    
    func searchMovieResuts(searchResults: SearchMovieResults) {
        print("\(searchResults.results!.count) movies loaded out of \(searchResults.totalItems!)")
        receiveResults(self.resultsMovies += searchResults.results!, pages: searchResults)
    }
    
    func searchTvShowResuts(searchResults: SearchTVResults) {
        print("\(searchResults.results!.count) tv shows loaded out of \(searchResults.totalItems!)")
        receiveResults(self.resultsTvShow += searchResults.results!, pages: searchResults)
    }
    
    func searchPersonResuts(searchResults: SearchPersonResults) {
        print("\(searchResults.results!.count) psersons loaded out of \(searchResults.totalItems!)")
        receiveResults(self.resultsPerson += searchResults.results!, pages: searchResults)
    }
    
    func searchNoMoviesFound(error: NSError) {
        loadingIndicator.stopAnimating()
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func searchNoTvShowFound(error: NSError) {
        loadingIndicator.stopAnimating()
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func searchNoPersonFound(error: NSError) {
        loadingIndicator.stopAnimating()
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func extractDataForRepresentation(row row: Int, section: Int) -> SearchViewRepresentation? {
        switch ScopeType(scopeIndex, section) {
        case .MOVIE: return resultsMovies[row]
        case .TV: return resultsTvShow[row]
        case .PEOPLE: return resultsPerson[row]
        case .ALL: return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return scopeIndex == 0 ? 3 : 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SearchViewCell.identifier, forIndexPath: indexPath) as! SearchViewCell
        let item = extractDataForRepresentation(row: indexPath.row, section: indexPath.section)
        
        cell.cellTitle.text = item?.representTitle
        cell.cellDate.text = item?.representDate?.stringByReplacingOccurrencesOfString("-", withString: "/")
        cell.cellDescription.text = item?.representDescription
        cell.cellImage.sd_setImageWithURL(NSURL(string: item?.representImage ?? ""), placeholderImage: UIImage.placeholder())
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionIndex = section
        if scopeIndex != 0 {
            sectionIndex = scopeIndex - 1
        }
        
        return sectionTitles[sectionIndex]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch ScopeType(scopeIndex, section) {
        case .MOVIE: return resultsMovies.count
        case .TV: return resultsTvShow.count
        case .PEOPLE: return resultsPerson.count
        case .ALL: return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch ScopeType(scopeIndex, indexPath.section) {
        case .MOVIE:
            let movie = resultsMovies[indexPath.row]
            MovieDetailsController.presentControllerWithNavigation(self, id: String(movie.movieId!))
        case .TV:
            let tvshow = resultsTvShow[indexPath.row]
            TvShowDetailsController.presentControllerWithNavigation(self, id: String(tvshow.showId!))
        case .PEOPLE:
            let person = resultsPerson[indexPath.row]
            PersonDetailsController.presentControllerWithNavigation(self, id: String(person.personId!))
        case .ALL: return
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
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        queryString = searchBar.text!
        scopeIndex = selectedScope
        clearResutls()
        executeQuery()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        queryString = searchBar.text!
        clearResutls()
        executeQuery()
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if viewController == self {
            print("You're back to search controller")
        } else {
            print("You're leaving search controller")
        }
    }
    
    enum ScopeType: Int {
        case ALL = 0, MOVIE, TV, PEOPLE
        init(_ scope: Int, _ section: Int = -1){
            if (scope == 0 && section == 0) || scope == 1 {
                self = .MOVIE
            }
            else if (scope == 0 && section == 1) || scope == 2 {
                self = .TV
            }
            else if(scope == 0 && section == 2) || scope == 3 {
                self = .PEOPLE
            } else {
                self = .ALL
            }
        }
        
        func scopeRequestUrl() -> String {
            switch self {
            case .MOVIE: return ApiEndpoints.searchMovie
            case .TV: return ApiEndpoints.searchTvShow
            case .PEOPLE: return ApiEndpoints.searchPerson
            case .ALL: return ""
            }
        }
    }
}






