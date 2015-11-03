//
//  ListInfoController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/3/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class ListInfoController: UIViewController {
    
    //MARK: Properties
    var argList: ListInfo!
    
    //MARK: Actions
    @IBAction func backButtonClick(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Controller lifecycle
    override func viewDidLoad() {
        if let list = argList {
            print("List loaded: \(list.listId!)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.title = argList.listName
    }
    
    override func viewDidAppear(animated: Bool) {
        if let list = argList {
            print("List loaded: \(list.listId!)")
        }
    }
    
}
