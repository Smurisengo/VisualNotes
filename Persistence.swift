import CoreData
import SwiftUI
import Photos
import Vision
import CoreLocation

var lastScreenshotFetch: Date?

class CoreDataManager {
    let persistentContainer: NSPersistentContainer
    static let shared = CoreDataManager()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "VisualNotes")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    func saveImage(filePath: String, tags: [String], locationName: String?, locationCoordinates: CLLocationCoordinate2D?, timestamp: Date?) {
        let context = persistentContainer.viewContext
        
        // Check if image already exists in CoreData
        let fileName = (filePath as NSString).lastPathComponent
        let normalizedFileName = fileName.lowercased() // Normalize to lowercase to ignore casing
        let fetchRequest: NSFetchRequest<ImageData> = ImageData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "filePath == %@", normalizedFileName)

        do {
            let matchingImages = try context.fetch(fetchRequest)
            let image: ImageData
            
            if let existingImage = matchingImages.first {
                image = existingImage
                print("Found existing image with fileName: \(fileName)")
            } else {
                image = ImageData(context: context)
                image.id = UUID()
                image.filePath = fileName
                image.locationName = locationName
                image.latitude = locationCoordinates?.latitude ?? 0
                image.longitude = locationCoordinates?.longitude ?? 0;
                print("Saving new image with fileName: \(fileName)")
            }
            
            for tagText in tags {
                let fetchTagRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
                fetchTagRequest.predicate = NSPredicate(format: "text == %@", tagText)
                
                let matchingTags = try context.fetch(fetchTagRequest)
                if let existingTag = matchingTags.first {
                    image.addToTags(existingTag)
                    print("Adding existing tag: \(existingTag.text!)")
                } else {
                    let tag = Tag(context: context)
                    tag.id = UUID()
                    tag.text = tagText
                    image.addToTags(tag)
                    print("Creating new tag: \(tag.text!)")
                }
            }
            
            // Load UIImage
            let uiImage = CoreDataManager.loadImageFromDiskWith(fileName: fileName)
            
            // Perform Object Recognition
            let objectRecognitionProcessor = ObjectRecognitionProcessor()
            objectRecognitionProcessor.recognizeObjects(in: uiImage) { recognizedObjects in
                let recognizedObjectsString = recognizedObjects?.joined(separator: ", ")
                image.recognizedObjects = recognizedObjectsString
            }
            
            // Save the context after adding/updating image and tags
            try context.save()
        } catch {
            print("Failed to save or update image context: \(error)")
        }
    }


    
    
    static func loadImageFromDiskWith(fileName: String) -> UIImage {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            print("Loading image from URL: \(imageUrl)")
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image ?? UIImage()
        }
        return UIImage()
    }
    
    func updateLaunchDates() {
        print("Current LastLaunchDate: \(UserDefaults.standard.object(forKey: "LastLaunchDate") ?? "Not Set")")
        print("Current PreviousLaunchDate: \(UserDefaults.standard.object(forKey: "PreviousLaunchDate") ?? "Not Set")")
        
        let currentLastLaunchDate = UserDefaults.standard.object(forKey: "LastLaunchDate") as? Date
        if let currentLastLaunchDate = currentLastLaunchDate {
            UserDefaults.standard.set(currentLastLaunchDate, forKey: "PreviousLaunchDate")
        }
        UserDefaults.standard.set(Date(), forKey: "LastLaunchDate")
    }
    
    func fetchAndSaveScreenshots() {
        let fetchOptions = PHFetchOptions()
        let allAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let allScreenshots = allAssets.objects(at: IndexSet(integersIn: 0..<allAssets.count)).filter { $0.mediaSubtypes.contains(.photoScreenshot) }
        print("Total fetched screenshots: \(allScreenshots.count)")
        
        if let previousLaunchDate = UserDefaults.standard.object(forKey: "PreviousLaunchDate") as? Date {
            let filteredScreenshots = allScreenshots.filter { $0.creationDate?.compare(previousLaunchDate) == .orderedDescending }
            print("Filtered screenshots count: \(filteredScreenshots.count)")
            
            // Initialize an instance of OCRProcessor and ObjectRecognitionProcessor
            let ocrProcessor = OCRProcessor()
            let objectRecognitionProcessor = ObjectRecognitionProcessor()
            
            for screenshot in filteredScreenshots {
                if fetchImageData(for: screenshot.localIdentifier) == nil {
                    let image = ImageData(context: self.persistentContainer.viewContext)
                    image.isScreenshot = true
                    image.screenshotIdentifier = screenshot.localIdentifier
                    image.creationDate = screenshot.creationDate
                    image.isTagged = false
                    
                    let options = PHImageRequestOptions()
                    options.deliveryMode = .highQualityFormat
                    options.resizeMode = .none
                    options.isSynchronous = true
                    PHImageManager.default().requestImage(for: screenshot, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { uiImage, info in
                        if let uiImage = uiImage {
                            // Perform OCR
                            ocrProcessor.processImage(uiImage) { recognizedText in
                                image.recognizedText = recognizedText
                            }
                            
                            // Perform Object Recognition
                            objectRecognitionProcessor.recognizeObjects(in: uiImage) { recognizedObjects in
                                let recognizedObjectsString = recognizedObjects?.joined(separator: ", ")
                                image.recognizedObjects = recognizedObjectsString
                            }
                            
                            // Save the context after adding recognized text and objects
                            do {
                                try self.persistentContainer.viewContext.save()
                            } catch {
                                print("Failed to save screenshot after adding recognized text and objects: \(error)")
                            }
                        } else {
                            print("Failed to load image for screenshot: \(screenshot.localIdentifier)")
                        }
                    }
                }
            }
        } else {
            print("No previous launch date found.")
        }
    }

    
    
    
    
    
    func fetchImageData(for identifier: String) -> ImageData? {
        let fetchRequest: NSFetchRequest<ImageData> = ImageData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "screenshotIdentifier == %@", identifier)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch ImageData for identifier: \(identifier). Error: \(error)")
            return nil
        }
    }
    
    func hasNewScreenshots() -> Bool {
        let fetchRequest: NSFetchRequest<ImageData> = ImageData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isScreenshot = true AND tags.@count = 0")
        let untaggedScreenshots = try? persistentContainer.viewContext.fetch(fetchRequest)
        let hasNewScreenshots = untaggedScreenshots?.count ?? 0 > 0
        print("Untagged screenshot count: \(untaggedScreenshots?.count ?? 0)")
        return hasNewScreenshots
    }
    
    static func loadImageFromAssetIdentifier(_ identifier: String, targetSize: CGSize = CGSize(width:1000.0, height: 1000.0)) -> UIImage {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        guard let asset = fetchResult.firstObject else {
            return UIImage()
        }
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        
        manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: option, resultHandler: { (result, info) -> Void in
            if let result = result {
                image = result
            } else {
                print("Failed to load image for asset with identifier: \(identifier)")
            }
        })
        
        return image
    }
    
    func fetchStoredLocationsFromCoreData() -> [StoredLocation] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ImageData> = ImageData.fetchRequest()
        
        do {
            let images = try context.fetch(fetchRequest)
            var locations: [StoredLocation] = []
            
            // Group images by location using Coordinate struct
            let groupedImages = Dictionary(grouping: images, by: { Coordinate(latitude: $0.latitude, longitude: $0.longitude) })
            
            for (coordinate, images) in groupedImages {
                let location = StoredLocation(id: UUID().uuidString, latitude: coordinate.latitude, longitude: coordinate.longitude, notesCount: images.count)
                locations.append(location)
            }
            
            return locations
        } catch {
            print("Failed to fetch locations from CoreData: \(error)")
            return []
        }
    }

    func fetchStoredLocation(by identifier: String) -> StoredLocation? {
        let storedLocations = fetchStoredLocationsFromCoreData()
        return storedLocations.first { $0.id == identifier }
    }



}
