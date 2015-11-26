//
//  ViewController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class SignInController: UIViewController, AuthenticationDelegate {

    var authManager: AuthenticationManager?
    
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBAction func signInClick(sender: UIButton) {
        if let login = loginField.text, password = passwordField.text {
            if login.isEmpty {
                showAlert("Please fill required fields", "Login is missing", "OK, Got it")
            } else if password.isEmpty {
                showAlert("Please fill required fields", "Password is missing", "OK, Got it")
            } else {
                loadingIndicator.startAnimating()
                authManager?.validateRequestToken(login, password)
            }
        } else {
            print("Input problem")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Cache.clearSessionIfNeeded()
        
        if let session = Cache.restoreSession() {
            print("Session restored:\n \(session)")
            moveToMainController()
        } else {
            authManager = AuthenticationManager()
            authManager?.delegate = self
            authManager?.loadRequestToken()
            prepareViews()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        appearAnimation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        authManager?.delegate = nil
        authManager = nil
    }
    
    func sessionCreatedSuccessfully(session: Session) {
        loadingIndicator.stopAnimating()

        moveToMainController()
    }
    
    func tokenValidatedSuccessfully(token: Token) {
        print("Token validated:\n \(token.requestToken!)")
        authManager?.createSession()
    }
    
    func tokenLoadedSuccessfully(token: Token) {
        print("Token loaded")
    }
    
    func tokenLoadingFailed(error: NSError) {
        handleError(error)
    }
    
    func tokenValidationFailed(error: NSError) {
        handleError(error)
    }
    
    func sessionCreationFailed(error: NSError) {
        handleError(error)
    }

    func handleError(error: NSError) {
        loadingIndicator.stopAnimating()
        
        if let error = error.apiError {
            if error.statusCode == 30 || error.statusCode == 32 {
                showAlert("Invalid login and/or password", "Check your sign-in data", "OK")
            } else {
                showAlert("Something went wrong", "Please come back to app again later", "OK")
            }
            error.printError()
        }
    }
    
    func moveToMainController() {
        let mainController = self.storyboard?.instantiateViewControllerWithIdentifier("MainContentControllerID") as! UITabBarController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainController
    }
    
    func appearAnimation() {
        let width = view.bounds.width
        loginField.center.x -= width
        passwordField.center.x -= width
        signInButton.alpha = 0
        
        UIView.animateWithDuration(0.4) { self.loginField.center.x += width }
        UIView.animateWithDuration(0.4, delay: 0.15) { self.passwordField.center.x += width }
        UIView.animateWithDuration(0.8, delay: 0.4) { self.signInButton.alpha += 1 }
        UIView.animateWithDuration(0.4) { self.appNameLabel.transform = CGAffineTransformMakeScale(1,1) }
    }
    
    func prepareViews() {
        loginField.layer.addSublayer(bottomLineLayer())
        passwordField.layer.addSublayer(bottomLineLayer())
        appNameLabel.transform = CGAffineTransformMakeScale(0, 0)
    }
    
    func bottomLineLayer() -> CALayer {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, CGRectGetHeight(loginField.frame) - 1, CGRectGetWidth(loginField.frame), 1.0);
        bottomBorder.backgroundColor = UIColor.rgb(6, 117, 255).CGColor
        return bottomBorder
    }
}

