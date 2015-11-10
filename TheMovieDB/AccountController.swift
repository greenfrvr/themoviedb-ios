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
    
    //MARK: Properties
    var session: Session!
    var segmentsLoader: UserSegmentsDelegate?
    var accountManager: AccountManager?
    
    //MARK: Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    //MARK: Actions
    @IBAction func usersSetChanged(sender: UISegmentedControl, forEvent event: UIEvent) {
        let type = AccountManager.SegmentType(rawValue: sender.selectedSegmentIndex)
        if let segmentType = type {
            switch segmentType {
            case .List: segmentsLoader?.loadLists()
            case .Favorite: segmentsLoader?.loadFavorite()
            case .Rated: segmentsLoader?.loadRated()
            case .Watchlist: segmentsLoader?.loadWatchlist()
            }
        }
    }
    
    //MARK: Controller lifecycle
    override func viewDidLoad() {
        session = SessionCache.restoreSession()!
        accountManager = AccountManager(sessionId: session.sessionToken!, accountDelegate: self)
        accountManager?.loadAccountData()
    }
    
    override func viewDidAppear(animated: Bool) {
        avatarImageView.layer.cornerRadius = 20
    }
    
    //MARK: AccountDelegate
    func userLoadedSuccessfully(account: Account) {
        if loadingIndicator.isAnimating() {
            loadingIndicator.stopAnimating()
        }
        
        usernameLabel.text = account.username
        fullNameLabel.text = account.fullName
        avatarImageView.sd_setImageWithURL(NSURL(string: account.gravatar), placeholderImage: UIImage(named: "defaultPhoto"))
    }
    
    func userLoadingFailed(error: NSError) {
        print(error)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UserListsSegue" {
           segmentsLoader = segue.destinationViewController as? UserSegmentsDelegate
        }
    }
}

protocol UserSegmentsDelegate {
    func loadLists()
    func loadFavorite()
    func loadRated()
    func loadWatchlist()
}


