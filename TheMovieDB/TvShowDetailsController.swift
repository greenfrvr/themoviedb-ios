//
//  TvDetailsController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/13/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class TvShowDetailsController: UIViewController, TvShowDetailsDelegate, TvShowStateChangeDelegate, UIBackdropsDelegat {

    //MARK: Properties
    var tvShowId: String?
    var tvShowHomepage: String?
    var tvShowState: AccountState?
    var detailsManager: TvShowDetailsManager?
    var backdropImages = [ImageInfo]()
    var shareUrl: String {
        return "\(ApiEndpoints.tvShare)/\(tvShowId!)"
    }
    
    static func performTvController(performer: UIViewController, id: String){
        let navigationController = performer.storyboard?.instantiateViewControllerWithIdentifier("TvNavigationController") as! UINavigationController
        let controller = navigationController.topViewController as! TvShowDetailsController
        controller.tvShowId = id
        performer.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    //MARK: Outlets
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var averageVoteLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var navFavoriteButton: UIBarButtonItem!
    @IBOutlet weak var watchlistButton: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabelWithPadding!
    @IBOutlet weak var backdropsLabel: UILabelWithPadding!
    @IBOutlet weak var imagesScrollView: UIBackdropsHorizontalView!
    
    //MARK: Actions
    
    @IBAction func unwindTvShowDetails(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addToFavorite(sender: UIBarButtonItem) {
        if let show = tvShowState {
            detailsManager?.changeFavoriteState(tvShowId!, state: show.favorite ?? false)
        }
    }
    
    @IBAction func addToWatchlist(sender: AnyObject) {
        if let show = tvShowState {
            detailsManager?.changeWatchlistState(tvShowId!, state: show.watchlist ?? false)
        }
    }
    
    @IBAction func actionButtonClicked(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Pick an action", message: "What do you want to do with this show?", preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Share", style: .Default, handler: { action in
            let shareController = UIActivityViewController(activityItems: [self.shareUrl], applicationActivities: nil)
            self.presentViewController(shareController, animated: true, completion: nil)
            
        }))
        
        if let homepage = tvShowHomepage {
            actionSheet.addAction(UIAlertAction(title: "Open home page", style: .Default, handler: { action in
                let openUrl = NSURL(string: homepage)
                if let url = openUrl{
                    UIApplication.sharedApplication().openURL(url)
                }
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Add to my list", style: .Default, handler: { action in
            print("add to my list")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Back", style: .Cancel, handler: nil))
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        let session = SessionCache.restoreSession()!
        detailsManager = TvShowDetailsManager(sessionId: session.sessionToken!, detailsDelegate: self, stateDelegate: self)
        
        if let id = tvShowId {
            print("LOADING ID \(id)")
            detailsManager?.loadDetails(id)
            detailsManager?.loadState(id)
            detailsManager?.loadImages(id)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        overviewLabel.numberOfLines = 0
        overviewLabel.sizeToFit()
        
        descriptionLabel.padding = 10
        backdropsLabel.padding = 10
        
        watchlistButton.tintColor = UIColor.rgb(6, 117, 255)
        
        imagesScrollView.backdropsDelegate = self

    }
    
    //MARK: TvShowDetailsDelegate
    func tvshowDetailsLoadedSuccessfully(details: TvShowInfo) {
        print("TvShow details loaded: \(details.tvShowId)")
        tvShowHomepage = details.homepage
        posterImageView.sd_setImageWithURL(NSURL(string: ApiEndpoints.poster(3, details.posterPath ?? "")), placeholderImage: UIImage(named: "defaultPhoto"))
        titleLabel.text = details.name
        averageVoteLabel.text = String(details.voteAverage ?? 0.0)
        voteCountLabel.text = "(\(details.voteCount ?? 0))"
//        runtimeLabel.text = "\(details.runtime ?? 0) min"
        overviewLabel.text = details.overview
    }
    
    func tvshowImagesLoadedSuccessully(images: ImageInfoList) {
        if let backdrops = images.backdrops {
            backdropImages = backdrops
            imagesScrollView.backdropsDisplay(backdrops)
        }
    }
    
    func tvshowStateLoadedSuccessfully(state: AccountState) {
        tvShowState = state
        updateStateIndicators()
    }
    
    func tvshowDetailsLoadingFailed(error: NSError) {
        print(error)
    }
    
    func tvshowImagesLoadingFailed(error: NSError) {
        print(error)
    }
    
    func tvshowStateLoadingFailed(error: NSError) {
        print(error)
    }
    
    //MARK: TvShowStateChangeDelegate
    func tvshowFavoriteStateChangedSuccessfully(isFavorite: Bool) {
        tvShowState?.favorite = isFavorite
        updateStateIndicators()
        movieStateChangeNotifier("Favorite list", message: "This show was \(isFavorite ? "added to" : "removed from") your favorites list")
    }
    
    func tvshowWatchlistStateChangedSuccessfully(isInWatchlist: Bool) {
        tvShowState?.watchlist = isInWatchlist
        updateStateIndicators()
        movieStateChangeNotifier("Watchlist", message: "This show was \(isInWatchlist ? "added to" : "removed from") your watchlist")
    }
    
    func tvshowFavoriteStateChangesFailed(error: NSError) {
        print(error)
    }
    
    func tvshowWatchlistStateChangesFailed(error: NSError) {
        print(error)
    }
    
    //MARK: BackdropsDelegate
    func backdropTapped(image: UIImage?, imageUrl: String) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("BackdropPages") as! BackdropsController
        controller.content = backdropImages
        controller.initialUrl = imageUrl
        presentViewController(controller, animated: true, completion: nil)
    }
    
    //MARK: UI
    func movieStateChangeNotifier(title: String, message: String){
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil)
        alert.show()
        alert.performSelector(Selector("dismiss"), withObject: alert, afterDelay: 1)
        
        func dismiss() {
            alert.dismissWithClickedButtonIndex(-1, animated: true)
        }
    }
    
    func updateStateIndicators(){
        navFavoriteButton.image = UIImage(named: tvShowState?.favorite ?? false ? "Like Filled" : "Hearts")
        watchlistButton.image = UIImage(named: tvShowState?.watchlist ?? false ? "Movie Filled" : "Movie")
    }

}
