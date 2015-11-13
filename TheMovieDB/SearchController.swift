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
    let sectionTitles = [
        0 : "Movie",
        1 : "TV Show",
        2 : "People"
    ]
    var scopeIndex = 0
    var nextPage: Int?
    var hasMoreItems = false
    var query: String?
    var searchManager: SearchManager?
    var resultsMovies = [SearchMovieItem]()
    var resultsTvShow = [SearchTVItem]()
    var resultsPerson = [SearchPersonItem]()
    
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
            searchManager?.query(ScopeType(scopeIndex), query: queryString)
        }
    }
    
    func loadNextPage(){
        searchTableView.tableFooterView?.hidden = false
        if let page = nextPage {
            let scope = ScopeType(scopeIndex)
            searchManager?.query(scope, query: query!, page: page)
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
        cell.cellDate.text = item?.representDate?.stringByReplacingOccurrencesOfString("-", withString: "/")
        cell.cellDescription.text = item?.representDescription
        cell.cellImage.sd_setImageWithURL(NSURL(string: item?.representImage ?? ""), placeholderImage: UIImage(named: "defaultPhoto"))
        
        return cell
    }
    
    func extractDataForRepresentation(row row: Int, section: Int) -> SearchViewRepresentation? {
        switch ScopeType(scopeIndex, section) {
        case .MOVIE: return resultsMovies[row]
        case .TV: return resultsTvShow[row]
        case .PEOPLE: return resultsPerson[row]
        case .ALL: return nil
        }
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
            MovieDetailsController.performMovieController(self, id: String(movie.movieId!))
        case .TV: print("TV Show clicked")
        case .PEOPLE: print("Person clicked")
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
    
    enum ScopeType {
        case ALL, MOVIE, TV, PEOPLE
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






