import Swift
import SwiftUI
import UIKit
import Photos

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let isFirstLaunch = UserDefaults.standard.bool(forKey: "IsFirstLaunch")
        if !isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "IsFirstLaunch")
        } else {
            // Retrieve the last stored launch date
            let currentLastLaunchDate = UserDefaults.standard.object(forKey: "LastLaunchDate") as? Date

            // Store this date as the previous launch date
            if let currentLastLaunchDate = currentLastLaunchDate {
                UserDefaults.standard.set(currentLastLaunchDate, forKey: "PreviousLaunchDate")
            }

            // Store the current date as the new last launch date
            UserDefaults.standard.set(Date(), forKey: "LastLaunchDate")

            print("Stored last launch date: \(UserDefaults.standard.object(forKey: "LastLaunchDate") ?? "Not Set")")
            print("Stored previous launch date: \(UserDefaults.standard.object(forKey: "PreviousLaunchDate") ?? "Not Set")")

            print("Requesting authorization")
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    print("Authorization granted")
                    CoreDataManager.shared.fetchAndSaveScreenshots()
                case .denied:
                    print("Authorization denied")
                case .restricted:
                    print("Authorization restricted")
                case .notDetermined:
                    print("Authorization not determined")
                case .limited:
                    print("Authorization limited")
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }

        // Create the SwiftUI view that provides the window contents.
        let rootView = ContentView()

        // Use a UIHostingController as window root view controller.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: rootView)
        self.window = window
        window.makeKeyAndVisible()

        return true
    }

    // ... rest of AppDelegate code ...
}
