//
//  AppDelegate.swift
//  Scover
//
//  Created by Mobile App Dev on 4/17/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import HockeySDK
import UserNotifications
import FBSDKCoreKit
import GoogleSignIn
import GGLCore
import HandyJSON
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    static var window: UIWindow? {
        if let s = UIApplication.shared.delegate as? AppDelegate {
            return s.window
        }
        return nil
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Position.shared().start()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions ?? [:])
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        BITHockeyManager.shared().configure(withIdentifier: "51ce25a8116f455192b6ea8bf439f383")
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
        
        GMSServices.provideAPIKey("AIzaSyAgv9zxxIjrykAIjV8Esuk0mincji4CNSg")
        
        UINavigationBar.appearance().isTranslucent   = false
        UINavigationBar.appearance().backgroundColor = .main
        UINavigationBar.appearance().barTintColor    = .main
        UINavigationBar.appearance().tintColor       = .white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.josefinSansBold(20.0)]
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UINavigationController(rootViewController: (Settings.authToken?.characters.count ?? 0 > 0) ? MainVC() : StartVC())
        self.window?.makeKeyAndVisible()

        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return check(app: application, url: url, source: sourceApplication, ann: annotation)
    }
    
    private func check(app: UIApplication, url: URL, source: String?, ann: Any?) -> Bool {
        if let source = source, let ann = ann {
            switch true {
            case GIDSignIn.sharedInstance().handle(url, sourceApplication: source, annotation: ann): return true
            case FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: source, annotation: ann): return true
            default: break
            }
        }
        return false
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        if !AppDelegate.isPushEnabled(token: false) {
            Settings.pushTurn = Settings.pushTurn || (Settings.pushToken?.characters.count ?? 0) > 0
            AppDelegate.disableNotifications()
        } else if Settings.pushTurn {
            AppDelegate.enableNotifications()
        }
    }
    
    static func logout() {
        disableNotifications()
        Settings.clear()
        self.window?.rootViewController?.dismiss(animated: true)
        if let nc = self.window?.rootViewController as? UINavigationController {
            nc.setViewControllers([StartVC()], animated: true)
        } else {
            self.window?.rootViewController = UINavigationController(rootViewController: StartVC())
        }
    }
    
    static func resetPushToken() {
        disableNotifications()
        
        let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            enableNotifications()
        }
    }
    
    static func disableNotifications() {
        Settings.pushToken = nil
        UIApplication.shared.unregisterForRemoteNotifications()
        NotificationCenter.default.post(name: .PushDisabled, object: nil)
    }
    
    static func isPushEnabled(token: Bool = true) -> Bool {
        if let types = UIApplication.shared.currentUserNotificationSettings?.types {
            if !token {
                return (types.contains(.alert) || types.contains(.badge) || types.contains(.sound))
            }
            return (types.contains(.alert) || types.contains(.badge) || types.contains(.sound)) && (Settings.pushToken?.characters.count ?? 0) > 0
        }
        return false
    }
    
    static func enableNotifications() {
        let app: UIApplication = UIApplication.shared
        let center = UNUserNotificationCenter.current()
        center.delegate = (app.delegate as? AppDelegate)
        center.requestAuthorization(options: [UNAuthorizationOptions.alert, UNAuthorizationOptions.badge, UNAuthorizationOptions.sound], completionHandler: { (granted, error) in
            if error == nil && granted {
                app.registerForRemoteNotifications()
            } else {
                NotificationCenter.default.post(name: .PushEnableError, object: error)
            }
        })
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars  = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        Settings.pushToken = tokenString
        Settings.pushTurn  = false
        NotificationCenter.default.post(name: .PushEnabled, object: nil)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationCenter.default.post(name: .PushEnableError, object: error)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound]);
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Position.shared().start()
    }
    
    static func open(url: String?) {
        if let url = URL(string: url ?? ""), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
