//
//  UIPosterView.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/12/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class UIPosterView: UIImageView {
    
    var delegate: UIPosterViewDelegate?
    var itemId: Int? {
        didSet {
            setupTapRecognizer()
        }
    }
    
    func setupTapRecognizer(){
        userInteractionEnabled = true
        gestureRecognizers?.removeAll()
        
        let recognizer = UITapGestureRecognizer(target: self, action: "posterTap")
        addGestureRecognizer(recognizer)
    }
    
    func posterTap(){
        delegate?.posterTapped(itemId)
    }
}

protocol UIPosterViewDelegate {

    func posterTapped(itemId: Int?)
    
}