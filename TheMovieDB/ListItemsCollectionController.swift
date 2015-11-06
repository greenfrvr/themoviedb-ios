//
//  ListItemsCollectionController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/4/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import SDWebImage

class ListItemsCollectionController: UICollectionViewController, ListItemsCollectionDelegate {
    
    var items = [ListItem]()
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ListItemViewCell.identifier, forIndexPath: indexPath) as! ListItemViewCell
        let item = items[indexPath.row]
        
        cell.movieNameLabel.padding = 10
        cell.movieNameLabel.text = item.title
        cell.posterImageView.sd_setImageWithURL(NSURL(string: ApiEndpoints.poster(2, item.posterPath!)), placeholderImage: UIImage(named: "defaultPhoto"))
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionFetched(collection: [ListItem]) {
        items += collection
        collectionView?.reloadData()
    }
    
}

protocol ListItemsCollectionDelegate {
    
    func collectionFetched(collection: [ListItem]) -> Void

}