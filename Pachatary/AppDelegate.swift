import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                        [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        setupUI()

        let HAS_RUN_BEFORE_KEY = "has_run_before"
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: HAS_RUN_BEFORE_KEY) == false {
           
            AppDataDependencyInjector.authStorageRepository.removeAll()
            
            userDefaults.set(true, forKey: HAS_RUN_BEFORE_KEY)
            userDefaults.synchronize()
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()

        FirebaseApp.configure()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let urlPath = url.pathComponents[1]
        if urlPath == "people" {
            let thirdPath = url.pathComponents[3]
            if thirdPath == "login" {
                let token = url.query!.replacingOccurrences(of: "token=", with: "")
                rootViewController.navigateToLogin(token: token)
            }
        }
        else if urlPath == "profiles" {
            let username = url.pathComponents[2]
            rootViewController.navigateToProfileRouter(username)
        }
        else if urlPath == "experiences" {
            let experienceShareId = url.pathComponents[2]
            rootViewController.navigateToExperienceRouter(experienceShareId)
        }
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let url = userActivity.webpageURL!
            if url.pathComponents[1] == "e" {
                rootViewController.navigateToExperienceRouter(url.pathComponents[2])
            }
            else if url.pathComponents[1] == "p" {
                rootViewController.navigateToProfileRouter(url.pathComponents[2])
            }
            else if url.path == "/redirects/people/me/login" || url.path == "/people/me/login" {
                let token = url.query!.replacingOccurrences(of: "token=", with: "")
                rootViewController.navigateToLogin(token: token)
            }
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate {

    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    var rootViewController: RootViewController {
        return window!.rootViewController as! RootViewController
    }

    private func setupUI() {
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = UIColor.themeGreen

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: UIControlState.highlighted)

        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().backgroundColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

        setupButtonsDesign()
    }
}
