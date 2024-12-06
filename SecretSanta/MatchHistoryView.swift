//
//  MatchHistoryView.swift
//  SecretSanta
//
//  Created by Kristian Emil on 02/12/2024.
//

import SwiftUI

struct MatchHistoryView: View {
    @ObservedObject var viewModel: SecretSantaViewModel
    @Environment(\.dismiss) var dismiss
    @State private var matchToDelete: SantaMatch?
    @State private var showingDeleteConfirmation = false
    @State private var showingClearAllConfirmation = false
    @State private var revealedMatches: Set<String> = []
    
    private let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.1, green: 0.2, blue: 0.4),
            Color(red: 0.2, green: 0.3, blue: 0.5),
            Color(red: 0.3, green: 0.4, blue: 0.6),
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        ZStack {
            // Background layers
            backgroundGradient.ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {

                if viewModel.loadMatches().isEmpty {
                    ContentUnavailableView(
                        "No Matches Yet",
                        systemImage: "list.clipboard.fill",
                        description: Text("Matches will appear here once people start drawing names")
                    )
                    .foregroundStyle(.white)

                } else {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "list.clipboard.fill")
                            .font(.system(size: 44))
                            .symbolRenderingMode(.multicolor)
                            .foregroundStyle(.white)
                        
                        Text("Match History")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 32)
                    // Matches List
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.loadMatches().sorted(by: { $0.timestamp > $1.timestamp }), id: \.giver) { match in
                                MatchRow(
                                    match: match,
                                    isRevealed: revealedMatches.contains(match.giver),
                                    onReveal: { revealedMatches.insert(match.giver) },
                                    onDelete: {
                                        matchToDelete = match
                                        showingDeleteConfirmation = true
                                    }
                                )
                            }
                            
                            if !viewModel.loadMatches().isEmpty {
                                Button(role: .destructive) {
                                    showingClearAllConfirmation = true
                                } label: {
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
                        .padding(.horizontal)
                    }
                }
            }
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
        .alert("Delete this match?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let match = matchToDelete {
                    viewModel.deleteMatch(giver: match.giver)
                    revealedMatches.remove(match.giver)
                }
            }
        } message: {
            if let match = matchToDelete {
                Text("Remove the match between \(match.giver) and their Secret Santa?")
            }
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
}
