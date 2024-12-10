//
//  ParticipantListView.swift
//  SecretSanta
//
//  Created by Kristian Emil on 02/12/2024.
//

import SwiftUI

struct ParticipantListView: View {
    @ObservedObject var viewModel: SecretSantaViewModel
    var onSelect: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
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
                // Header text
                VStack(spacing: 8) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                    
                    Text("Choose Your Name")
                        .font(.title2)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.white)
                .padding(.vertical, 32)
                
                // Participants list
                ScrollView {
                    VStack(spacing: 12) {
                        Text("Available Participants")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 20)
                        ForEach(viewModel.availableGivers.sorted(by: { $0.name < $1.name })) { person in
                            Button(action: { onSelect(person.name) }) {
                                HStack(spacing: 16) {

                                    Image(systemName: "person.fill")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                                                        
                                    Text(person.name)
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                    
                                    Spacer()

                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .disabled(!viewModel.canMatchParticipant(person.name))
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ParticipantListView(viewModel: SecretSantaViewModel()) { _ in }
    }
}

