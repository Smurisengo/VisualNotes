import CoreLocation
import CoreData

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private(set) var internalLocationManager = CLLocationManager()

    override init() {
        super.init()
        self.internalLocationManager.delegate = self
        self.internalLocationManager.requestWhenInUseAuthorization()
        self.internalLocationManager.startUpdatingLocation()

        print("Location Manager initialized.")
        
        // Register regions (geofences) for stored locations
        registerGeofencesForStoredLocations()
    }

    private func registerGeofencesForStoredLocations() {
        // Fetch stored locations from CoreData
        let storedLocations = CoreDataManager.shared.fetchStoredLocationsFromCoreData()
        print("Fetched \(storedLocations.count) stored locations from CoreData.")

        // Register a geofence for each stored location
        for location in storedLocations {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = CLCircularRegion(center: coordinate, radius: 10, identifier: location.id) // Adjust radius as needed
            region.notifyOnEntry = true
            region.notifyOnExit = false
            internalLocationManager.startMonitoring(for: region)
            
            print("Registered geofence for location \(location.id) at coordinates (\(location.latitude), \(location.longitude)).")
        }
    }

    // Implement delegate methods to handle region entry/exit events
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let identifier = region.identifier
        print("Entered region with identifier \(identifier).")
        
        if let storedLocation = CoreDataManager.shared.fetchStoredLocation(by: identifier) {
            NotificationManager.triggerNotification(for: storedLocation)
            print("Triggered notification for stored location \(identifier).")
        } else {
            print("Stored location not found for identifier \(identifier).")
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // Handle region exit event if needed
        print("Exited region with identifier \(region.identifier).")
    }

    // Implement other required methods as needed
}
