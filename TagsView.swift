//
//  TagsView.swift
//  VisualNotes
//
//  Created by Santiago Murisengo on 3/8/2023.
//

import SwiftUI
import CoreData

struct TagsView: View {
    @FetchRequest(entity: Tag.entity(), sortDescriptors: []) var tags: FetchedResults<Tag>
    
    @State private var expandedTags: [UUID: Bool] = [:]
    
    var body: some View {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(Array(tags), id: \.self) { tag in
                        VStack {
                            Button(action: {
                                withAnimation {
                                    expandedTags[tag.id!] = !(expandedTags[tag.id!] ?? false)
                                }
                            }) {
                                HStack {
                                    Text(tag.text ?? "")
                                    Spacer()
                                    Text("\(tag.images?.count ?? 0)")
                                        .font(.footnote)
                                        .padding(5)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    Image(systemName: expandedTags[tag.id!] ?? false ? "chevron.up" : "chevron.down")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                            
                            if expandedTags[tag.id!] ?? false {
                                TagCollageView(tag: tag, images: tag.images?.allObjects as? [ImageData] ?? [])
                                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, -8)
                .navigationTitle("Tags")
        }
    }
}

