//
//  ListInfoController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/3/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class ListDetailsController: UIViewController, ListDetailsDelegate {
    
    //MARK: Properties
    var argListId: String?
    var detailsManager: ListDetailsManager?
    var collectionDelegate: ListItemsCollectionDelegate?
    var shareUrl: String {
        return ApiEndpoints.listShare(self.argListId!)
    }
    
    //MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionContainer: UIView!
    
    //MARK: Actions
    @IBAction func backButtonClick(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func actionButtonClick(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Pick an action", message: "What do you want to do with your list?", preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Share", style: .Default, handler: { action in
            let shareController = UIActivityViewController(activityItems: [self.shareUrl], applicationActivities: nil)
            self.presentViewController(shareController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Delete list", style: .Destructive, handler: { action in
            let deleteController = UIAlertController(title: "List removing", message: "Are you sure you want to remove this list. (Can't be undone)", preferredStyle: .Alert)
            deleteController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            deleteController.addAction(UIAlertAction(title: "Remove", style: .Destructive, handler:
                { action in self.detailsManager?.listDelete(listId: self.argListId!) }))
            self.presentViewController(deleteController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Back", style: .Cancel, handler: nil))
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: Controller lifecycle
    override func viewDidLoad() {
        let session = SessionCache.restoreSession()!
        detailsManager = ListDetailsManager(sessionId: session.sessionToken!, detailsDelegate: self)
        detailsManager?.listDetails(listId: argListId!)
    }
        
    override func viewDidAppear(animated: Bool) {
        if let list = argListId {
            print("List loaded: \(list)")
        }
    }
    
    //MARK: ListDetailsDelegate
    func listDetailsLoadedSuccessfully(details: ListDetails) {
        loadingIndicator.stopAnimating()
        titleLabel.text = details.name
        authorLabel.text = "by \(details.createdBy!)"
        descriptionLabel.text = details.description
        favoriteCountLabel.text = String(details.favoriteCount!)
        
        collectionDelegate?.collectionFetched(details.items ?? [])
    }
    
    func listDetailsLoadingFailed(error: NSError) {
        print(error)
    }
    
    func listRemovedSuccessfully() {
        performSegueWithIdentifier("ItemRemoved", sender: self)
    }
    
    func listRemovingFailed(error: NSError) {
        print(error)
    }
    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ListItemsCollectionSegue" {
            collectionDelegate = segue.destinationViewController as? ListItemsCollectionDelegate
        }
    }
}
