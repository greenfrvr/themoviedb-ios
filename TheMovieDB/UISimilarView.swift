//
//  UISimilarView.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 12/1/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class UISimilarView: NSObject, UIScrollViewDelegate, UIPosterViewDelegate {
    
    var delegate: UISimilarViewDelegate?
    var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    let itemHeight: CGFloat = 156.0
    let itemWidth: CGFloat = 256.0
    let posterWidth: CGFloat = 104.0
    let margin: CGFloat = -2.0
    var currentItem = 0
    var items = [SegmentListItem]()
    var offset: CGFloat {
        return itemWidth / 2
    }
    
    func castDisplay(cast: [SegmentListItem]){
        items = cast
        if !cast.isEmpty {
            setupCollection()
        }
    }
    
    func setupPosterId(item: SegmentListItem, inout poster: UIPosterView) {
        poster.itemId = item.itemId
    }
    
    func callback(itemId: Int?) -> ((SegmentListItem) -> Bool) {
        return { $0.itemId == itemId }
    }
    
    func posterTapped(itemId: Int?) {
        delegate?.similarItemTapped(itemId)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        for view in scrollView.subviews {
            let delta = view.center.x - (scrollView.bounds.origin.x + scrollView.contentInset.left) - offset
            updateView(view, delta: delta)
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if abs(velocity.x) > 0.2 {
            let fullWidth = itemWidth + margin
            let maxIndex = CGFloat(items.count)
            let targetX: CGFloat = scrollView.contentOffset.x + velocity.x * 15
            var targetIndex: CGFloat = velocity.x > 0 ? ceil(targetX / fullWidth) : floor(targetX / fullWidth)
            
            if targetIndex < 0 {
                targetIndex = 0
            }
            if targetIndex > maxIndex {
                targetIndex = maxIndex
            }
            targetContentOffset.memory.x = targetIndex * fullWidth
        }
    }
    
    private func setupCollection(){
        let offset = CGFloat(scrollView.bounds.width - itemWidth - margin) / 2
        var frame = CGRectMake(offset, 0, itemWidth, itemHeight)
        
        for item in items {
            let view = UISimilarCard(frame: frame, item: item, delegate: self)
            frame.offsetInPlace(dx:  margin + itemWidth, dy: 0)
            scrollView.addSubview(view)
        }
        frame.offsetInPlace(dx:  offset, dy: 0)
        
        scrollView.contentSize = CGSizeMake(frame.origin.x, frame.height)
        scrollView.contentOffset = CGPointMake(1, 0)
    }
    
    private func updateView(view: UIView, delta: CGFloat){
        let (scale, alpha): (CGFloat, CGFloat)
        
        if abs(delta) < offset {
            scrollView.bringSubviewToFront(view)
            (scale, alpha) = (1.0, 1)
        } else {
            (scale, alpha) = (0.9, 0.7)
        }
        
        animateView(view, params: (scale, alpha))
    }
    
    private func findIndex(callback: (SegmentListItem) -> Bool) -> Int? {
        for (index, elem): (Int, SegmentListItem) in items.enumerate() {
            if callback(elem) {
                return index
            }
        }
        return .None
    }
    
    private func animateView(view: UIView, params : (CGFloat, CGFloat)){
        let (scale, alpha) = params
        UIView.animateWithDuration(0.2, delay: 0,
            options: [UIViewAnimationOptions.CurveEaseInOut, .AllowUserInteraction],
            animations: {
                view.transform = CGAffineTransformMakeScale(scale, scale)
                view.alpha = alpha
            },
            completion: nil)
    }
}

protocol UISimilarViewDelegate {
    func similarItemTapped(id: Int?)
}