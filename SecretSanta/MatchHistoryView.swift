//
//  MatchHistoryView.swift
//  SecretSanta
//
//  Created by Kristian Emil on 02/12/2024.
//

import SwiftUI

// MARK: - Header Component
struct MatchHistoryHeader: View {
    var body: some View {
        VStack {
            
            ViewHeader(iconName: "list.clipboard.fill", title: "Match History")

        }
    }
}

// MARK: - Empty State Component
struct EmptyMatchesView: View {
    var body: some View {
        
        if #available(iOS 17.6, *) {
            ContentUnavailableView(
                "No Matches Yet",
                systemImage: "list.clipboard.fill",
                description: Text("Matches will appear here once people start drawing names")
            )
            .foregroundStyle(.white)
        } else {
            VStack {
                Text("No Matches Yet")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Matches will appear here once people start drawing names")
            }
            .foregroundStyle(.white)
        }
    }
}

// MARK: - Match List View Component
struct MatchListView: View {
    let matches: [SantaMatch]
    let revealedMatches: Set<String>
    let onReveal: (String) -> Void
    let onDelete: (SantaMatch) -> Void
    
    var body: some View {
        ForEach(matches.sorted(by: { $0.timestamp > $1.timestamp }), id: \.giver) { match in
            MatchRow(
                match: match,
                isRevealed: revealedMatches.contains(match.giver),
                onReveal: { onReveal(match.giver) },
                onDelete: { onDelete(match) }
            )
        }
    }
}

// MARK: - Clear All Button Component
struct ClearAllButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(role: .destructive, action: action) {
            HStack {
                Text("Clear All Matches")
                    .font(.headline)
                Spacer()
                Image(systemName: "trash")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 8)
    }
}

// MARK: - Main View
struct MatchHistoryView: View {
    @ObservedObject var viewModel: SecretSantaViewModel
    @Environment(\.dismiss) var dismiss
    @State private var matchToDelete: SantaMatch?
    @State private var showingDeleteConfirmation = false
    @State private var showingClearAllConfirmation = false
    @State private var revealedMatches: Set<String> = []
    
    var body: some View {
        ZStack {
            AppStyle.backgroundGradient.ignoresSafeArea()
            contentView
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
                .foregroundStyle(.white)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .alert(
            "Delete this match?",
            isPresented: $showingDeleteConfirmation,
            presenting: matchToDelete
        ) { match in
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteMatch(giver: match.giver)
                revealedMatches.remove(match.giver)
            }
        } message: { match in
            Text("Remove the match between \(match.giver) and their Secret Santa?")
        }
        .alert("Clear All Matches?", isPresented: $showingClearAllConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                viewModel.resetAll()
                revealedMatches.removeAll()
            }
        } message: {
            Text("This will remove all Secret Santa assignments and return everyone to the available pool.")
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            if viewModel.loadMatches().isEmpty {
                EmptyMatchesView()
            } else {
                matchesContent
            }
        }
    }
    
    private var matchesContent: some View {
        VStack(spacing: 0) {
            ViewHeader(iconName: "list.clipboard.fill", title: "Match History")
            
            ScrollView {
                VStack(spacing: 12) {
                    
                    MatchListView(
                        matches: viewModel.loadMatches(),
                        revealedMatches: revealedMatches,
                        onReveal: { giver in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                handleReveal(for: giver)
                            }
                        },
                        onDelete: { match in
                            matchToDelete = match
                            showingDeleteConfirmation = true
                        }
                    )
                    
                    if !viewModel.loadMatches().isEmpty {
                        ClearAllButton {
                            showingClearAllConfirmation = true
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
  
    
    private func handleReveal(for giver: String) {
        if revealedMatches.contains(giver) {
            revealedMatches.remove(giver)
        } else {
            revealedMatches.insert(giver)
            
            // Using SwiftUI's native animation timing
            _ = withAnimation(.easeInOut(duration: 0.3).delay(3)) {
                revealedMatches.remove(giver)
            }
        }
    }
}
