import SwiftUI
import CoreLocation

struct CameraView: View {
    @Binding var state: AppState
    @Binding var image: UIImage?
    @Binding var locationName: String?
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    @Binding var timestamp: Date?
    @StateObject private var locationManager = LocationManager()
    @State private var showingImagePicker = false

    var body: some View {
        VStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: self.$image, state: self.$state, locationName: self.$locationName, latitude: self.$latitude, longitude: self.$longitude, timestamp: self.$timestamp, locationManager: locationManager)
        }
        .onAppear {
            NotificationManager.requestNotificationPermission { granted in
                if granted {
                    print("Notification permissions granted.")
                } else {
                    print("Notification permissions denied.")
                }
            }
            self.showingImagePicker = true
        }
   
    }


    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        @Binding var state: AppState
        @Binding var locationName: String?
        @Binding var latitude: Double?
        @Binding var longitude: Double?
        @Binding var timestamp: Date?
        var locationManager: LocationManager

        func makeCoordinator() -> Coordinator {
            Coordinator(state: $state, image: $image, locationName: $locationName, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, locationManager: locationManager)
        }

        func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
            }
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            @Binding var image: UIImage?
            @Binding var state: AppState
            @Binding var locationName: String?
            @Binding var latitude: Double?
            @Binding var longitude: Double?
            @Binding var timestamp: Date?
            @Environment(\.presentationMode) var presentationMode
            var parentLocationManager: LocationManager

            init(state: Binding<AppState>, image: Binding<UIImage?>, locationName: Binding<String?>, latitude: Binding<Double?>, longitude: Binding<Double?>, timestamp: Binding<Date?>, locationManager: LocationManager) {
                _state = state
                _image = image
                _locationName = locationName
                _latitude = latitude
                _longitude = longitude
                _timestamp = timestamp
                self.parentLocationManager = locationManager
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let uiImage = info[.originalImage] as? UIImage {
                    image = uiImage
                    state = .tagging

                    if let location = parentLocationManager.internalLocationManager.location {
                        latitude = location.coordinate.latitude
                        longitude = location.coordinate.longitude
                        timestamp = Date()

                        let geocoder = CLGeocoder()
                        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                            if let placemark = placemarks?.first {
                                self.locationName = placemark.locality ?? placemark.administrativeArea ?? placemark.country
                            }
                        }
                    }
                }
                presentationMode.wrappedValue.dismiss()
            }

            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                if CoreDataManager.shared.hasNewScreenshots() {
                    state = .recentNotes
                } else {
                    state = .recentNotes
                }
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
