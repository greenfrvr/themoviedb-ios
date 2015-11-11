//
//  BackdropsController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/11/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class BackdropsController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    var content = [ImageInfo]()
    
    override func viewDidLoad() {
        self.delegate = self
        self.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setViewControllers([viewControllerAtIndex(0)!], direction: .Forward, animated: true, completion: nil)
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.75)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = indexOfViewController(viewController as! BackdropItemController)

        index++
        if index == content.count {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = indexOfViewController(viewController as! BackdropItemController)

        if (index == 0) {
            return nil
        }

        index--
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> BackdropItemController? {
        if content.count == 0 || index >= content.count {
                return nil
        }
        
        let dataViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BackdropItem") as! BackdropItemController
        dataViewController.backdropData = content[index]
        return dataViewController
    }
    
    func indexOfViewController(viewController: BackdropItemController) -> Int {
        if let data = viewController.backdropData {
            return content.indexOf { $0 == data }!
        }
        return -1
    }
}
