//
//  Cache.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import Locksmith

class Cache {
    
    static let serviceName = "movie-db"
    static let userAccount = "default_account"
    
    static func saveSession(session: Session) {
        do {
            try session.createInSecureStore()
        } catch {
            print("Caching session token is failed")
            print(error)
        }
    }
    
    static func restoreSession() -> String? {
        let data = Locksmith.loadDataForUserAccount(userAccount, inService: serviceName)
        if let data = data {
            return data["sessionId"] as? String
        }
        return nil
    }
    
    static func clearSessionIfNeeded() {
        if !needsSessionCaching() {
            do {
                try Locksmith.deleteDataForUserAccount(userAccount, inService: serviceName)
            } catch {
                print("Cannot clear session cache")
                print(error)
            }
        }
    }
    
    static func saveAccount(account: Account) {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setInteger((account.userId)!, forKey: "userId")
        prefs.setObject(account.username, forKey: "username")
        prefs.setObject(account.fullName, forKey: "fullname")
        prefs.setObject(account.gravatarHash, forKey: "gravatar")
        prefs.setObject(account.langCode, forKey: "lang")
        prefs.setObject(account.countryCode, forKey: "country")
        prefs.setBool((account.includeAdult)!, forKey: "adult")
        prefs.setObject(account.username, forKey: "account")
    }
    
    static func restoreAccount() -> Account? {
        let prefs = NSUserDefaults.standardUserDefaults()
        let id = prefs.integerForKey("userId")
        if id != 0 {
            var acc = Account()
            acc.userId = id
            acc.username = prefs.stringForKey("username")
            acc.fullName = prefs.stringForKey("fullname")
            acc.gravatarHash = prefs.stringForKey("gravatar")
            acc.langCode = prefs.stringForKey("lang")
            acc.countryCode = prefs.stringForKey("country")
            acc.includeAdult = prefs.boolForKey("adult")
            return acc
        } else {
            return nil
        }
    }
    
    private static func needsSessionCaching() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("session_caching_enabled")
    }
}