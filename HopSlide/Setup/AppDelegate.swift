import UIKit
import Firebase
import UserNotifications
import GoogleMobileAds
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    let gcmMessageIDKey = "gcm.Message_ID"
    var window: UIWindow?

    // MARK: - Application Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase configuration
        FirebaseApp.configure()

        // Notification setup
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
        application.registerForRemoteNotifications()
        FirebaseMessaging.Messaging.messaging().delegate = self

        // User Defaults setup for ads and high score
        let defaults = UserDefaults.standard
        defaults.register(defaults: ["adsOrNot": "yes", "highscore": 0])

        // AdMob configuration
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Pause ongoing tasks and timers
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save user data and state
        let defaults = UserDefaults.standard
        if let highscore = Int(defaults.string(forKey: "highscore")!) {
            if GameViewController.tempBestScore.temporaryBestScore >= highscore {
                defaults.set(GameViewController.tempBestScore.temporaryBestScore, forKey: "highscore")
                defaults.synchronize()
            }
        }

        if musicPlayer.paused {
            defaults.set(true, forKey: "musicIsPaused")
            defaults.synchronize()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Prepare to transition to active state
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart tasks that were paused or not yet started
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Perform tasks when application is about to terminate
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        // Handle foreground notification
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        return [[.alert, .sound]]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // Handle notification response
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Receive Firebase registration token
        print("Firebase registration token: \(String(describing: fcmToken))")
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: ["token": fcmToken ?? ""])
    }
}
