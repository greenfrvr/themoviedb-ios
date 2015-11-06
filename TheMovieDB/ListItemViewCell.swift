//
//  ListItemViewCell.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/4/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class ListItemViewCell: UICollectionViewCell {
    
    static let identifier = "ListItemViewCell"
    
    @IBOutlet weak var movieNameLabel: UILabelWithPadding!
    @IBOutlet weak var posterImageView: UIImageView!
    
}
