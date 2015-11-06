//
//  ListActionSheet.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/6/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class ListActionSheet: UIAlertController {
    
    init() {
        super.init()
    }
    
    init(shareUrl: String){
        self.init()
        
        title = "Pick an action"
        message =
        super.init(title: , message: "What do you want to do with your list?", preferredStyle: .ActionSheet)
        
        addAction(UIAlertAction(title: "Share", style: .Default, handler: { action in
            let shareController = UIActivityViewController.init(activityItems: [shareUrl], applicationActivities: nil)
            self.presentViewController(shareController, animated: true, completion: nil)
        }))
        
        addAction(UIAlertAction(title: "Delete list", style: .Destructive, handler: { action in
            let deleteController = UIAlertController(title: "List removing", message: "Are you sure you want to remove this list. (Can't be undone)", preferredStyle: .Alert)
            deleteController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            deleteController.addAction(UIAlertAction(title: "Remove", style: .Destructive, handler:
                { action in self.detailsManager?.listDelete(listId: self.argList.listId!) }))
            
            self.presentViewController(deleteController, animated: true, completion: nil)
        }))
        
        addAction(UIAlertAction(title: "Back", style: .Cancel, handler: nil))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
