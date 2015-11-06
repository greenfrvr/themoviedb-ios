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
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsManager = MovieDetailsManager(delegate: self)
        print("Movie identificator: \(movieId ?? "didn't receive")")
        if let id = movieId {
            detailsManager?.loadDetails(id)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        taglineLabel.numberOfLines = 2
        taglineLabel.sizeToFit()
        
        overviewLabel.numberOfLines = 0
        overviewLabel.sizeToFit()
    }
    
    //MARK: MovieDetailsDelegate
    func detailsLoadedSuccessfully(details: MovieInfo) {
        print("details loaded: \(details.title!)")
        posterImageView.sd_setImageWithURL(NSURL(string: ApiEndpoints.poster(3, details.posterPath ?? "")), placeholderImage: UIImage(named: "defaultPhoto"))
        titleLabel.text = details.title
        taglineLabel.text = details.tagline
        averageVoteLabel.text = String(details.voteAverage!)
        voteCountLabel.text = "(\(details.voteCount!))"
        runtimeLabel.text = "\(details.runtime!) min"
        budgetLabel.text = "\(details.budget!)$"
        revenueLabel.text = "\(details.revenue!)$"
        overviewLabel.text = details.overview
    }
    
    func detailsLoadingFailed(error: NSError) {
        print(error)
    }
}
