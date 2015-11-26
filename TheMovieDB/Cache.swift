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
            print("Saving session id \(session.sessionToken ?? "")")
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

    private static func needsSessionCaching() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("session_caching_enabled")
    }

    static func saveUsername(username: String?) {
        NSUserDefaults.standardUserDefaults().setObject(username, forKey: "account")
    }
    
    static func saveAccount(account: Account) {
        saveUsername(account.username)
        
        guard let url = NSURL(docsFilePath: "account.archive") else {
            print("Cannot save account info")
            return
        }
        
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(account, forKey: "account")
        archiver.finishEncoding()
        data.writeToURL(url, atomically: true)
    }
    
    static func restoreAccount() -> Account? {
        guard let url = NSURL(docsFilePath: "account.archive"), let data = NSData(contentsOfURL: url) else {
            print("Cannot restore account info")
            return nil
        }
        
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        return unarchiver.decodeObjectForKey("account") as? Account
    }
}