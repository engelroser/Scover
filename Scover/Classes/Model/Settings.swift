//
//  Settings.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 29/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Foundation

class Settings {
    
    private struct Keys {
        
        static let auth: String = "auth"
        static let push: String = "push"
        static let turn: String = "turn"
        
    }
    
    struct URL {
        static let help:        String = "http://scover.today/help"
        static let report:      String = "http://scover.today/report-problem"
        static let privacy:     String = "http://scover.today/privacy-policy"
        static let terms:       String = "http://scover.today/terms-of-use"
        static let about:       String = "http://scover.today/about"
        static let inspiration: String = "http://scover.today/inspiration"
        static let base:        String = "http://scover-app.us-east-2.elasticbeanstalk.com"
    }

    static var authToken: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.auth)
        }
        set {
            let s: UserDefaults = UserDefaults.standard
            if newValue != nil {
                s.set(newValue, forKey: Keys.auth)
            } else {
                s.removeObject(forKey: Keys.auth)
            }
            s.synchronize()
        }
    }
    
    static var pushTurn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.turn)
        }
        set {
            let s: UserDefaults = UserDefaults.standard
            s.set(newValue, forKey: Keys.turn)
            s.synchronize()
        }
    }
    
    static var pushToken: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.push)
        }
        set {
            let s: UserDefaults = UserDefaults.standard
            if newValue != nil {
                s.set(newValue, forKey: Keys.push)
            } else {
                s.removeObject(forKey: Keys.push)
            }
            s.synchronize()
        }
    }
    
    static func clear() {
        Settings.authToken = nil
        Settings.pushToken = nil
    }
    
    static var profile: Profile?
    
}
