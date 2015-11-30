//
//  AccountController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import SDWebImage

class AccountController: UIViewController, UITabBarControllerDelegate, AccountDelegate {
    
    var segmentsLoader: UserSegmentsDelegate?
    var accountManager: AccountManager?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentsChooser: UISegmentedControl!
    @IBOutlet weak var typeSwitcher: UISwitch!
    
    @IBAction func usersSetChanged(sender: UISegmentedControl, forEvent event: UIEvent) {
        loadData()
    }
    
    @IBAction func typeSwticher(sender: UISwitch) {
        let isMovie = sender.on
        typeLabel.text = isMovie ? "Movie" : "TV"
        AccountManager.isMovie = isMovie
        
        loadData()
    }
    
    override func viewDidLoad() {
        tabBarController?.delegate = self
        
        if let session = Cache.restoreSession() {
            accountManager = AccountManager(sessionId: session, accountDelegate: self)
            accountManager?.loadAccountData()
        }
    }
    
    func userLoadedSuccessfully(account: Account) {
        if loadingIndicator.isAnimating() { loadingIndicator.stopAnimating() }
        
        usernameLabel.text = account.username
        fullNameLabel.text = account.fullName
        avatarImageView.sd_setImageWithURL(NSURL(string: account.gravatar), placeholderImage: UIImage.placeholder())
    }
    
    func userLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func loadData() {
        let index = segmentsChooser.selectedSegmentIndex
        guard let segment = AccountSegmentType(rawValue: index) else { return }
        
        segmentsLoader?.loadSelectedSegment(segment)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UserListsSegue" {
           segmentsLoader = segue.destinationViewController as? UserSegmentsDelegate
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if viewController == self {
            loadData()
        }
    }
}

enum AccountSegmentType: Int {
    case List = 0, Favorite, Rated, Watchlist
    
    var requestUrl: String {
        switch self {
        case .Favorite: return AccountManager.urlFavoriteMovies
        case .Rated: return AccountManager.urlRatedMovies
        case .Watchlist: return AccountManager.urlWatchlistMovies
        case .List: return AccountManager.urlCompilations
        }
    }
}

protocol UserSegmentsDelegate {
    func loadSelectedSegment(segment: AccountSegmentType)
}


