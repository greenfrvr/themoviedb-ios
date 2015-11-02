//
//  ViewController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit
import AFNetworking

class ViewController: UIViewController, AuthenticationDelegate {

    //MARK: Properties
    var requestToken: String = ""
    var moveiApi: MovieApiManager!
    
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
                validateToken(login, password)
            }
        } else {
            print("Input problem")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moveiApi = MovieApiManager(delegate: self)
        loadRequestToken()
    }
    
    func loadRequestToken(){
        let token = SessionCache.restoreToken()
        if let t = token {
            print("Token restored:\n \(t.requestToken!)")
            requestToken = t.requestToken!
        } else {
            moveiApi.loadToken()
        }
    }
    
    func tokenLoadedSuccessfully(token: Token) {
        print("Token loaded:\n \(token.requestToken!)")
        SessionCache.save(token)
        requestToken = token.requestToken!
    }
    
    func tokenLoadingFailed(error: NSError) {
        print(error)
    }
    
    func tokenValidatedSuccessfully(token: Token) {
        print("Token validated:\n \(token.requestToken!)")
        SessionCache.save(token)
        requestToken = token.requestToken!
    }
    
    func tokenValidationFailed(error: NSError) {
        print(error)
    }
    
    func sessionLoadedSuccessfully() {
        
    }
    
    func sessionLoadingFailed() {
        
    }
    
    func validateToken(log: String, _ pass: String){
        moveiApi.validateToken(requestToken, login: log, password: pass)
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

