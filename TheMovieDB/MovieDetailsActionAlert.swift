//
//  MovieDetailsActionAlert.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/16/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class MovieDetailsActionAlert: DetailsActionAlert {
    
    var imdbPage: String?
    var shareUrl: String?
    var id: String?
    
    init(presenter controller: UIViewController?, imdb: String?, url: String?){
        self.imdbPage = imdb
        self.shareUrl = url
        
        super.init(controller: controller)
    }
    
    override internal func alertData() -> (String, String) {
        return (title: NSLocalizedString("Pick an action", comment: ""), message:NSLocalizedString("What do you want to do with this movie?", comment: ""))
    }
    
    override func defineActions() -> [UIAlertAction] {
        var actions = [UIAlertAction]()
        
        if let url = shareUrl {
            actions += [
                UIAlertAction(title: NSLocalizedString("Share", comment: ""), style: .Default,
                    handler: { action in
                        let shareController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                        self.controller?.presentViewController(shareController, animated: true, completion: nil)
                })
            ]
        }
        
        if let imdb = imdbPage, url = NSURL(string: imdb) {
            actions += [UIAlertAction(title: NSLocalizedString("Open IMDB page", comment: ""), style: .Default, handler: { action in UIApplication.sharedApplication().openURL(url) })]
        }
        
        actions += [UIAlertAction(title: NSLocalizedString("Add to my list", comment: ""), style: .Default, handler: { action in
            let listPickerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ListPickerController") as! ListPickerController
            listPickerController.itemId = self.id
            listPickerController.itemType = "movie"
            self.controller?.presentViewController(listPickerController, animated: true, completion: nil)
        })]
        
        return actions
    }
}