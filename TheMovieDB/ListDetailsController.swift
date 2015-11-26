//
//  ListInfoController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/3/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class ListDetailsController: UIViewController, ListDetailsDelegate, DetailsNavigation {
    
    static var controllerId = "ListDetails"
    static var navigationId = "CollectionNavigationController"
    
    var id: String?
    var detailsManager: ListDetailsManager?
    var collectionDelegate: ListItemsCollectionDelegate?
    var shareUrl: String { return String(format: ApiEndpoints.listShare, self.id!) }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionContainer: UIView!
    
    @IBAction func backButtonClick(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func actionButtonClick(sender: UIBarButtonItem) {
        let alert = ListDetailsActionAlert(presenter: self, detailsManager: detailsManager, id: id!, url: shareUrl)
        alert.present()
    }
    
    override func viewDidLoad() {
        if let session = Cache.restoreSession() {
            detailsManager = ListDetailsManager(sessionId: session, detailsDelegate: self)
            detailsManager?.listDetails(listId: id!)
        }
    }
        
    func listDetailsLoadedSuccessfully(details: ListDetails) {
        loadingIndicator.stopAnimating()
        titleLabel.text = details.name
        authorLabel.text = "by \(details.createdBy!)"
        descriptionLabel.text = details.description
        favoriteCountLabel.text = String(details.favoriteCount!)
        
        collectionDelegate?.collectionFetched(details.items ?? [])
    }
    
    func listRemovedSuccessfully() {
        performSegueWithIdentifier("ItemRemoved", sender: self)
    }
    
    func listDetailsLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }

    func listRemovingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ListItemsCollectionSegue" {
            collectionDelegate = segue.destinationViewController as? ListItemsCollectionDelegate
        }
    }
}
