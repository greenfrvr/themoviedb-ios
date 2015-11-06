//
//  ViewController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class SignInController: UIViewController, AuthenticationDelegate {

    //MARK: Properties
    var session: Session?
    var authManager: AuthenticationManager!
    
    //MARK: Outlets
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
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
                let range = password.characters.startIndex.advancedBy(3)..<password.characters.endIndex.predecessor()
                var hiddenPassword = password
                hiddenPassword.replaceRange(range, with: "*")
                print("login - \(login), password - \(hiddenPassword)")
                
                validateToken(login, password)
            }
        } else {
            print("Input problem")
        }
    }
    
    //MARK: Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCachedSession()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if session == nil {
            authManager.loadRequestToken()
        }
    }
    
    //MARK: Session cache check
    func loadCachedSession(){
        session = SessionCache.restoreSession()
        if let s = session {
            print("Session restored:\n \(s.sessionToken!)")
            moveToMainController()
         } else {
            authManager = AuthenticationManager(delegate: self)
            authManager.loadRequestToken()
        }
    }
    
    //MARK: AuthenticationDelegate
    func tokenLoadedSuccessfully(token: Token) {
        print("Token loaded:\n \(token.requestToken!)")
    }
    
    func tokenValidatedSuccessfully(token: Token) {
        print("Token validated:\n \(token.requestToken!)")
        authManager.createSession()
    }
    
    func sessionCreatedSuccessfully(session: Session) {
        print("Session created: \(session.sessionToken!)")
        SessionCache.save(session)
        loadingIndicator.stopAnimating()
        moveToMainController()
    }
    
    func tokenLoadingFailed(error: NSError) {
        print(error)
        let alert = UIAlertView(title: "Something went wrong", message: "Please come back to app again later", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func tokenValidationFailed(error: NSError) {
        print(error)
    }
    
    func sessionCreationFailed(error: NSError) {
        print(error)
    }
    
    func validateToken(login: String, _ password: String){
        loadingIndicator.startAnimating()
        authManager.validateRequestToken(login, password)
    }

    //MARK: UI
    func showInputAlert(message: String){
        let alert = UIAlertView(title: "Please fill required fields", message: message, delegate: nil, cancelButtonTitle: "OK, Got it")
        alert.show()
    }
    
    func moveToMainController(){
        let mainController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainContentController") as! UITabBarController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainController
    }
    
}

