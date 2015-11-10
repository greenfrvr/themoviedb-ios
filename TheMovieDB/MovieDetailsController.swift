//
//  MovieDetailsController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/6/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import SDWebImage

class MovieDetailsController: UIViewController, MovieDetailsDelegate {
    
    //MARK: Properties
    var movieId: String?
    var shareUrl: String {
        return "\(ApiEndpoints.movieShare)/\(movieId!)"
    }
    var imdbId: String?
    var openIMDBUrl: String {
        return "http://www.imdb.com/title/\(imdbId!)"
    }
    var movieState: MovieState?
    var detailsManager: MovieDetailsManager?
    
    //MARK: Outlets
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var averageVoteLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var navFavoriteButton: UIBarButtonItem!
    @IBOutlet weak var watchlistButton: UIImageView!
    
    //MARK: Action
    @IBAction func unwindMovieDetails(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
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
        let actionSheet = UIAlertController(title: "Pick an action", message: "What do you want to do with this movie?", preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Share", style: .Default, handler: { action in
            let shareController = UIActivityViewController(activityItems: [self.shareUrl], applicationActivities: nil)
            self.presentViewController(shareController, animated: true, completion: nil)

        }))
        
        if imdbId != nil {
            actionSheet.addAction(UIAlertAction(title: "Open IMDB page", style: .Default, handler: { action in
                let openUrl = NSURL(string: self.openIMDBUrl)
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
        super.viewDidLoad()
        let session = SessionCache.restoreSession()!
        detailsManager = MovieDetailsManager(sessionId: session.sessionToken!, delegate: self)
        
        if let id = movieId {
            print("LOADING ID \(id)")
            detailsManager?.loadDetails(id)
            detailsManager?.loadState(id)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        taglineLabel.numberOfLines = 2
        taglineLabel.sizeToFit()
        
        overviewLabel.numberOfLines = 0
        overviewLabel.sizeToFit()
        
        watchlistButton.tintColor = UIColor.rgb(6, 117, 255)
    }
    
    //MARK: MovieDetailsDelegate
    func movieDetailsLoadedSuccessfully(details: MovieInfo) {
        print("Movie details loaded: \(details.movieId!)")
        imdbId = details.imdbId
        posterImageView.sd_setImageWithURL(NSURL(string: ApiEndpoints.poster(3, details.posterPath ?? "")), placeholderImage: UIImage(named: "defaultPhoto"))
        titleLabel.text = details.title
        taglineLabel.text = details.tagline
        averageVoteLabel.text = String(details.voteAverage ?? 0.0)
        voteCountLabel.text = "(\(details.voteCount ?? 0))"
        runtimeLabel.text = "\(details.runtime ?? 0) min"
        budgetLabel.text = "\(details.budget ?? 0)$"
        revenueLabel.text = "\(details.revenue ?? 0)$"
        overviewLabel.text = details.overview
    }
    
    func movieStateLoadedSuccessfully(state: MovieState) {
        movieState = state
        updateStateIndicators()
    }
    
    func movieFavoriteStateChangedSuccessfully(isFavorite: Bool) {
        movieState?.favorite = isFavorite
        updateStateIndicators()
        movieStateChangeNotifier("Favorite list", message: "This movie was \(isFavorite ? "added to" : "removed from") your favorites list")
    }
    
    func movieWatchlistStateChangedSuccessfully(isInWatchlist: Bool) {
        movieState?.watchlist = isInWatchlist
        updateStateIndicators()
        movieStateChangeNotifier("Watchlist", message: "This movie was \(isInWatchlist ? "added to" : "removed from") your watchlist")
    }
    
    func movieDetailsLoadingFailed(error: NSError) {
        print(error)
    }
    
    func movieStateLoadingFailed(error: NSError) {
        print(error)
    }
    
    func movieFavoriteStateChangesFailed(error: NSError) {
        print(error)
    }
    
    func movieWatchlistStateChangesFailed(error: NSError) {
        print(error)
    }
    
    func movieStateChangeNotifier(title: String, message: String){
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil)
        alert.show()
        alert.performSelector(Selector("dismiss"), withObject: alert, afterDelay: 1)
        
        func dismiss() {
            alert.dismissWithClickedButtonIndex(-1, animated: true)
        }
    }
    
    func updateStateIndicators(){
        navFavoriteButton.image = UIImage(named: movieState?.favorite ?? false ? "Like Filled" : "Hearts")
        watchlistButton.image = UIImage(named: movieState?.watchlist ?? false ? "Movie Filled" : "Movie")
    }
}
