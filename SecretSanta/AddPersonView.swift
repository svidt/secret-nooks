//
//  AddNewPerson.swift
//  SecretSanta
//
//  Created by Kristian Emil on 02/12/2024.
//

import SwiftUI

struct AddPersonView: View {
    @ObservedObject var viewModel: SecretSantaViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingDeleteAllConfirmation = false
    
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
            backgroundGradient.ignoresSafeArea(.all)
            
            // Content
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                    
                    Text("Add Participant")
                        .font(.title2)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.white)
                .padding(.vertical, 32)
                
                // Main content
                ScrollView {
                    VStack(spacing: 12) {
                        // Add participant input
                        
                        
                        HStack(spacing: 16) {
                            Image(systemName: "person.badge.plus.fill")
                                .foregroundStyle(.white)
                            TextField("Add participant name", text: $viewModel.newPersonName)
                                .focused($isTextFieldFocused)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.words)
                                .submitLabel(.done)
                                .foregroundStyle(.white)
                                .onSubmit {
                                    if !viewModel.newPersonName.isEmpty {
                                        if viewModel.addPerson(name: viewModel.newPersonName) {
                                            viewModel.newPersonName = ""
                                        }
                                    }
                                }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        if viewModel.allParticipants.count < 2 {
                            Text("A minimum of two participants are required")
                                .font(.footnote)
                                .foregroundStyle(.white)
                        }
                        
                        // Participants list
                        if !viewModel.allParticipants.isEmpty {
                            Text("Current Participants")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 20)
                            
                            ForEach(viewModel.allParticipants.sorted(by: { $0.name < $1.name })) { person in
                                ParticipantRow(
                                    person: person,
                                    isGiver: viewModel.isPersonGiver(person.name),
                                    isReceiver: viewModel.isPersonReceiver(person.name),
                                    onDelete: {
                                        // Make sure we're using the correct index from the sorted array
                                        let sortedParticipants = viewModel.allParticipants.sorted(by: { $0.name < $1.name })
                                        if let index = sortedParticipants.firstIndex(where: { $0.id == person.id }) {
                                            viewModel.deletePerson(IndexSet(integer: index))
                                        }
                                    }
                                )
                            }
                        }
                        
                        if !viewModel.allParticipants.isEmpty {
                            Button(role: .destructive) {
                                showingDeleteAllConfirmation = true
                            } label: {
                                HStack {
                                    Text("Delete All Participants")
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
                            .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal)
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
        
        
        .alert("Cannot Add Name", isPresented: $viewModel.showingNameError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.nameErrorMessage)
        }
        .alert("Delete All Participants?", isPresented: $showingDeleteAllConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                viewModel.allParticipants.removeAll()
                viewModel.saveParticipants()
            }
        } message: {
            do {
                Text("This will remove all participants. This action cannot be undone.")
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

// Updated MatchRow to match the styling
struct MatchRow: View {
    let match: SantaMatch
    let isRevealed: Bool
    let onReveal: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Giver info
            HStack {
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                
                Text(match.giver)
                    .font(.title3)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "x.circle")
                        .foregroundStyle(.white)
                }
            }
            
            // Receiver info
            HStack {
                Image(systemName: "gift.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                
                if isRevealed {
                    Text(match.receiver)
                        .font(.title3)
                        .transition(.blurReplace)
                } else {
                    Text("Tap to reveal")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .onTapGesture {
                onReveal()
            }
            
            Text(match.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


struct ParticipantRow: View {
    let person: Person
    let isGiver: Bool
    let isReceiver: Bool  // Add this
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirmation = false
    
    var isInGame: Bool {
        isGiver || isReceiver
    }
    
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .font(.title2)
                .foregroundStyle(.white)
            
            Text(person.name)
                .font(.title3)
            
            Spacer()
            
            HStack(spacing: 16) {
                if isGiver {
                    Image(systemName: "gift.fill")
                        .foregroundStyle(.white)
                }
                
                Button {
                    if isInGame {
                        showingDeleteConfirmation = true
                    } else {
                        onDelete()
                    }
                } label: {
                    Image(systemName: "x.circle")
                        .foregroundStyle(.white)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .alert("Delete Participant?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("\(person.name) is currently \(isGiver ? "giving a gift" : "receiving a gift") in Secret Santa. Deleting them will remove their match.")
        }
    }
}
