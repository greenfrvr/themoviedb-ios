//
//  UICastHorizontalView.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/16/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import Dollar

class UICastHorizontalView: UIScrollView, UIScrollViewDelegate, UIPosterViewDelegate {

    var itemHeight: Int = 116
    var itemWidth: Int = 77
    let offset = CGFloat(38.5)
    var currentItem: Int = 0
    var items: [Credits.Cast]!
    var castDelegate: UICastDelegate? {
        didSet {
            self.delegate = self
            self.contentInset = UIEdgeInsetsMake(0, (frame.size.width - CGFloat(itemWidth)) / 2.0, 0, (frame.size.width - CGFloat(itemWidth)) / 2.0)
        }
    }
    
    func castDisplay(cast: [Credits.Cast]){
        items = cast
        setupCastLabel()
        setupPhotos()
    }
    
    func setupCastLabel(){
        let castLabel = UILabel(frame: CGRect(x: center.x, y: bounds.height - 18, width: CGFloat(itemWidth), height: CGFloat(10)))
        castLabel.text = "\(items[currentItem].name!) as \(items[currentItem].character!)"
        castLabel.font = castLabel.font.fontWithSize(12)
        castLabel.textColor = UIColor.rgb(37, 37, 37)
        castLabel.sizeToFit()
        addSubview(castLabel)
    }
    
    func setupPhotos(){
        var x = 0
        for item in items {
            let imageView = UIPosterView(frame: CGRect(x: x, y: 0, width: itemWidth, height: itemHeight))
            imageView.itemId = item.id
            imageView.delegate = self
            imageView.sd_setImageWithURL(NSURL(string: ApiEndpoints.poster(3, item.profilePath ?? "")), placeholderImage: UIImage(named: "defaultPhoto"))
            
            x += itemWidth
            addSubview(imageView)
        }
        contentSize = CGSizeMake(CGFloat(x), CGFloat(itemHeight))
        contentOffset = CGPointMake(-contentInset.left + 1, 0)
    }
    
    func posterTapped(itemId: Int?) {
        castDelegate?.castTapped(itemId)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        for view in scrollView.subviews {
            if let image = view as? UIPosterView {
                let delta = view.center.x - (scrollView.bounds.origin.x + scrollView.contentInset.left) - offset
                updatePhoto(image, delta: delta)
            }
            else if let label = view as? UILabel {
                updateLabel(label)
            }
        }
    }
    
    func updatePhoto(image: UIPosterView, delta: CGFloat){
        if abs(delta) < offset {
            currentItem = $.findIndex(items) { $0.id == image.itemId } ?? 0
            bringSubviewToFront(image)
            animatePhoto(image, scale: 1.1, alpha: 1)
        }
        else if abs(delta) < offset * 3 {
            animatePhoto(image, scale: 0.9, alpha: 0.7)
        }
        else {
            animatePhoto(image, scale: 0.7, alpha: 0.5)
        }
    }
    
    func updateLabel(label: UILabel){
        if currentItem < items.count {
            label.text = "\(items[currentItem].name!) as \(items[currentItem].character!)"
            label.frame.origin.x = self.center.x + contentOffset.x - label.frame.width / 2
            label.sizeToFit()
        }
    }
    
    func animatePhoto(view: UIView, scale: CGFloat, alpha: CGFloat){
        UIView.animateWithDuration(0.2,
            delay: 0,
            options: [UIViewAnimationOptions.CurveEaseInOut, .AllowUserInteraction],
            animations: {
                view.transform = CGAffineTransformMakeScale(scale, scale)
                view.alpha = alpha
            },
            completion: nil)
    }
}

protocol UICastDelegate {
    
    func castTapped(id: Int?)
}
