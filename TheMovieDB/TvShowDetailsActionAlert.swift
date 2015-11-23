//
//  TvShowDetailsActionAlert.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/16/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class TvShowDetailsActionAlert: DetailsActionAlert {
    
    var showHomepage: String?
    var shareUrl: String?
    
    init(presenter controller: UIViewController?, homepage: String?, url: String?){
        self.showHomepage = homepage
        self.shareUrl = url
        
        super.init(controller: controller)
    }
    
    override func alertData() -> (String, String) {
        return (title: NSLocalizedString("Pick an action", comment: ""), message: NSLocalizedString("What do you want to do with this show?", comment: ""))
    }
    
    override func defineActions() -> [UIAlertAction] {
        var actions = [UIAlertAction]()
        
        if let url = shareUrl {
            actions += [
                UIAlertAction(title: "Share", style: .Default,
                    handler: { action in
                        let shareController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                        self.controller?.presentViewController(shareController, animated: true, completion: nil)
                })
            ]
        }
        
        if let homepage = showHomepage, url = NSURL(string: homepage) {
            actions += [UIAlertAction(title: "Open home page", style: .Default, handler: { action in UIApplication.sharedApplication().openURL(url) })]
        }
        
        actions += [UIAlertAction(title: "Add to my list", style: .Default, handler: { action in print("add to my list")})]
        
        return actions
    }
}
