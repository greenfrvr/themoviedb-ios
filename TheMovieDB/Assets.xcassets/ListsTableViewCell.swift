//
//  ListsTableViewCell.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/3/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class ListsTableViewCell: UITableViewCell {

    static let identifier = "ListsTableViewCell"
    
    @IBOutlet weak var listTitleLabel: UILabel!
    @IBOutlet weak var listDescLabel: UILabel!
    @IBOutlet weak var listCounterLabel: UILabel!
    @IBOutlet weak var listImageView: UIImageView!
    
}

protocol SegmentsRepresentation {
    var id: String? { get }
    var representImage: String? { get }
    var representTitle: String? { get }
    var representDescription: String? { get }
    var representCounter: String? { get }
}
