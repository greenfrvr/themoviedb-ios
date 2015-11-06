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
    var query: String?
    var searchManager: SearchManager?
    var resultsMovies = [SearchMovieItem]()
    var resultsTvShow = [SearchTVItem]()
    var resultsPerson = [SearchPersonItem]()
    
    //MARK: Outlets
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchManager = SearchManager(delegate: self)
        searchTableView.dataSource = self
        searchTableView.delegate = self
    }
    
    //MARK: SearchDelegate
    func searchMovieResuts(searchResults: SearchMovieResults) {
        resultsMovies = searchResults.results!
        print("\(resultsMovies.count) movies loaded")
        loadingIndicator.stopAnimating()
        searchTableView.reloadData()
    }
    
    func searchTvShowResuts(searchResults: SearchTVResults) {
        resultsTvShow = searchResults.results!
        print("\(resultsTvShow.count) tv shows loaded")
        loadingIndicator.stopAnimating()
        searchTableView.reloadData()
    }
    
    func searchPersonResuts(searchResults: SearchPersonResults) {
        resultsPerson = searchResults.results!
        print("\(resultsPerson.count) persons loaded")
        loadingIndicator.stopAnimating()
        searchTableView.reloadData()
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
        let cellIdentifier = "SearchCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SearchViewCell
        let section = indexPath.section
        var item: SearchViewRepresentation? = nil
        
        if (scopeIndex == 0 && section == 0) || scopeIndex == 1 {
            item = resultsMovies[indexPath.row]
        }
        else if (scopeIndex == 0 && section == 1) || scopeIndex == 2 {
            item = resultsTvShow[indexPath.row]
        }
        else if (scopeIndex == 0 && section == 2) || scopeIndex == 3{
            item = resultsPerson[indexPath.row]
        }
        
        cell.cellTitle.text = item?.representTitle
        cell.cellDate.text = item?.representDate
        cell.cellDescription.text = item?.representDescription
        cell.cellImage.sd_setImageWithURL(NSURL(string: item?.representImage ?? ""), placeholderImage: UIImage(named: "defaultPhoto"))
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionIndex = section
        if scopeIndex != 0 {
            sectionIndex = scopeIndex - 1
        }
        
        let title: String?
        switch sectionIndex {
        case 0: title = "Movies"
        case 1: title = "Series"
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
    
    //MARK: SearchBarDelegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        query = searchBar.text!
        scopeIndex = selectedScope
        clearResutls()
        executeQuery()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        query = searchBar.text!
        executeQuery()
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    //MARK: Data
    func clearResutls(){
        resultsMovies.removeAll()
        resultsTvShow.removeAll()
        resultsPerson.removeAll()
        searchTableView.reloadData()
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
    
}
