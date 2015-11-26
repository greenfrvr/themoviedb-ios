//
//  PersonDetailsController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/17/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class PersonDetailsController: UIViewController, PersonDetailsDelegate, UIPersonCreditsViewDelegate, DetailsNavigation {
    
    static var controllerId = "PersonDetails"
    static var navigationId = "PersonNavigationController"
    
    var id: String?
    var homepage: String?
    var shareUrl: String {
        return "\(ApiEndpoints.personShare)/\(id!)"
    }
    var detailsManager: PersonDetailsManager?
    lazy var creditsView = UIPersonCreditsView()

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var birthplaceLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var creditsScrollView: UIScrollView! {
        didSet {
            creditsView.scrollView = creditsScrollView
        }
    }
    
    @IBAction func unwindPersonDetails(sender: AnyObject) {
        if navigationController?.viewControllers.count == 1 {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func actionButtonClicked(sender: AnyObject) {
        let alert = PersonDetailsActionAlert(presenter: self, homepage: homepage, url: shareUrl)
        alert.present()
    }
    
    override func viewDidLoad() {
        detailsManager = PersonDetailsManager(detailsDelegate: self)
        
        if let id = id {
            detailsManager?.loadDetails(id)
            detailsManager?.loadCredits(id)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        creditsView.creditsDelegate = self
    }
    
    func personDetailsLoadedSuccessfully(details: PersonInfo) {
        homepage = details.homepage
        profileImageView.sd_setImageWithURL(NSURL(profilePath: details.profilePath, size: 3), placeholderImage: UIImage.placeholder())
        nameLabel.text = details.name
        birthdayLabel.text = details.birthday
        birthplaceLabel.text = details.birthplace
        biographyLabel.text = details.biography
    }
    
    func personCreditsLoadedScuccessfully(credits: PersonCredits) {
        if let cast = credits.cast {
            creditsView.castDisplay(cast)
        }
    }
    
    func personDetailsLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func personCreditsLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func castSelected(itemId: Int?, type itemType: String?) {
        if let id = itemId, type = itemType {
            switch type {
            case "movie": MovieDetailsController.presentControllerModally(self, id: String(id))
            case "tv": TvShowDetailsController.presentControllerModally(self, id: String(id))
            default: return
            }
        }
    }
}
