//
//  MovieDetailsController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/6/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import SDWebImage

class MovieDetailsController: UIViewController, MovieDetailsDelegate, MovieStateChangeDelegate, UIBackdropsDelegat, UICastDelegate, UISimilarViewDelegate,DetailsNavigation {
    
    static var controllerId = "MovieDetails"
    static var navigationId = "MovieNavigationController"
    
    var id: String?
    var imdbId: String?
    var movieState: AccountState?
    var detailsManager: MovieDetailsManager?
    var backdropImages = [ImageInfo]()
    var shareUrl: String { return MovieDetailsManager.urlShare.withArgs(id!) }
    var openIMDBUrl: String { return "http://www.imdb.com/title/\(imdbId!)" }
    lazy var castView = UICastHorizontalView()
    lazy var similarView = UISimilarView()
    
    @IBOutlet var screenPanRecognizer: UIScreenEdgePanGestureRecognizer!
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var rateIcon: UIImageView!
    @IBOutlet weak var averageVoteLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    
    @IBOutlet weak var navFavoriteButton: UIBarButtonItem!
    @IBOutlet weak var watchlistButton: UIImageView!
    @IBOutlet weak var watchlistLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabelWithPadding!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var backdropsLabel: UILabelWithPadding!
    @IBOutlet weak var castLabel: UILabelWithPadding!
    
    @IBOutlet weak var detailsScrollContainer: UIScrollView!
    @IBOutlet weak var imagesScrollView: UIBackdropsHorizontalView! {
        didSet {
            imagesScrollView.panGestureRecognizer.requireGestureRecognizerToFail(screenPanRecognizer)
        }
    }
    @IBOutlet weak var similarScrollView: UIScrollView! {
        didSet {
            similarView.scrollView = similarScrollView
            similarScrollView.panGestureRecognizer.requireGestureRecognizerToFail(screenPanRecognizer)
        }
    }
    @IBOutlet weak var castScrollView: UIScrollView! {
        didSet {
            castView.scrollView = castScrollView
            castScrollView.panGestureRecognizer.requireGestureRecognizerToFail(screenPanRecognizer)
        }
    }
    
    @IBAction func unwindMovieDetails(sender: UIBarButtonItem) {
        if navigationController?.viewControllers.count == 1 {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func addToFavorite(sender: UIBarButtonItem) {
        if let movie = movieState {
            detailsManager?.changeFavoriteState(id!, state: movie.favorite ?? false)
        }
    }
    
    @IBAction func addToWatchlist(sender: AnyObject) {
        if let movie = movieState {
            detailsManager?.changeWatchlistState(id!, state: movie.watchlist ?? false)
        }
    }
    
    @IBAction func actionButtonClicked(sender: AnyObject) {
        let alert = MovieDetailsActionAlert(presenter: self, imdb: openIMDBUrl, url: shareUrl)
        alert.id = id
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
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let session = Cache.restoreSession(), id = id {
            detailsManager = MovieDetailsManager(sessionId: session, detailsDelegate: self, stateDelegate: self)
            detailsManager?.loadDetails(id)
            detailsManager?.loadState(id)
            detailsManager?.loadImages(id)
            detailsManager?.loadCredits(id)
            detailsManager?.loadSimilar(id)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        watchlistButton.tintColor = UIColor.rgb(6, 117, 255)
        
        imagesScrollView.backdropsDelegate = self
        castView.castDelegate = self
        similarView.delegate = self
    }

    func movieDetailsLoadedSuccessfully(details: MovieInfo) {
        imdbId = details.imdbId
        posterImageView.sd_setImageWithURL(NSURL(posterPath: details.posterPath, size: 3), placeholderImage: UIImage(res: .PosterPlaceholder))
        titleLabel.text = details.title

        if let tagline = details.tagline where !tagline.isEmpty {
            taglineLabel.text = tagline
            taglineLabel.sizeToFit()
        } else {
            taglineLabel.removeConstraints(taglineLabel.constraints)
            NSLayoutConstraint(item: rateIcon, attribute: .Top, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1.0, constant: 8).active = true
        }
        averageVoteLabel.text = String(details.voteAverage ?? 0.0)
        voteCountLabel.text = "(\(details.voteCount ?? 0))"
        runtimeLabel.text = "\(details.runtime ?? 0) min"
        budgetLabel.text = "\(details.budget ?? 0)$"
        revenueLabel.text = "\(details.revenue ?? 0)$"
        
        overviewLabel.text = details.overview
        overviewLabel.sizeToFit()

        view.layoutIfNeeded()
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
    
    func movieCreditsLoadedSuccessfully(credits: MovieCredits) {
        if let cast = credits.casts {
            castView.castDisplay(cast)
        }
    }
    
    func movieSimilarLoadedSuccessfully(similar: SegmentList) {
        if let similar = similar.results {
            similarView.castDisplay(similar)
        }
    }
    
    func movieDetailsLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func movieStateLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func movieImagesLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func movieCreditsLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func movieSimilarLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
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
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func movieWatchlistStateChangesFailed(error: NSError) {
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
    
    func similarItemTapped(id: Int?) {
        if let movieId = id {
            MovieDetailsController.presentControllerModally(self, id: String(movieId))
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
        navFavoriteButton.image = UIImage(res: movieState?.favorite ?? false ? .HeartFilled : .Heart)
        watchlistButton.image = UIImage(res: movieState?.watchlist ?? false ? .MovieFilled : .Movie)
        watchlistLabel.text = movieState?.watchlist ?? false ? "In watchlist" : "Add to watchlist"
    }
}
