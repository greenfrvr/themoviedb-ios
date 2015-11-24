//
//  DetailsActionAlert.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/16/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class DetailsActionAlert {
    
    private(set) weak var controller: UIViewController?
    
    init(controller: UIViewController?){
        self.controller = controller
    }
    
    func present(completion: (() -> Void)? = nil) {
        controller?.presentViewController(prepareAlert(), animated: true, completion: completion)
    }
    
    func prepareAlert() -> UIAlertController {
        let (title, message) = alertData()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        for action in defineActions() {
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Back", comment: ""), style: .Cancel, handler: nil))
        
        return alert
    }
    
    func alertData() -> (String, String) {
        assert(false, "Should be overriden to provide specified alert title and message")
    }
    
    func defineActions() -> [UIAlertAction] {
        assert(false, "Should be overriden to provide specified actions")
    }
}