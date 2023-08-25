import UserNotifications

class NotificationManager {
    static func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Failed to request notification permissions: \(error)")
            }
            completion(granted)
        }
    }

    static func triggerNotification(for location: StoredLocation) {
        let center = UNUserNotificationCenter.current()
        
        // Create the content of the notification
        let content = UNMutableNotificationContent()
        content.title = "Visual Notes Reminder"
        content.body = "The last Time you've been here you took \(location.notesCount) Visual Notes. Tap to see them."
        content.sound = UNNotificationSound.default

        // Create a trigger based on time (can be immediate or delayed)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // Create the request with unique identifier
        let request = UNNotificationRequest(identifier: location.id, content: content, trigger: trigger)

        // Schedule the notification
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
}
