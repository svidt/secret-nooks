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
    
    var body: some View {
        ZStack {
            
            AppStyle.backgroundGradient.ignoresSafeArea()
            
            // Content
            
            // Participants list
            ScrollView {
                
                VStack(spacing: 12) {
                    
                    ViewHeader(iconName: "gift.fill", title: "Choose Your Name")
                    
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

