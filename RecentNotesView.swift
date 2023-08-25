import SwiftUI

struct RecentNotesView: View {
    @Binding var state: AppState
    @FetchRequest(entity: ImageData.entity(),
                  sortDescriptors: [NSSortDescriptor(key: "creationDate", ascending: false)])
    var images: FetchedResults<ImageData>
    
    // Add a variable to track if there are untagged screenshots
    var hasUntaggedScreenshots: Bool {
        images.contains { !$0.isTagged && $0.isScreenshot }
    }

    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: NotesLibraryView()) {
                Text("All My Captures")
                    .font(.headline)
                    .padding(.bottom, 10)
            }
            
            NavigationLink(destination: TagsView()) {
                Text("My Tags")
                    .font(.headline)
                    .padding(.bottom, 10)
            }
            
            // Badge for untagged screenshots prompt
            if hasUntaggedScreenshots {
                Button(action: {
                    // Present the prompt
                    state = .tagPrompt
                }) {
                    HStack {
                        Image(systemName: "photo")
                        Text("Check New Screenshots")
                            .font(.caption)
                    }
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.primary))
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
            
            ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                                ForEach(Array(images.prefix(9)), id: \.self) { image in
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
                                                .background(Color.gray.opacity(0.7))
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
                    .navigationTitle("Recent Notes")
                }
            }


            

