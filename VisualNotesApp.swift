//
//  VisualNotesApp.swift
//  VisualNotes
//
//  Created by Santiago Murisengo on 3/8/2023.
//

import SwiftUI

@main
struct VisualNotesApp: App {
    let coreDataManager = CoreDataManager.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.persistentContainer.viewContext)
        }
    }
}


