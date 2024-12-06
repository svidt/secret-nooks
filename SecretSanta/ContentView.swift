//
//  ContentView.swift
//  SecretSanta
//
//  Created by Kristian Emil on 02/12/2024.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var viewModel = SecretSantaViewModel()
    @StateObject private var snowViewModel = NameSnowViewModel()
    @State private var selectedGiver = ""
    @State private var showingGiverPicker = false
    
    // Festive gradient for background atmosphere
    private let backgroundGradient = LinearGradient(
        colors: [
//            Color(red: 0.1, green: 0.1, blue: 0.2),
            Color(red: 0.1, green: 0.2, blue: 0.4),
            Color(red: 0.2, green: 0.3, blue: 0.5),
            Color(red: 0.3, green: 0.4, blue: 0.6),
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    private var isAnySheetPresented: Bool {
        showingGiverPicker ||
        viewModel.showingAddPerson ||
        viewModel.showingMatchHistory ||
        viewModel.showingMatch
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background Layer
                backgroundGradient.ignoresSafeArea()
                SnowfallView()
                    .ignoresSafeArea()
                    .opacity(0.7)
                NameSnowView(viewModel: snowViewModel)
                    .opacity(0.6)
                
                // MARK: - Main Content
                ScrollView {
                    VStack(spacing: 32) {
                        // Festive Header
                        VStack(spacing: 16) {
                            ZStack {
                                Text("Secret Nooks")
                                    .blur(radius: 10)
                                    .opacity(0.5)
                                Text("Secret Nooks")
                            }
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .scaleEffect(1.5)
                        }
                        .padding(.top, 32)
                        
                        
                        ZStack {
                            
                            // MARK: - Primary Action
                            Button(action: {
                                showingGiverPicker = true
                            }) {
                                VStack {
                                    ZStack {
                                        Circle()
                                            .frame(width: 100)
                                            .foregroundStyle(.white)
                                            .blur(radius: 50)
                                        
                                        Image(systemName: "gift.fill")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 100))
                                            .symbolEffect(.wiggle, options: .repeating)
                                    }
                                    .padding(.bottom, 20)
                                    
                                    Text("Draw Your Secret Santa")
                                        .font(.system(.headline, design: .rounded))
                                    
                                    
                                    
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(.red)
                                .foregroundStyle(.white)
                                .cornerRadius(16)
                                .shadow(radius: 5)
                            }
                            .scaleEffect(viewModel.availableGivers.count <= 1 ? 0.0 : 1.0, anchor: .bottom)
                            .animation(.bouncy(duration: 0.6), value: viewModel.availableGivers)
//                            .disabled(viewModel.availableGivers.isEmpty)
                            .buttonStyle(.plain)
                        }
                        
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()

                        
                        // MARK: - Secondary Actions
                        VStack(spacing: 16) {

                            DetailedStatusView(viewModel: viewModel)
                            
                            Button(action: { viewModel.showingAddPerson = true }) {
                                Label("Add Participant", systemImage: "person.badge.plus.fill")
                                    .bold()
                                    .frame(height: 40)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.white)
                            
                            Button(action: { viewModel.showingMatchHistory = true }) {
                                Label("View Matches", systemImage: "list.clipboard.fill")
                                    .frame(height: 40)
                                    .frame(maxWidth: .infinity)
                                    .bold()
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.white)
                            .disabled(viewModel.matches.isEmpty)
                            
                            
                        }
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                    }
                    .padding()
                }
                .sheetOverlay(isPresented: isAnySheetPresented)
            }
            
            // MARK: - Sheets and Modals
            .sheet(isPresented: $showingGiverPicker) {
                ParticipantListView(viewModel: viewModel) { name in
                    selectedGiver = name
                    if !viewModel.attemptMatch(for: name) {
                        viewModel.reset()
                    }
                    showingGiverPicker = false
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $viewModel.showingAddPerson) {
                AddPersonView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $viewModel.showingMatchHistory) {
                MatchHistoryView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            }

            .sheet(isPresented: $viewModel.showingMatch) {
                MatchRevealView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
                    .interactiveDismissDisabled(true)
            }
            // MARK: - Alerts
            .alert("Need to Start Over", isPresented: $viewModel.needsReset) {
                Button("OK") {
                    viewModel.reset()
                    viewModel.needsReset = false
                }
            } message: {
                Text("We've hit a dead end in the matching. Let's start over to ensure everyone gets a fair match!")
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isAnySheetPresented)
        .onChange(of: viewModel.availableGivers) { newValue in
            snowViewModel.updateParticles(with: newValue.map { $0.name })
        }
    }
}

#Preview {
    ContentView()
}

struct SheetOverlayModifier: ViewModifier {
    let isPresented: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black
                    .opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
    }
}

// Add an extension to View for easier usage
extension View {
    func sheetOverlay(isPresented: Bool) -> some View {
        modifier(SheetOverlayModifier(isPresented: isPresented))
    }
}
