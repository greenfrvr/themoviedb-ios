//
//  ViewController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import AFNetworking

class ViewController: UIViewController, RequestTokenLoader {

    //MARK: Properties
    var requestToken: String = ""
    
    //MARK: Outlets
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //MARK: Actions
    @IBAction func signInClick(sender: UIButton) {
        print("Sign in button clicked")
        
        if let login = loginField.text, password = passwordField.text {
            if login.isEmpty {
                showInputAlert("Login is missing")
            }
            else if password.isEmpty {
                showInputAlert("Password is missing")
            }
            else {
                print("login - \(login), password - \(password)")
            }
        } else {
            print("Input problem")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRequestToken()
    }
    
    func loadRequestToken(){
        let token = SessionCache.restoreToken()
        if let t = token {
            print("Token restored:\n \(t.requestToken!)")
            requestToken = t.requestToken!
        } else {
            MovieApiManager.loadToken(self)
        }
    }
    
    func tokenLoadedSuccessfully(token: Token) -> Void {
        print("Token loaded:\n \(token.requestToken)")
        SessionCache.save(token)
        requestToken = token.requestToken!
    }
    
    func tokenLoadingFailed(error: NSError) -> Void {
        print(error)
    }
    
    func showInputAlert(message: String){
        let alert: UIAlertView = UIAlertView.init(title: "Warning", message: message, delegate: nil, cancelButtonTitle: "Got it")
        alert.show()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
}

