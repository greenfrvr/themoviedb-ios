//
//  UICastHorizontalView.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/16/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import Dollar

class UICastHorizontalView: UIScrollCollectionWithLabel<MovieCredits.Cast> {
    
    var castDelegate: UICastDelegate? {
        didSet {
            itemHeight = 116.0
            itemWidth = 77.0
            
            let inset = (scrollView.frame.size.width - itemWidth) / 2
            scrollView.contentInset = UIEdgeInsetsMake(0, inset, 0, inset)
            scrollView.delegate = self
        }
    }
    
    override func prepareLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: scrollView.center.x, y: scrollView.bounds.height - 18, width: itemWidth, height: 10.0))
        updateLabelText(label)
        label.font = label.font.fontWithSize(12)
        label.textColor = UIColor.rgb(37, 37, 37)
        label.sizeToFit()
        return label
    }
    
    override func updateLabelText(label: UILabel) {
        label.text = "\(items[currentItem].name!) as \(items[currentItem].character!)"
    }
    
    override func setupPosterId(item: MovieCredits.Cast, inout poster: UIPosterView) {
        poster.itemId = item.id
    }
    
    override func imageUrl(item: MovieCredits.Cast) -> String {
        return ImagesConfig.profile(2, item.profilePath ?? "")
    }
    
    override func callback(itemId: Int?) -> ((MovieCredits.Cast) -> Bool) {
        return { $0.id == itemId }
    }
    
    override func posterTapped(itemId: Int?) {
        castDelegate?.castSelected(itemId)
    }
}

protocol UICastDelegate {
    func castSelected(id: Int?)
}
