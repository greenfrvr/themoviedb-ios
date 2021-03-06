//
//  AppDelegate.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        NSUserDefaults.standardUserDefaults().registerDefaults([Settings.Account.rawValue : Settings.deaultUser, Settings.SessionCaching.rawValue : true, Settings.Language.rawValue : Settings.defaultLang])
        
        let lang = NSUserDefaults.standardUserDefaults().valueForKey(Settings.Language.rawValue) as? String
        NSUserDefaults.standardUserDefaults().setObject([lang ?? Settings.defaultLang], forKey: "AppleLanguages")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    @available(iOS 9, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        if let tabBarController = self.window?.rootViewController as? UITabBarController {
            if shortcutItem.type == "com.greenfrvr.moviedb.search" {
                tabBarController.selectedIndex = 1
                completionHandler(true)
            } else if shortcutItem.type == "com.greenfrvr.moviedb.favorite-list" {
                print("favorite list action")
                tabBarController.selectedIndex = 0
                if let controller = tabBarController.selectedViewController, id = shortcutItem.userInfo!["listId"] as? String{
                    ListDetailsController.presentControllerWithNavigation(controller, id: id)
                }
                completionHandler(true)
            }
        }
        completionHandler(false)
    }
    
    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }

}

