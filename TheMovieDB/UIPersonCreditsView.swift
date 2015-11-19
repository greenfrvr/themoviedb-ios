//
//  UIPersonCreditsView.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/17/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import Dollar

class UIPersonCreditsView: UIScrollCollectionWithLabel<PersonCredits.Cast>  {

    var creditsDelegate: UIPersonCreditsViewDelegate? {
        didSet {
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
        label.text = items[currentItem].title
    }
    
    override func setupPosterId(item: PersonCredits.Cast, inout poster: UIPosterView) {
        poster.itemId = item.itemId
    }
    
    override func imageUrl(item: PersonCredits.Cast) -> String {
        return ApiEndpoints.poster(3, item.posterPath ?? "")
    }
    
    override func callback(itemId: Int?) -> ((PersonCredits.Cast) -> Bool) {
        return { $0.itemId == itemId }
    }
    
    override func posterTapped(itemId: Int?) {
        let item = $.find(items, callback: callback(itemId))
        creditsDelegate?.castSelected(itemId, type: item?.type)
    }
}

protocol UIPersonCreditsViewDelegate {
    func castSelected(id: Int?, type: String?)
}