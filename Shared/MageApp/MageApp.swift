//
//  MageApp.swift
//  mage-ios
//
//  Created by Kushkumar Katira on 12/10/23.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        let notificationManager = NotificationManager()
        notificationManager.delegate = self
        notificationManager.registerForPushNotifications()

        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
//        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
}

extension AppDelegate: NotificationManagerDelegate {
    
    func didReceiveNotificationToken(token: String) {
        print("FCM Token: ", token)
        UserDefaults.fcm_token = token
    }
}
