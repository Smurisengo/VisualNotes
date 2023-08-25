import SwiftUI
import CoreData
import Photos

struct TaggingView: View {
    @State private var tag = ""
    @Binding var state: AppState
    @FetchRequest(entity: Tag.entity(), sortDescriptors: []) var existingTags: FetchedResults<Tag>
    var images: [UIImage]
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    var timestamp: Date?
    
    @State private var currentIndex = 0
    @State private var showSuccess = false

    var body: some View {
        VStack {
            Spacer() // Pushes content below to the bottom
            
            // Display Image (with Loading Animation)
            Image(uiImage: images[currentIndex])
                .resizable()
                .scaledToFit()
                .padding()
                .onAppear {
                    print("Rendering TaggingView with tag: \(tag) and image: \(images[currentIndex])")
                }
            
            // Tag Input
            TextField("Enter a tag", text: $tag)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20) // Increased padding
            
            // Existing Tags Scrollable Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(filteredTags, id: \.self) { tag in
                        Button(action: {
                            self.tag = tag.text ?? ""
                        }) {
                            Text(tag.text ?? "")
                                .padding(.horizontal, 20) // Increased padding
                                .background(Color.secondary.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 5)
                    }
                }
            }
            .padding(.bottom)
            
            // Submit Button (with Gradient Background)
            Button(action: {
                let filePath = saveImageToDisk(image: images[currentIndex])
                let locationCoordinates = CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitude ?? 0)
                CoreDataManager.shared.saveImage(filePath: filePath, tags: [tag], locationName: locationName, locationCoordinates: locationCoordinates, timestamp: timestamp)
                
                // Show success animation/message
                withAnimation {
                    showSuccess = true
                }
                
                // Hide success animation/message after 0.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showSuccess = false
                    }
                    
                    // Perform navigation or further actions here
                    state = .recentNotes
                }
            }) {
                Text("Submit")
                    .padding()
                    .foregroundColor(.white)
                    .font(.system(size: 18)) // Adjusted font size
                    .frame(maxWidth: .infinity) // Full-width button
                    .background(LinearGradient(gradient: Gradient(colors: [.blue, Color("Primary")]), startPoint: .leading, endPoint: .trailing)) // Gradient background
                    .cornerRadius(10) // Rounded corners
                    .shadow(radius: 5) // Shadow effect
            }
            .padding(.bottom)
            
            // Floating Success Icon Animation (Checkmark Icon)
            if showSuccess {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 40))
                    .offset(y: -20) // Adjust the vertical offset
                    .transition(AnyTransition.opacity.animation(.easeInOut))
            }
        }
    }

    var filteredTags: [Tag] {
        if tag.isEmpty {
            return Array(existingTags)
        } else {
            return existingTags.filter { $0.text?.lowercased().hasPrefix(tag.lowercased()) ?? false }
        }
    }
}
