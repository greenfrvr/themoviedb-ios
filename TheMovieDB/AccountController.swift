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
    var accountManager: AccountManager?
    
    //MARK: Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    
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
        usernameLabel.text = account.username
        fullNameLabel.text = account.fullName
        print("Gravatar URL: \(account.gravatar)")
        avatarImageView.sd_setImageWithURL(NSURL(string: account.gravatar), placeholderImage: UIImage.init(named: "defaultPhoto"))
     }
    
    func userLoadingFailed(error: NSError) {
        print(error)
    }
    
}