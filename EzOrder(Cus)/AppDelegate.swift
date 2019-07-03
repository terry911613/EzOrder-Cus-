//
//  AppDelegate.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import AdSupport
import TPDirect
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            
            // from UNUserNotificationCenterDelegate
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        TPDSetup.setWithAppId(13543, withAppKey: "app_86RZyP9vQAmMILzjRTItsICOGh0gRPjP6mwxB2foTg5d92nti4GARBfw9SKg", with: .sandBox)
        let IDFA = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        TPDSetup.shareInstance().setupIDFA(IDFA)
        TPDSetup.shareInstance().serverSync()
        
        // from MessagingDelegate
        Messaging.messaging().delegate = self
        Messaging.messaging().subscribe(toTopic: "advertisement") { error in
            print("Subscribed to advertisement topic")
        }
        
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any], let resID = notification["resID"] as? String {
            let notificationName = Notification.Name("receiveAPNS")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["resID": resID])
            }
            
//            let apns = notification["aps"] as? [String: AnyObject]
//            let resID = apns!["resID"] as? String
//
//            let notificationName = Notification.Name("receiveAPNS")
//            DispatchQueue.asynca
//            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["resID": resID])
            
        }
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //        var tokenString = ""
        //        for byte in deviceToken {
        //            let hexString = String(format: "%02x", byte)
        //            tokenString += hexString
        //        }
        Messaging.messaging().apnsToken = deviceToken
        
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let resID = userInfo["resID"] as? String {

            
            if let topVC = UIApplication.topViewController() {
                if let searchNav = topVC.tabBarController?.viewControllers?[1] as? UINavigationController {
                    searchNav.popToRootViewController(animated: false)
                    let searchStoryboard: UIStoryboard = UIStoryboard(name: "Search", bundle: nil)
                    let storeShowVC = searchStoryboard.instantiateViewController(withIdentifier: "storeShowVC") as! StoreShowViewController
                    storeShowVC.resID = resID
                    storeShowVC.enterFromFavorite = true
                    topVC.tabBarController?.selectedIndex = 1
                    searchNav.pushViewController(storeShowVC, animated: true)
                }
            }
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let tabBar = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
//            tabBar.selectedIndex = 1
//            let nav = tabBar.selectedViewController as! UINavigationController
//            let searchVC = nav.topViewController as! SearchViewController
//            let storeShowVC = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "storeShowVC") as! StoreShowViewController
//            storeShowVC.resID = resID
//            storeShowVC.enterFromFavorite = true
//            self.window?.rootViewController?.dismiss(animated: false, completion: { self.window?.rootViewController = tabBar })
//            searchVC.show(storeShowVC, sender: searchVC)
//            window?.makeKeyAndVisible()
        }
        completionHandler()
    }
}

