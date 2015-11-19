//
//  UIScrollCollectionWithLabel.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/17/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import Dollar

class UIScrollCollectionWithLabel<C>: NSObject, UIScrollViewDelegate, UIPosterViewDelegate {
    
    var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    var itemHeight: CGFloat = 116.0
    var itemWidth: CGFloat = 77.0
    var currentItem = 0
    var items = [C]()
    var offset: CGFloat {
        return itemWidth / 2
    }
    
    func castDisplay(cast: [C]){
        items = cast
        if !cast.isEmpty {
            setupScrollView()
            setupLabel()
            setupCollection()
        }
    }
    
    func setupScrollView() {
//        delegate = self
    }
    
    func prepareLabel() -> UILabel {
        assert(false, "Must be overriden")
    }
    
    func setupLabel(){
        scrollView.addSubview(prepareLabel())
    }
    
    func setupCollection(){
        var x = CGFloat(0.0)
        for item in items {
            var imageView = UIPosterView(frame: CGRect(x: x, y: 0, width: itemWidth, height: itemHeight))
            imageView.delegate = self
            imageView.sd_setImageWithURL(NSURL(string: imageUrl(item)), placeholderImage: UIImage(named: "defaultPhoto"))
            setupPosterId(item, poster: &imageView)
            
            x += itemWidth
            scrollView.addSubview(imageView)
        }
        scrollView.contentSize = CGSizeMake(x, itemHeight)
        scrollView.contentOffset = CGPointMake(-scrollView.contentInset.left + 1, 0)
    }
    
    func setupPosterId(item: C, inout poster: UIPosterView) {
        assert(false, "Must be overriden")
    }
    
    func imageUrl(item: C) -> String {
        assert(false, "Must be overriden")
    }
    
    func posterTapped(itemId: Int?) {
        //empty poster tap listener
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
        let (scale, alpha): (CGFloat, CGFloat)
        
        if abs(delta) < offset {
            currentItem = findIndex(callback(image.itemId)) ?? 0
            scrollView.bringSubviewToFront(image)
            (scale, alpha) = (1.1, 1)
        }
        else if abs(delta) < offset * 3 {
            (scale, alpha) = (0.9, 0.7)
        }
        else {
            (scale, alpha) = (0.7, 0.5)
        }
        animatePhoto(image, params: (scale, alpha))
    }
    
    func findIndex(callback: (C) -> Bool) -> Int? {
        for (index, elem): (Int, C) in items.enumerate() {
            if callback(elem) {
                return index
            }
        }
        return .None
    }
    
    func callback(itemId: Int?) -> ((C) -> Bool) {
        assert(false, "Must be specified")
    }
    
    func updateLabel(label: UILabel){
        if currentItem < items.count {
            updateLabelText(label)
            label.frame.origin.x = scrollView.center.x + scrollView.contentOffset.x - label.frame.width / 2
            label.sizeToFit()
        }
    }
    
    func updateLabelText(label: UILabel) {
        assert(false, "Must be overriden")
    }
    
    func animatePhoto(view: UIView, params : (CGFloat, CGFloat)){
        let (scale, alpha) = params
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
