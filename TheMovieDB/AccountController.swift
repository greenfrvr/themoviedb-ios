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
    var segmentsLoader: UserSegmentsDelegate?
    var accountManager: AccountManager?
    
    //MARK: Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    //MARK: Actions
    @IBAction func usersSetChanged(sender: UISegmentedControl, forEvent event: UIEvent) {
        let type = AccountSegmentType(rawValue: sender.selectedSegmentIndex)
        if let segmentType = type {
            segmentsLoader?.loadSelectedSegment(segmentType)
        }
    }
    
    //MARK: Controller lifecycle
    override func viewDidLoad() {
        if let session = Cache.restoreSession() {
            accountManager = AccountManager(sessionId: session, accountDelegate: self)
            accountManager?.loadAccountData()
        }
    }
    
    //MARK: AccountDelegate
    func userLoadedSuccessfully(account: Account) {
        if loadingIndicator.isAnimating() {
            loadingIndicator.stopAnimating()
        }
        
        usernameLabel.text = account.username
        fullNameLabel.text = account.fullName
        avatarImageView.sd_setImageWithURL(NSURL(string: account.gravatar), placeholderImage: UIImage.placeholder())
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

enum AccountSegmentType: Int {
    case List = 0, Favorite, Rated, Watchlist
}

protocol UserSegmentsDelegate {
    func loadSelectedSegment(segment: AccountSegmentType)
}


