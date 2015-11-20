//
//  TvDetailsController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/13/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class TvShowDetailsController: UIViewController, TvShowDetailsDelegate, TvShowStateChangeDelegate, UIBackdropsDelegat, UICastDelegate {

    //MARK: Properties
    var tvShowId: String?
    var homepage: String?
    var showState: AccountState?
    var detailsManager: TvShowDetailsManager?
    var backdropImages = [ImageInfo]()
    var shareUrl: String {
        return "\(ApiEndpoints.tvShare)/\(tvShowId!)"
    }
    lazy var castView = UICastHorizontalView()
    
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
    @IBOutlet weak var numberOfSeasonsLabel: UILabel!
    @IBOutlet weak var numberOfEpisodesLabel: UILabel!
    @IBOutlet weak var lastAirLabel: UILabel!
    
    @IBOutlet weak var navFavoriteButton: UIBarButtonItem!
    @IBOutlet weak var watchlistButton: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabelWithPadding!
    @IBOutlet weak var backdropsLabel: UILabelWithPadding!
    @IBOutlet weak var castLabel: UILabelWithPadding!
    
    @IBOutlet weak var detailsScrollContainer: UIScrollView!
    @IBOutlet weak var imagesScrollView: UIBackdropsHorizontalView!
    @IBOutlet weak var castScrollView: UIScrollView! {
        didSet {
            castView.scrollView = castScrollView
        }
    }
    
    //MARK: Actions
    @IBAction func unwindTvShowDetails(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addToFavorite(sender: UIBarButtonItem) {
        if let show = showState {
            detailsManager?.changeFavoriteState(tvShowId!, state: show.favorite ?? false)
        }
    }
    
    @IBAction func addToWatchlist(sender: AnyObject) {
        if let show = showState {
            detailsManager?.changeWatchlistState(tvShowId!, state: show.watchlist ?? false)
        }
    }
    
    @IBAction func actionButtonClicked(sender: AnyObject) {
        let alert = TvShowDetailsActionAlert(presenter: self, homepage: homepage, url: shareUrl)
        alert.present()
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        let session = SessionCache.restoreSession()!
        detailsManager = TvShowDetailsManager(sessionId: session.sessionToken!, detailsDelegate: self, stateDelegate: self)
        
        if let id = tvShowId {
            detailsManager?.loadDetails(id)
            detailsManager?.loadState(id)
            detailsManager?.loadImages(id)
            detailsManager?.loadCredits(id)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        overviewLabel.numberOfLines = 0
        overviewLabel.sizeToFit()
        
        descriptionLabel.padding = 10
        backdropsLabel.padding = 10
        castLabel.padding = 10
        
        watchlistButton.tintColor = UIColor.rgb(6, 117, 255)
        
        imagesScrollView.backdropsDelegate = self
        castView.castDelegate = self
    }
    
    //MARK: TvShowDetailsDelegate
    func tvshowDetailsLoadedSuccessfully(details: TvShowInfo) {
        homepage = details.homepage
        posterImageView.sd_setImageWithURL(NSURL(imagePath: details.posterPath), placeholderImage: UIImage.placeholder())
        titleLabel.text = details.name
        averageVoteLabel.text = String(details.voteAverage ?? 0.0)
        voteCountLabel.text = "(\(details.voteCount ?? 0))"
        numberOfSeasonsLabel.text = String(details.numberOfSeasons!)
        numberOfEpisodesLabel.text = String(details.numberOfEpisodes!)
        lastAirLabel.text = details.lastAirDate?.stringByReplacingOccurrencesOfString("-", withString: "/")
        overviewLabel.text = details.overview
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
    
    func tvshowCreditsLoadedSuccessfully(credits: Credits) {
        if let cast = credits.casts {
            castView.castDisplay(cast)
        }
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
    
    func tvshowCreditsLoadingFailed(error: NSError) {
        print(error)
    }
    
    //MARK: TvShowStateChangeDelegate
    func tvshowFavoriteStateChangedSuccessfully(isFavorite: Bool) {
        showState?.favorite = isFavorite
        updateStateIndicators()
        movieStateChangeNotifier("Favorite list", message: "This show was \(isFavorite ? "added to" : "removed from") your favorites list")
    }
    
    func tvshowWatchlistStateChangedSuccessfully(isInWatchlist: Bool) {
        showState?.watchlist = isInWatchlist
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
    
    //MARK: CastDelegate 
    func castSelected(id: Int?) {
        if let castId = id {
            PersonDetailsController.performPersonDetails(self, id: String(castId))
         }
    }
    
    //MARK: UI
    func movieStateChangeNotifier(title: String, message: String){
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil)
        alert.show()
        alert.performSelector("dismiss", withObject: alert, afterDelay: 1)
        
        func dismiss() {
            alert.dismissWithClickedButtonIndex(-1, animated: true)
        }
    }
    
    func updateStateIndicators(){
        navFavoriteButton.image = UIImage(named: showState?.favorite ?? false ? "Like Filled" : "Hearts")
        watchlistButton.image = UIImage(named: showState?.watchlist ?? false ? "Movie Filled" : "Movie")
    }

}
