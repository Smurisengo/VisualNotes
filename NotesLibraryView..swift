import SwiftUI

struct NotesLibraryView: View {
    @State private var searchTerm = ""
    @FetchRequest(entity: ImageData.entity(), sortDescriptors: []) var allImages: FetchedResults<ImageData>

    var images: [ImageData] {
        if searchTerm.isEmpty {
            return allImages.map { $0 }
        } else {
            let filteredImages = allImages.filter { image in
                image.tags?.contains(where: { tag in
                    (tag as? Tag)?.text?.localizedCaseInsensitiveContains(searchTerm) ?? false
                }) ?? false
                || image.recognizedText?.localizedCaseInsensitiveContains(searchTerm) ?? false
                || image.recognizedObjects?.split(separator: ",").contains(where: { object in
                    object.trimmingCharacters(in: .whitespaces).localizedCaseInsensitiveContains(searchTerm)
                }) ?? false
            }
            return filteredImages
        }
    }


    var body: some View {
        VStack {
            // Search bar
            TextField("Search", text: $searchTerm)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            // Grid of images
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(images, id: \.self) { image in
                        NavigationLink(destination: NoteView(image: image)) {
                            ZStack(alignment: .bottomLeading) {
                                if image.isScreenshot {
                                    Image(uiImage: CoreDataManager.loadImageFromAssetIdentifier(image.screenshotIdentifier ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .center)
                                        .cornerRadius(8)
                                } else {
                                    Image(uiImage: CoreDataManager.loadImageFromDiskWith(fileName: image.filePath ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .center)
                                        .cornerRadius(8)
                                }
                                
                                // Overlay tag on the bottom-left corner
                                if let firstTag = (image.tags?.allObjects as? [Tag])?.first {
                                    HStack {
                                        Text(firstTag.text ?? "")
                                        if image.tags?.count ?? 0 > 1 {
                                            Text("+\(image.tags?.count ?? 0 - 1)")
                                        }
                                    }
                                    .padding(5)
                                    .background(Color.gray.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .padding(5)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("All my notes")
    }
}
