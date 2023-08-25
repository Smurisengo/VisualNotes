//
//  Tag+CoreDataProperties.swift
//  VisualNotes
//
//  Created by Santiago Murisengo on 3/8/2023.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var image: Image?

}

extension Tag : Identifiable {

}
