//
//  TagCollageView.swift
//  VisualNotes
//
//  Created by Santiago Murisengo on 3/8/2023.
//

import SwiftUI
import CoreData

struct TagCollageView: View {
    var tag: Tag
    var images: [ImageData]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
            ForEach(images, id: \.self) { image in
                NavigationLink(destination: NoteView(image: image)) {
                    Image(uiImage: CoreDataManager.loadImageFromDiskWith(fileName: image.filePath ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .center)
                        .cornerRadius(8)
                }
            }
        }
    }
}


