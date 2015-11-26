//
//  FavoritesController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/3/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class TrendsController: UIViewController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        tabBarController?.delegate = self
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if viewController == self {
            print("You're back to trends controller")
        }
    }
}
