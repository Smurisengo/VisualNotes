import SwiftUI
import CoreLocation
import Photos
import CoreData

enum AppState: CustomStringConvertible {
    case camera
    case tagging
    case recentNotes
    case tagPrompt

    var description: String {
        switch self {
        case .camera:
            return "camera"
        case .tagging:
            return "tagging"
        case .recentNotes:
            return "recentNotes"
        case .tagPrompt:
            return "tagPrompt"
        }
    }
}

struct ContentView: View {
    @State private var image: UIImage?
    @State private var state: AppState = .camera
    @State private var untaggedScreenshots: [UIImage] = []
    @State private var locationName: String?
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var timestamp: Date?

    var body: some View {
            NavigationView {
                switch state {
                case .camera:
                    CameraView(state: $state, image: $image, locationName: $locationName, latitude: $latitude, longitude: $longitude, timestamp: $timestamp)
                case .tagging:
                    if let img = image {
                        TaggingView(state: $state, images: [img], locationName: locationName, latitude: latitude, longitude: longitude, timestamp: timestamp) // Fixed here
                    } else if !untaggedScreenshots.isEmpty {
                        TaggingView(state: $state, images: untaggedScreenshots, locationName: nil, latitude: nil, longitude: nil, timestamp: nil) // Passing nil for location-related parameters
                    } else {
                        Text("No images available for tagging.")
                    }
            case .recentNotes:
                RecentNotesView(state: $state)
            case .tagPrompt:
                TagPromptView(state: $state, screenshots: $untaggedScreenshots)
            }
        }
    }
}
