//
//  MovieDetailsController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/6/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import SDWebImage

class MovieDetailsController: UIViewController, MovieDetailsDelegate, MovieStateChangeDelegate, UIBackdropsDelegat, UICastDelegate {
    
    //MARK: Properties
    var movieId: String?
    var imdbId: String?
    var movieState: AccountState?
    var detailsManager: MovieDetailsManager?
    var backdropImages = [ImageInfo]()
    var shareUrl: String {
        return "\(ApiEndpoints.movieShare)/\(movieId!)"
    }
    var openIMDBUrl: String {
        return "http://www.imdb.com/title/\(imdbId!)"
    }
    lazy var castView = UICastHorizontalView()
    
    static func performMovieController(performer: UIViewController, id: String?){
        let navigationController = performer.storyboard?.instantiateViewControllerWithIdentifier("MovieNavigationController") as! UINavigationController
        let controller = navigationController.topViewController as! MovieDetailsController
        controller.movieId = id
        performer.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    //MARK: Outlets
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var averageVoteLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    
    @IBOutlet weak var navFavoriteButton: UIBarButtonItem!
    @IBOutlet weak var watchlistButton: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabelWithPadding!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var backdropsLabel: UILabelWithPadding!
    @IBOutlet weak var castLabel: UILabelWithPadding!
    
    @IBOutlet weak var detailsScrollContainer: UIScrollView!
    @IBOutlet weak var imagesScrollView: UIBackdropsHorizontalView!
    @IBOutlet weak var castScrollView: UIScrollView! {
        didSet {
            castView.scrollView = castScrollView
        }
    }
    
    //MARK: Action
    @IBAction func unwindMovieDetails(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func overviewSectionClicked(sender: AnyObject) {
        print("Overview clicked")
    }
    
    @IBAction func addToFavorite(sender: UIBarButtonItem) {
        if let movie = movieState {
            detailsManager?.changeFavoriteState(movieId!, state: movie.favorite ?? false)
        }
    }
    
    @IBAction func addToWatchlist(sender: AnyObject) {
        if let movie = movieState {
            detailsManager?.changeWatchlistState(movieId!, state: movie.watchlist ?? false)
        }
    }
    
    @IBAction func actionButtonClicked(sender: AnyObject) {
        let alert = MovieDetailsActionAlert(presenter: self, imdb: openIMDBUrl, url: shareUrl)
        alert.id = movieId
        alert.present()
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let session = SessionCache.restoreSession()!
        detailsManager = MovieDetailsManager(sessionId: session.sessionToken!, detailsDelegate: self, stateDelegate: self)
        
        if let id = movieId {
            detailsManager?.loadDetails(id)
            detailsManager?.loadState(id)
            detailsManager?.loadImages(id)
            detailsManager?.loadCredits(id)
        }
    }
    
    override func accessibilityPerformEscape() -> Bool {
        print("Escape performed")
        return super.accessibilityPerformEscape()
    }
    
    override func viewWillAppear(animated: Bool) {
        taglineLabel.numberOfLines = 2
        taglineLabel.sizeToFit()
        
        overviewLabel.numberOfLines = 0
        overviewLabel.sizeToFit()
        
        watchlistButton.tintColor = UIColor.rgb(6, 117, 255)
        
        imagesScrollView.backdropsDelegate = self
        castView.castDelegate = self
    }

    //MARK: MovieDetailsDelegate
    func movieDetailsLoadedSuccessfully(details: MovieInfo) {
        imdbId = details.imdbId
        posterImageView.sd_setImageWithURL(NSURL(imagePath: details.posterPath), placeholderImage: UIImage.placeholder())
        titleLabel.text = details.title
        taglineLabel.text = details.tagline
        averageVoteLabel.text = String(details.voteAverage ?? 0.0)
        voteCountLabel.text = "(\(details.voteCount ?? 0))"
        runtimeLabel.text = "\(details.runtime ?? 0) min"
        budgetLabel.text = "\(details.budget ?? 0)$"
        revenueLabel.text = "\(details.revenue ?? 0)$"
        overviewLabel.text = details.overview
    }
    
    func movieStateLoadedSuccessfully(state: AccountState) {
        movieState = state
        updateStateIndicators()
    }
    
    func movieImagesLoadedSuccessully(images: ImageInfoList) {
        if let backdrops = images.backdrops {
            backdropImages = backdrops
            imagesScrollView.backdropsDisplay(backdrops)
        }
    }
    
    func movieCreditsLoadedSuccessfully(credits: Credits) {
        if let cast = credits.casts {
            castView.castDisplay(cast)
        }
    }
    
    func movieDetailsLoadingFailed(error: NSError) {
        print(error)
    }
    
    func movieStateLoadingFailed(error: NSError) {
        print(error)
    }
    
    func movieImagesLoadingFailed(error: NSError) {
        print(error)
    }
    
    func movieCreditsLoadingFailed(error: NSError) {
        print(error)
    }
    
    //MARK: MovieStateChangeDelegate
    func movieFavoriteStateChangedSuccessfully(isFavorite: Bool) {
        let title = NSLocalizedString("Favorite list", comment: "")
        let message = NSLocalizedString(isFavorite ? "Movie added to favorites" : "Movie removed from favorites", comment: "")
        movieState?.favorite = isFavorite
        
        updateStateIndicators()
        movieStateChangeNotifier(title, message)
    }
    
    func movieWatchlistStateChangedSuccessfully(isInWatchlist: Bool) {
        let title = NSLocalizedString("Watchlist", comment: "")
        let message = NSLocalizedString(isInWatchlist ? "Movie added to watchlist" : "Movie removed from watchlist", comment: "")
        movieState?.watchlist = isInWatchlist
        
        updateStateIndicators()
        movieStateChangeNotifier(title, message)
    }
    
    func movieFavoriteStateChangesFailed(error: NSError) {
        print(error)
    }
    
    func movieWatchlistStateChangesFailed(error: NSError) {
        print(error)
    }
    
    //MARK: UIBackdropsDelegate
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
    func movieStateChangeNotifier(title: String, _ message: String){
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil)
        alert.show()
        alert.performSelector("dismiss", withObject: alert, afterDelay: 1)
        
        func dismiss() {
            alert.dismissWithClickedButtonIndex(-1, animated: true)
        }
    }
    
    func updateStateIndicators(){
        navFavoriteButton.image = UIImage(named: movieState?.favorite ?? false ? "Like Filled" : "Hearts")
        watchlistButton.image = UIImage(named: movieState?.watchlist ?? false ? "Movie Filled" : "Movie")
    }
}
