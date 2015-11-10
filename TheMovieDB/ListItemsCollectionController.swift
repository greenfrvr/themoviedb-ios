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
    
    //MARK: Properties
    var items = [ListItem]()
    
    //MARK: Collection
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = items[indexPath.row]
        presentMovieController(item.itemId)
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
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //MARK: Data
    func collectionFetched(collection: [ListItem]) {
        items += collection
        collectionView?.reloadData()
    }
    
    func presentMovieController(id: Int?) {
        let navigationController = storyboard?.instantiateViewControllerWithIdentifier("MovieNavigationController") as! UINavigationController
        let controller = navigationController.topViewController as! MovieDetailsController
        controller.movieId = "\(id!)"
        presentViewController(navigationController, animated: true, completion: nil)
    }
}

protocol ListItemsCollectionDelegate {
    
    func collectionFetched(collection: [ListItem]) -> Void

}