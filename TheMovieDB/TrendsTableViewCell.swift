//
//  TrendsTableViewCell.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/12/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class TrendsTableViewCell: UITableViewCell {
    
    static let identifier = "TrendsTableViewCell"
    
    @IBOutlet weak var leftPoster: UIPosterView!
    @IBOutlet weak var middlePoster: UIPosterView!
    @IBOutlet weak var rightPoster: UIPosterView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateIcon: UIImageView! {
        didSet {
            rateIcon.tintColor = UIColor.rgb(224, 224, 224)
        }
    }
    @IBOutlet weak var shortDetails: UIView!
    @IBOutlet weak var detailsContainer: UIView!
    @IBOutlet weak var detailsBackground: UIImageView!
    
    func setupDelegate(delegate: UIPosterViewDelegate){
        leftPoster.delegate = delegate
        middlePoster.delegate = delegate
        rightPoster.delegate = delegate
        
        shortDetails.addGestureRecognizer(UITapGestureRecognizer(target: rightPoster, action: "posterTap"))
     }
}
