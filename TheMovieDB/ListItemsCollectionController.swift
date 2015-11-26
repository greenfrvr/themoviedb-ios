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
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = items[indexPath.row]
        MovieDetailsController.presentControllerWithNavigation(self, id: String(item.itemId!))
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ListItemViewCell.identifier, forIndexPath: indexPath) as! ListItemViewCell
        let item = items[indexPath.row]
        
        cell.movieNameLabel.padding = 10
        cell.movieNameLabel.text = item.title
        cell.posterImageView.sd_setImageWithURL(NSURL(posterPath: item.posterPath, size: 3), placeholderImage: UIImage.placeholder())
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionFetched(collection: [ListItem]) {
        items += collection
        collectionView?.reloadData()
    }
}

protocol ListItemsCollectionDelegate {
    
    func collectionFetched(collection: [ListItem]) -> Void

}