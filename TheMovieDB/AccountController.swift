//
//  AccountController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import SDWebImage

class AccountController: UIViewController, AccountDelegate {
    
    var segmentsLoader: UserSegmentsDelegate?
    var accountManager: AccountManager?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBAction func usersSetChanged(sender: UISegmentedControl, forEvent event: UIEvent) {
        let type = AccountSegmentType(rawValue: sender.selectedSegmentIndex)
        if let segmentType = type {
            segmentsLoader?.loadSelectedSegment(segmentType)
        }
    }
    
    override func viewDidLoad() {
        if let session = Cache.restoreSession() {
            accountManager = AccountManager(sessionId: session, accountDelegate: self)
            accountManager?.loadAccountData()
        }
    }
    
    func userLoadedSuccessfully(account: Account) {
        if loadingIndicator.isAnimating() {
            loadingIndicator.stopAnimating()
        }
        
        usernameLabel.text = account.username
        fullNameLabel.text = account.fullName
        avatarImageView.sd_setImageWithURL(NSURL(string: account.gravatar), placeholderImage: UIImage.placeholder())
    }
    
    func userLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UserListsSegue" {
           segmentsLoader = segue.destinationViewController as? UserSegmentsDelegate
        }
    }
}

enum AccountSegmentType: Int {
    case List = 0, Favorite, Rated, Watchlist
    
    var requestUrl: String {
        switch self {
        case .Favorite: return ApiEndpoints.accountFavoriteMovies
        case .Rated: return ApiEndpoints.accountRatedMovies
        case .Watchlist: return ApiEndpoints.accountWatchlistMovies
        case .List: return ApiEndpoints.accountLists
        }
    }
}

protocol UserSegmentsDelegate {
    func loadSelectedSegment(segment: AccountSegmentType)
}


