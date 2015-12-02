//
//  TvDetailsController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/13/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class TvShowDetailsController: UIViewController, TvShowDetailsDelegate, TvShowStateChangeDelegate, UIBackdropsDelegat, UICastDelegate, DetailsNavigation {
    
    static var controllerId = "TvDetails"
    static var navigationId = "TvNavigationController"
    
    var id: String?
    var homepage: String?
    var showState: AccountState?
    var detailsManager: TvShowDetailsManager?
    var backdropImages = [ImageInfo]()
    var shareUrl: String { return TvShowDetailsManager.urlShare.withArgs(id!) }
    lazy var castView = UICastHorizontalView()
    
    @IBOutlet var screenPanRecognizer: UIScreenEdgePanGestureRecognizer!
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var averageVoteLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var numberOfSeasonsLabel: UILabel!
    @IBOutlet weak var numberOfEpisodesLabel: UILabel!
    @IBOutlet weak var lastAirLabel: UILabel!
    
    @IBOutlet weak var navFavoriteButton: UIBarButtonItem!
    @IBOutlet weak var watchlistButton: UIImageView!
    @IBOutlet weak var watchlistLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabelWithPadding!
    @IBOutlet weak var backdropsLabel: UILabelWithPadding!
    @IBOutlet weak var castLabel: UILabelWithPadding!
    
    @IBOutlet weak var detailsScrollContainer: UIScrollView!
    @IBOutlet weak var imagesScrollView: UIBackdropsHorizontalView! {
        didSet {
            imagesScrollView.panGestureRecognizer.requireGestureRecognizerToFail(screenPanRecognizer)
        }
    }
    @IBOutlet weak var castScrollView: UIScrollView! {
        didSet {
            castView.scrollView = castScrollView
            castScrollView.panGestureRecognizer.requireGestureRecognizerToFail(screenPanRecognizer)
        }
    }
    
    @IBAction func unwindTvShowDetails(sender: UIBarButtonItem) {
        if navigationController?.viewControllers.count == 1 {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func addToFavorite(sender: UIBarButtonItem) {
        if let show = showState {
            detailsManager?.changeFavoriteState(id!, state: show.favorite ?? false)
        }
    }
    
    @IBAction func addToWatchlist(sender: AnyObject) {
        if let show = showState {
            detailsManager?.changeWatchlistState(id!, state: show.watchlist ?? false)
        }
    }
    
    @IBAction func actionButtonClicked(sender: AnyObject) {
        let alert = TvShowDetailsActionAlert(presenter: self, homepage: homepage, url: shareUrl)
        alert.present()
    }
    
    @IBAction func screenSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Changed {
            view.frame.origin.x = sender.translationInView(view).x
        } else if sender.state == .Ended {
            var targetX: CGFloat = 0
            var completion: ((Bool) -> Void)?
            
            if view.frame.origin.x > view.bounds.width / 2 {
                targetX = view.bounds.width
                completion = { completed in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            
            UIView.animateWithDuration(0.3, animations: { self.view.frame.origin.x = targetX }, completion: completion)
        }
    }
    
    override func viewDidLoad() {
        if let session = Cache.restoreSession(), id = id {
            detailsManager = TvShowDetailsManager(sessionId: session, detailsDelegate: self, stateDelegate: self)
            detailsManager?.loadDetails(id)
            detailsManager?.loadState(id)
            detailsManager?.loadImages(id)
            detailsManager?.loadCredits(id)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        watchlistButton.tintColor = UIColor.rgb(6, 117, 255)
        
        imagesScrollView.backdropsDelegate = self
        castView.castDelegate = self
    }
    
    func tvshowDetailsLoadedSuccessfully(details: TvShowInfo) {
        homepage = details.homepage
        posterImageView.sd_setImageWithURL(NSURL(posterPath: details.posterPath, size: 2), placeholderImage: UIImage(res: .PosterPlaceholder))
        titleLabel.text = details.name
        averageVoteLabel.text = String(details.voteAverage ?? 0.0)
        voteCountLabel.text = "(\(details.voteCount ?? 0))"
        numberOfSeasonsLabel.text = String(details.numberOfSeasons!)
        numberOfEpisodesLabel.text = String(details.numberOfEpisodes!)
        lastAirLabel.text = details.lastAirDate?.stringByReplacingOccurrencesOfString("-", withString: "/")
        overviewLabel.text = details.overview
        overviewLabel.sizeToFit()
    }
    
    func tvshowImagesLoadedSuccessully(images: ImageInfoList) {
        if let backdrops = images.backdrops {
            backdropImages = backdrops
            imagesScrollView.backdropsDisplay(backdrops)
        }
    }
    
    func tvshowStateLoadedSuccessfully(state: AccountState) {
        showState = state
        updateStateIndicators()
    }
    
    func tvshowCreditsLoadedSuccessfully(credits: MovieCredits) {
        if let cast = credits.casts {
            castView.castDisplay(cast)
        }
    }
    
    func tvshowDetailsLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func tvshowImagesLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func tvshowStateLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func tvshowCreditsLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func tvshowFavoriteStateChangedSuccessfully(isFavorite: Bool) {
        let title = NSLocalizedString("Favorite list", comment: "")
        let message = NSLocalizedString(isFavorite ? "TV added to favorites" : "TV removed from favorites", comment: "")
        showState?.favorite = isFavorite
        
        updateStateIndicators()
        movieStateChangeNotifier(title, message)
    }
    
    func tvshowWatchlistStateChangedSuccessfully(isInWatchlist: Bool) {
        let title = NSLocalizedString("Watchlist", comment: "")
        let message = NSLocalizedString(isInWatchlist ? "TV added to watchlist" : "TV removed from watchlist", comment: "")
        showState?.watchlist = isInWatchlist
        
        updateStateIndicators()
        movieStateChangeNotifier(title, message)
    }
    
    func tvshowFavoriteStateChangesFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func tvshowWatchlistStateChangesFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func backdropTapped(image: UIImage?, imageUrl: String) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("BackdropPages") as! BackdropsController
        controller.content = backdropImages
        controller.initialUrl = imageUrl
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func castSelected(id: Int?) {
        if let castId = id {
            PersonDetailsController.presentControllerModally(self, id: String(castId))
         }
    }
    
    func movieStateChangeNotifier(title: String, _ message: String){
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil)
        alert.show()
        alert.performSelector("dismiss", withObject: alert, afterDelay: 1)
        
        func dismiss() {
            alert.dismissWithClickedButtonIndex(-1, animated: true)
        }
    }
    
    func updateStateIndicators(){
        navFavoriteButton.image = UIImage(res: showState?.favorite ?? false ? .HeartFilled : .Heart)
        watchlistButton.image = UIImage(res: showState?.watchlist ?? false ? .MovieFilled : .Movie)
        watchlistLabel.text = showState?.watchlist ?? false ? "In watchlist" : "Add to watchlist"
    }
}
