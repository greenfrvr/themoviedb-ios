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
    
    var padding: Int = 8
    var itemsMargin: Int = 8
    var itemHeight: Int = 128
    var backdropsDelegate: UIBackdropsDelegat?
    
    func backdropsDisplay(backdrops: [ImageInfo]){
        var x = padding
        for (pos, image) in backdrops.enumerate() {
            let width = Int(Double(itemHeight) * (image.aspectRatio ?? 1.0))
            let imageView = UIImageView(frame: CGRect(x: x, y: 0, width: width, height: itemHeight))
            imageView.sd_setImageWithURL(NSURL(string: ApiEndpoints.poster(4, image.filePath ?? "")))
            
            x += width + (pos == backdrops.count - 1 ? padding : itemsMargin)
            
            addSubview(imageView)
            itemTapDetector(imageView)
        }
        contentSize = CGSizeMake(CGFloat(x), CGFloat(itemHeight))
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
