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
    var shareUrl: String { return String(format: ApiEndpoints.listShare, self.argListId!) }
    
    static func performListController(performer: UIViewController, id: String?){
        let navigationController = performer.storyboard?.instantiateViewControllerWithIdentifier("CollectionNavigationController") as! UINavigationController
        let controller = navigationController.topViewController as! ListDetailsController
        controller.argListId = id
        performer.presentViewController(navigationController, animated: true, completion: nil)
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
        let alert = ListDetailsActionAlert(presenter: self, detailsManager: detailsManager, id: argListId!, url: shareUrl)
        alert.present()
    }
    
    //MARK: Controller lifecycle
    override func viewDidLoad() {
        let session = SessionCache.restoreSession()!
        detailsManager = ListDetailsManager(sessionId: session.sessionToken!, detailsDelegate: self)
        detailsManager?.listDetails(listId: argListId!)
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
