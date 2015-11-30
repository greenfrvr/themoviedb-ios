//
//  DetailsProtocol.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/26/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

protocol DetailsNavigation {
    
    var id: String? { get set }
    static var controllerId: String { get }
    static var navigationId: String { get }
    
    static func presentControllerWithNavigation(presenter: UIViewController, id: String?)
    
    static func presentControllerModally(presenter: UIViewController, id: String?)
    
}

extension DetailsNavigation {
    
    static func presentControllerWithNavigation(presenter: UIViewController, id: String?) {
        let navigationController = UIStoryboard(name: "Details", bundle: nil).instantiateViewControllerWithIdentifier(navigationId) as! UINavigationController
        var controller = navigationController.topViewController as! DetailsNavigation
        controller.id = id
        presenter.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    static func presentControllerModally(presenter: UIViewController, id: String?) {
        var controller = presenter.storyboard?.instantiateViewControllerWithIdentifier(controllerId) as! DetailsNavigation
        controller.id = id
        presenter.navigationController?.pushViewController(controller as! UIViewController, animated: true)
    }

}