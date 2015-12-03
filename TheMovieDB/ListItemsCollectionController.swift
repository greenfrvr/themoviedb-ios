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
    
    var items = [CompilationItem]()
    
    override func viewDidLoad() {
        adjustCollectionFlow(UIScreen.mainScreen().bounds.size)
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        adjustCollectionFlow(size)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = items[indexPath.row]
        MovieDetailsController.presentControllerWithNavigation(self, id: String(item.itemId!))
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ListItemViewCell.identifier, forIndexPath: indexPath) as! ListItemViewCell
        let item = items[indexPath.row]
        
        cell.movieNameLabel.text = item.title
        cell.posterImageView.sd_setImageWithURL(NSURL(posterPath: item.posterPath, size: 3), placeholderImage: UIImage(res: .PosterPlaceholder))
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionFetched(collection: [CompilationItem]) {
        items += collection
        collectionView?.reloadData()
    }
    
    func adjustCollectionFlow(size: CGSize) {
        func itemSize(isPortrait: Bool) -> CGSize {
            let cellWidth = size.width / CGFloat(isPortrait ? 3 : 5)
            
            return CGSizeMake(cellWidth, cellWidth / 2 * 3)
        }
        
        let isPortrait = size.width < size.height
        let topInset = CGFloat(isPortrait ? 22 : 56)
        
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(topInset, 0, 0, 0)
        layout.itemSize = itemSize(isPortrait)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView?.collectionViewLayout = layout
    }
}

protocol ListItemsCollectionDelegate {
    
    func collectionFetched(collection: [CompilationItem]) -> Void

}