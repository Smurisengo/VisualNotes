//
//  MainView.swift
//  VisualNotes
//
//  Created by Santiago Murisengo on 4/8/2023.
//
import SwiftUI

struct MainView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ZStack {
            if appState.showRecentNotesView {
                RecentNotesView()
            } else if appState.showTaggingView {
                TagPromptView(showTaggingView: $appState.showTaggingView, showRecentNotesView: $appState.showRecentNotesView)
            }
        }
    }
}
