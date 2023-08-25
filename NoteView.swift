import SwiftUI

struct NoteView: View {
    var image: ImageData?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Image Display
                if image?.isScreenshot == true {
                    Image(uiImage: CoreDataManager.loadImageFromAssetIdentifier(image?.screenshotIdentifier ?? ""))
                        .resizable()
                        .aspectRatio(contentMode: .fit)  // Maintain original aspect ratio
                } else {
                    Image(uiImage: CoreDataManager.loadImageFromDiskWith(fileName: image?.filePath ?? ""))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }

                // Recognized Text (for screenshots)
                if image?.isScreenshot == true, let recognizedText = image?.recognizedText, !recognizedText.isEmpty {
                    Text("Recognized Text:")
                        .font(.headline)
                        .padding(.top, 10)
                    Text(recognizedText)
                        .font(.body)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                // Tags Display
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tags:")
                        .font(.headline)
                        .padding(.top, 10)
                    ForEach(image?.tags?.allObjects as? [Tag] ?? [], id: \.self) { tag in
                        Text(tag.text ?? "")
                            .font(.caption)
                            .padding(5)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(5)
                    }
                    
                    //Location Display
                    
                    if image?.isScreenshot == false, let locationName = image?.locationName {
                                       Text("Location:")
                                           .font(.headline)
                                           .padding(.top, 10)
                                       Text(locationName)
                                           .font(.body)
                                           .padding(.horizontal)
                                   }
                    
                    // Recognized Objects Display
                    if let recognizedObjects = image?.recognizedObjects, !recognizedObjects.isEmpty {
                        Text("Recognized Objects:")
                            .font(.headline)
                            .padding(.top, 10)
                        ForEach(recognizedObjects.split(separator: ","), id: \.self) { object in
                            Text(object.trimmingCharacters(in: .whitespaces))
                                .font(.caption)
                                .padding(5)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(5)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Note")
    }
}
