//
//  PersonDetailsActionAlert.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/18/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class PersonDetailsActionAlert: DetailsActionAlert {
    
    var shareUrl: String?
    var homepage: String?
    
    init(presenter controller: UIViewController?, homepage: String?, url: String?) {
        self.homepage = homepage
        self.shareUrl = url
        
        super.init(controller: controller)
    }
    
    override func alertData() -> (String, String) {
        return (title: "Pick an action", message: "What do you want to do with this person?")
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
        
        if let home = homepage, url = NSURL(string: home) {
            actions += [UIAlertAction(title: "Open home page", style: .Default, handler: { action in UIApplication.sharedApplication().openURL(url) })]
        }
        
        return actions
    }
    
}
