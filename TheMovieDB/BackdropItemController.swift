//
//  BackdropItemController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/11/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class BackdropItemController: UIViewController, UIGestureRecognizerDelegate {
    //MARK: Properties
    var backdropData: ImageInfo!
    var x = CGFloat(), y = CGFloat();
    
    //MARK: Outlets
    @IBOutlet var backdropImage: UIImageView!
    
    
    override func viewDidAppear(animated: Bool) {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "dismiss:")
        panRecognizer.cancelsTouchesInView = false
        panRecognizer.delegate = self
        self.view.addGestureRecognizer(panRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        backdropImage.sd_setImageWithURL(NSURL(string: ApiEndpoints.poster(4, backdropData.filePath ?? "")))
        
        backdropImage.frame.size = CGSizeMake(backdropImage.frame.size.width, CGFloat(Double(backdropImage.frame.width) * backdropData.aspectRatio!))
    }
    
    var p = CGPoint()
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let point = touch.locationInView(self.view)
            if gesture.state == UIGestureRecognizerState.Began {
                p = point
            } else if gesture.state == UIGestureRecognizerState.Possible {
                let delta = CGPoint(x: p.x - point.x, y: p.y - point.y)
                p = point
                p1 = p

                return abs(delta.y) > abs(delta.x)
            }
        }
        
        return false
    }
    
    var p1 = CGPoint()
    func dismiss(sender: UIGestureRecognizer){
        print("dismiss")
        let point = sender.locationInView(self.view)
        let delta = CGPoint(x: p1.x - point.x, y: p1.y - point.y)
        p1 = point

        backdropImage.center.y -= delta.y
    }
}
