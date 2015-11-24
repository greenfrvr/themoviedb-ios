//
//  BackdropsHorizontalView.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/11/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import SDWebImage

class UIBackdropsHorizontalView: UIScrollView {
    
    var padding: CGFloat = 8
    var itemsMargin: CGFloat = 8
    var itemHeight: CGFloat = 128
    var backdropsDelegate: UIBackdropsDelegat?
    
    func backdropsDisplay(backdrops: [ImageInfo]){
        var x: CGFloat = padding
        for (pos, image) in backdrops.enumerate() {
            let width = itemHeight * CGFloat(image.aspectRatio ?? 1.0)
            let imageView = UIImageView(frame: CGRect(x: x, y: 0, width: width, height: itemHeight))
            imageView.sd_setImageWithURL(NSURL(imagePath: image.filePath, size: 4))
            
            x += width + (pos == backdrops.count - 1 ? padding : itemsMargin)
            
            addSubview(imageView)
            itemTapDetector(imageView)
        }
        contentSize = CGSizeMake(x, itemHeight)
    }
    
    func itemTapDetector(imageView: UIImageView){
        let singleTap = UITapGestureRecognizer(target: self, action: "tapDetected:")
        singleTap.numberOfTapsRequired = 1
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
    }
    
    func tapDetected(sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView{
            backdropsDelegate?.backdropTapped(imageView.image, imageUrl: imageView.sd_imageURL().absoluteString)
        }
    }
}

protocol UIBackdropsDelegat {
    
    func backdropTapped(image: UIImage?, imageUrl: String)
}
