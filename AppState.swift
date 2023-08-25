import Combine

class AppState: ObservableObject {
    @Published var isTagging: Bool = false
    @Published var showTaggingView: Bool = false
    @Published var showRecentNotesView: Bool = false
}
