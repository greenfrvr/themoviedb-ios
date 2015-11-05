//
//  SearchMovieViewCell.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/5/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class SearchViewCell: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDate: UILabel!
    @IBOutlet weak var cellDescription: UILabel!
    
}

protocol SearchViewRepresentation {
    var representImage: String? { get }
    var representTitle: String? { get }
    var representDate: String? { get }
    var representDescription: String? { get }
}