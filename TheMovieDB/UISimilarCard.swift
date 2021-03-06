//
//  UISimilarCard.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 12/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class UISimilarCard: UIView {
    
    let margin: CGFloat = 8
    let posterWidth: CGFloat = 104
    let delegate: UIPosterViewDelegate
    var item: SegmentListItem
    
    init(frame: CGRect, item: SegmentListItem, delegate: UIPosterViewDelegate) {
        self.item = item
        self.delegate = delegate
        
        super.init(frame: frame)
        
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        setupImages()
        
        let blurEffect = UIBlurEffect(style: .Light)
        let blurView = setupBlurEffect(blurEffect)
        let vibrancyView = setupVibrancyEffect(blurEffect)
        
        blurView.contentView.addSubview(vibrancyView)
        addSubview(blurView)
        
        backgroundColor = UIColor.grayColor()
    }
    
    func setupImages() {
        let backdropView = UIPosterView(frame: CGRectMake(posterWidth, 0, bounds.width - posterWidth, bounds.height))
        backdropView.delegate = delegate
        backdropView.itemId = item.itemId
        backdropView.contentMode = UIViewContentMode.ScaleToFill
        
        let maskView = UIView(frame: backdropView.bounds)
        maskView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.55)
        backdropView.maskView = maskView
        
        let posterView = UIPosterView(frame: CGRectMake(0, 0, posterWidth, bounds.height))
        posterView.delegate = delegate
        posterView.itemId = item.itemId
        posterView.sd_setImageWithURL(NSURL(posterPath: item.posterPath, size: 3), placeholderImage: UIImage(res: .PosterPlaceholder),
            completed: { (image, error, cacheType, url) -> Void in
                backdropView.image = image
        })
        
        addSubview(backdropView)
        addSubview(posterView)
    }
    
    func setupBlurEffect(blurEffect: UIBlurEffect) -> UIVisualEffectView {
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRectMake(posterWidth, 0, bounds.width - posterWidth, bounds.height)
        blurEffectView.userInteractionEnabled = false
        
        return blurEffectView
    }
    
    func setupVibrancyEffect(blurEffect: UIBlurEffect) -> UIVisualEffectView {
        var vibrancyEffectView = UIVisualEffectView(frame: CGRectMake(0, 0, bounds.width - posterWidth, bounds.height))
        vibrancyEffectView.effect = UIVibrancyEffect(forBlurEffect: blurEffect)
        
        let titleHeight = addTitle(&vibrancyEffectView)
        addDate(&vibrancyEffectView, offset: titleHeight)
        addRateStars(&vibrancyEffectView)
        addRateLabel(&vibrancyEffectView)
        addVotesCount(&vibrancyEffectView)
        
        return vibrancyEffectView
    }
    
    func addTitle(inout parent: UIVisualEffectView) -> CGFloat {
        let view = UILabel(frame: CGRectMake(margin, margin, bounds.width - posterWidth - 2 * margin, 36))
        view.numberOfLines = 2
        view.font = UIFont(name: "Helvetica Neue", size: 14)
        view.text = item.representTitle
        view.sizeToFit()
        
        parent.contentView.addSubview(view)
        
        return view.bounds.height
    }
    
    func addDate(inout parent: UIVisualEffectView, offset: CGFloat) {
        let view = UILabel(frame: CGRectMake(margin, 4 + margin + offset, bounds.width - posterWidth - 2 * margin, 18))
        view.font = UIFont(name: "Helvetica Neue", size: 12)
        view.text = item.representDescription
        view.sizeToFit()
        
        parent.contentView.addSubview(view)
    }
    
    func addRateStars(inout parent: UIVisualEffectView) {
        let height: CGFloat = 18
        let view = UIView(frame: CGRectMake(margin, bounds.height - height - 22, bounds.width - posterWidth - 2 * margin, height))
        let size: CGFloat = 12
        for i in 0..<10 {
            let star = UIImageView(frame: CGRectMake(CGFloat(i) * (size + 1), 3, size, size))
            star.image = UIImage(res: Double(i) < round(item.voteAverage ?? 0.0) ? .StarFilled : .Star)
                .imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            view.addSubview(star)
        }
        
        parent.contentView.addSubview(view)
    }
    
    func addRateLabel(inout parent: UIVisualEffectView) {
        let height: CGFloat = 12
        let view = UILabel(frame: CGRectMake(margin, bounds.height - margin - height, bounds.width - posterWidth - 2 * margin, height))
        view.text = String(item.voteAverage ?? 0.0)
        view.font = UIFont(name: "Helvetica Neue", size: 12)
        
        parent.contentView.addSubview(view)
    }
    
    func addVotesCount(inout parent: UIVisualEffectView) {
        let height: CGFloat = 10
        let view = UILabel(frame: CGRectMake(margin, bounds.height - margin - height, bounds.width - posterWidth - 2 * margin, height))
        view.text = String(item.voteCount ?? 0)
        view.textAlignment = NSTextAlignment.Right
        view.font = UIFont(name: "Helvetica Neue", size: 10)
        
        parent.contentView.addSubview(view)
    }
    
}
