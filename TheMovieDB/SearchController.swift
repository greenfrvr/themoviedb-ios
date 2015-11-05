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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchManager = SearchManager(delegate: self)
        searchTableView.dataSource = self
        searchTableView.delegate = self
    }
    
    //MARK: SearchDelegate
    func searchMovieResuts(searchResults: SearchMovieResults) {
        resultsMovies = searchResults.results!
        searchTableView.reloadData()
    }
    
    func searchTvShowResuts(searchResults: SearchTVResults) {
        resultsTvShow = searchResults.results!
        searchTableView.reloadData()
    }
    
    func searchPersonResuts(searchResults: SearchPersonResults) {
        resultsPerson = searchResults.results!
        searchTableView.reloadData()
    }
    
    func searchNoMoviesFound(error: NSError) {
        print(error)
    }
    
    func searchNoTvShowFound(error: NSError) {
        print(error)
    }
    
    func searchNoPersonFound(error: NSError) {
        print(error)
    }
    
    //MARK: TableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return scopeIndex == 0 ? 3 : 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SearchViewCell
        var itemTitle: String? = ""
        var itemImagePath: String? = ""
        var itemDate: String? = ""
        var itemDescription: String? = ""
        
        let section = indexPath.section
        
        if (scopeIndex == 0 && section == 0) || scopeIndex == 1 {
            itemTitle = resultsMovies[indexPath.row].title
            itemDate = resultsMovies[indexPath.row].releaseDate
            itemDescription = resultsMovies[indexPath.row].overview
            itemImagePath = resultsMovies[indexPath.row].posterPath
        }
        else if (scopeIndex == 0 && section == 1) || scopeIndex == 2 {
            itemTitle = resultsTvShow[indexPath.row].name
            itemDate = resultsTvShow[indexPath.row].firstAirDate
            itemDescription = resultsTvShow[indexPath.row].overview
            itemImagePath = resultsTvShow[indexPath.row].posterPath
        }
        else if (scopeIndex == 0 && section == 2) || scopeIndex == 3{
            itemTitle = resultsPerson[indexPath.row].name
            itemImagePath = resultsPerson[indexPath.row].profilePath
        }
        
        cell.cellTitle.text = itemTitle
        cell.cellDate.text = itemDate
        cell.cellDescription.text = itemDescription
        cell.cellImage.sd_setImageWithURL(NSURL(string: ApiEndpoints.poster(3, itemImagePath ?? "")), placeholderImage: UIImage(named: "defaultPhoto"))
        
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
        if scopeIndex == 1 {
            return resultsMovies.count
        }
        else if scopeIndex == 2 {
            return resultsTvShow.count
        }
        else if scopeIndex == 3 {
            return resultsPerson.count
        }
        else {
            switch section {
            case 0:
                print("Movie section contains \(resultsMovies.count) items")
                return resultsMovies.count
            case 1:
                print("Series section")
                return resultsTvShow.count
            case 2:
                print("People section")
                return resultsPerson.count
            default: return 0
            }
        }
    }
    
    //MARK: SearchBarDelegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("Selected scope: \(selectedScope)")
        scopeIndex = selectedScope
        searchTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("Search initiated with query: \(searchBar.text!)")
        query = searchBar.text!
        executeQuery()
        searchBar.resignFirstResponder()
    }
    
    func executeQuery() {
        if let queryString = query {
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
