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
    let movementDuration = 0.3
    let screenPart: CGFloat = 0.2
    
    var backdropData: ImageInfo!
    var dragPoint = CGPoint()
    
    //MARK: Outlets
    @IBOutlet var backdropImage: UIImageView!
    
    //MARK: Lifecycle
    override func viewDidAppear(animated: Bool) {
        setupPanRecognizer()
    }
    
    override func viewWillAppear(animated: Bool) {
        backdropImage.sd_setImageWithURL(NSURL(string: ApiEndpoints.poster(4, backdropData.filePath ?? "")))
        backdropImage.frame.size = CGSizeMake(backdropImage.frame.size.width, CGFloat(Double(backdropImage.frame.width) * backdropData.aspectRatio!))
    }
    
    //MARK: Gestures
    func setupPanRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "dismiss:")
        panRecognizer.cancelsTouchesInView = false
        panRecognizer.delegate = self
        view.addGestureRecognizer(panRecognizer)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let newPoint = touch.locationInView(self.view)
            if gesture.state == UIGestureRecognizerState.Began {
                dragPoint = newPoint
            } else if gesture.state == UIGestureRecognizerState.Possible {
                let delta = CGPoint(x: dragPoint.x - newPoint.x, y: dragPoint.y - newPoint.y)
                dragPoint = newPoint
                return 11 * abs(delta.y) > 13 * abs(delta.x)
            }
        }
        return false
    }
    
    func dismiss(sender: UIGestureRecognizer){
        if sender.state == UIGestureRecognizerState.Changed {
            let newPoint = sender.locationInView(self.view)
            let deltaY = dragPoint.y - newPoint.y
            
            backdropImage.center.y -= deltaY
            dragPoint = newPoint
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            let deltaY = backdropImage.center.y - view.center.y
            if abs(deltaY) < screenPart * view.frame.size.height {
                moveImageToCenter(deltaY)
            }
            else {
                moveImageAway(deltaY)
            }
        }
    }
    
    func moveImageToCenter(delta: CGFloat) {
        UIView.animateWithDuration(movementDuration) { self.backdropImage.center.y -= delta }
    }
    
    func moveImageAway(delta: CGFloat) {
        func sign() -> CGFloat { return delta > 0 ? 1 : -1 }
        
        UIView.animateWithDuration(movementDuration,
            animations: { self.backdropImage.center.y += sign() * self.view.center.y},
            completion: { finished in if finished { self.dismissBackrops() }
        })
    }
    
    func dismissBackrops(){
        presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
