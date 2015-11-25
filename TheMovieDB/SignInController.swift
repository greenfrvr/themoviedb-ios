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
    var authManager: AuthenticationManager!
    
    //MARK: Outlets
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signInButton: UIButton!
    
    //MARK: Actions
    @IBAction func signInClick(sender: UIButton) {
        if let login = loginField.text, password = passwordField.text {
            if login.isEmpty {
                showInputAlert("Login is missing")
            }
            else if password.isEmpty {
                showInputAlert("Password is missing")
            }
            else {
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
        appNameLabel.transform = CGAffineTransformMakeScale(0, 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        loginField.layer.addSublayer(bottomLine())
        passwordField.layer.addSublayer(bottomLine())

        appearAnimation()
    }
    
    func bottomLine() -> CALayer {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, loginField.frame.size.height - 1, loginField.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.rgb(6, 117, 255)?.CGColor
        return bottomBorder
    }
    
    //MARK: Session cache check
    func loadCachedSession(){
        let session = Cache.restoreSession()
        if let session = session {
            print("Session restored:\n \(session)")
            moveToMainController()
         } else {
            print("Need to create new session")
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
        loadingIndicator.stopAnimating()
        moveToMainController()
    }
    
    func tokenLoadingFailed(error: NSError) {
        print(error)
        let alert = UIAlertView(title: NSLocalizedString("Something went wrong", comment: ""), message: NSLocalizedString("Please come back to app again later", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
        alert.show()
    }
    
    func tokenValidationFailed(error: NSError) {
        print(error)
    }
    
    func sessionCreationFailed(error: NSError) {
        print(error)
    }
    
    func validateToken(login: String, _ password: String) {
        loadingIndicator.startAnimating()
        authManager.validateRequestToken(login, password)
    }

    //MARK: UI
    func showInputAlert(messageKey: String) {
        let title = NSLocalizedString("Please fill required fields", comment: "")
        let message = NSLocalizedString(messageKey, comment: "")
        let cancelTitle = NSLocalizedString("OK, Got it", comment: "")
        
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelTitle)
        alert.show()
    }
    
    func moveToMainController() {
        let mainController = self.storyboard?.instantiateViewControllerWithIdentifier("MainContentControllerID") as! UITabBarController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainController
    }
    
    func appearAnimation() {
        loginField.center.x -= view.bounds.width
        passwordField.center.x -= view.bounds.width
        signInButton.alpha = 0
        
        UIView.animateWithDuration(0.4, animations: {
            self.loginField.center.x += self.view.bounds.width
        })
        UIView.animateWithDuration(0.4, delay: 0.15, options: [], animations: {
            self.passwordField.center.x += self.view.bounds.width
            }, completion: nil)
        UIView.animateWithDuration(0.8, delay: 0.4, options: [], animations: {
            self.signInButton.alpha += 1
            }, completion: nil)
        UIView.animateWithDuration(0.4) {
            self.appNameLabel.transform = CGAffineTransformMakeScale(1,1)
        }
    }
}

