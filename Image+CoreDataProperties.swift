//
//  Image+CoreDataProperties.swift
//  VisualNotes
//
//  Created by Santiago Murisengo on 3/8/2023.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var filePath: String?
    @NSManaged public var tag: Tag?

}

extension Image : Identifiable {

}
