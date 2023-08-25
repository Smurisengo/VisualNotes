import SwiftUI
import CoreData

struct TagPromptView: View {
    @FetchRequest(
        entity: ImageData.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "isScreenshot = true AND isTagged = false AND creationDate > %@", UserDefaults.standard.object(forKey: "PreviousLaunchDate") as! NSDate)
    ) var untaggedScreenshots: FetchedResults<ImageData>

    @Binding var state: AppState
    @Binding var screenshots: [UIImage]

    var body: some View {
        if untaggedScreenshots.count > 0 {
            // Prompt view for tagging screenshots
            ZStack {
                        // Semi-transparent background
                        Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)
                        
                        // Prompt content
                        VStack(spacing: 20) {
                            Text("You have \(untaggedScreenshots.count) new screenshots.")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()

                            Text("Do you want to tag them?")
                                .font(.title)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 50) {
                                Button("Yes", action: {
                                    print("TagPromptView: 'Yes' button pressed.")
                                    self.screenshots = untaggedScreenshots.map { CoreDataManager.loadImageFromAssetIdentifier($0.screenshotIdentifier!) }
                                    state = .tagging
                                })
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule())

                                Button("No", action: {
                                    // No new screenshots to tag, navigate to RecentNotesView
                                    state = .recentNotes
                                })
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            }
                        }
                    }
                
        } else {
            // No new screenshots to tag
            Text("").onAppear {
                state = .recentNotes
            }
        }
    }
}
