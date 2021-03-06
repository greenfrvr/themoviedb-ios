//
//  File.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/24/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class ListDetailsActionAlert: DetailsActionAlert {
    
    var listId: String
    var title: String
    var shareUrl: String?
    weak var detailsManager: ListDetailsManager?
    
    init(presenter controller: UIViewController?, detailsManager: ListDetailsManager?, id: String, title: String, url: String?){
        self.listId = id
        self.title = title
        self.shareUrl = url
        self.detailsManager = detailsManager
        
        super.init(controller: controller)
    }
    
    override func alertData() -> (String, String) {
        return (title: NSLocalizedString("Pick an action", comment: ""), message: NSLocalizedString("What do you want to do with this list?", comment: ""))
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
        
        if #available(iOS 9.0, *) {
            actions += [ UIAlertAction(title: NSLocalizedString("Homescreen access", comment: ""), style: .Default, handler: { action in
                let shortcut = UIApplicationShortcutItem(type: "com.greenfrvr.moviedb.favorite-list", localizedTitle: self.title, localizedSubtitle: NSLocalizedString("Open compilation details", comment: ""), icon: UIApplicationShortcutIcon(templateImageName: "Star"), userInfo: ["listId" : String(self.listId)])
                UIApplication.sharedApplication().shortcutItems = [shortcut]
            }) ]
        }
        
        actions += [
        UIAlertAction(title: NSLocalizedString("Delete list", comment: ""), style: .Destructive, handler: { action in self.showDeleteAlert() })]
        
        return actions
    }
    
    private func showDeleteAlert() {
        let deleteController = UIAlertController(title: NSLocalizedString("List removing", comment: ""), message: NSLocalizedString("Are you sure you want to remove this list?", comment: ""), preferredStyle: .Alert)
        deleteController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Default, handler: nil))
        deleteController.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: .Destructive, handler:
            { action in self.detailsManager?.listDelete(listId: self.listId) }))
        self.controller?.presentViewController(deleteController, animated: true, completion: nil)
    }
}
