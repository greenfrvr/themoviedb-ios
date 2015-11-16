//
//  BackdropsController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/11/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import Dollar

class BackdropsController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    //MARK: Properties
    var initialUrl: String!
    var content = [ImageInfo]()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        self.delegate = self
        self.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setViewControllers([viewControllerAtIndex(inititalIndex())!], direction: .Forward, animated: true, completion: nil)
        setupBackground()
    }
    
    //MARK: PageViewController
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = indexOfViewController(viewController as! BackdropItemController) + 1
        return index == content.count ? nil : viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = indexOfViewController(viewController as! BackdropItemController)
        return index == 0 ? nil : viewControllerAtIndex(index - 1)
    }
    
    func viewControllerAtIndex(index: Int) -> BackdropItemController? {
        if content.count == 0 || index >= content.count { return nil }
        
        let dataViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BackdropItem") as! BackdropItemController
        dataViewController.backdropData = content[index]
        return dataViewController
    }
    
    func indexOfViewController(viewController: BackdropItemController) -> Int {
        if let data = viewController.backdropData { return content.indexOf { $0 == data }! }
        return -1
    }
    
    func inititalIndex() -> Int {
        return $.findIndex(content, callback: { self.initialUrl.containsString($0.filePath!) }) ?? 0
    }
    
    //MARK: UI
    func setupBackground(){
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = UIColor.clearColor()
            
            let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            view.insertSubview(blurEffectView, atIndex: 0)
        }
        else {
            view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.75)
        }
    }
}
