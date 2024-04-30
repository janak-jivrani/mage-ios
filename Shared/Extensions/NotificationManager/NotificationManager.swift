

import FirebaseCore
import FirebaseMessaging
import UserNotifications

protocol NotificationManagerDelegate {
    func didReceiveNotificationToken(token: String)
}

class NotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var delegate: NotificationManagerDelegate?
    private lazy var pushNotificationOption: UNNotificationPresentationOptions = {
        if #available(iOS 14.0, *) {
            return [.alert, .banner, .sound]
        } else {
            return [.alert, .sound]
        }
    }()
    
    func registerForPushNotifications() {
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
        updateFirestorePushTokenIfNeeded()
    }
    
    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            delegate?.didReceiveNotificationToken(token: token)
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirestorePushTokenIfNeeded()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let data = notification.request.content.userInfo
        print("Notification Data: \(data)")
        completionHandler(pushNotificationOption)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let data = response.notification.request.content.userInfo
        print("Notification Data: \(data)")
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        print("Notification Data New", data)
    }
    
}
