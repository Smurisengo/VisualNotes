struct Coordinate: Hashable {
    let latitude: Double
    let longitude: Double
}

struct StoredLocation {
    let id: String
    let latitude: Double
    let longitude: Double
    let notesCount: Int
}
