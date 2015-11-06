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
    
}
