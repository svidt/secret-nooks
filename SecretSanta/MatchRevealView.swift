//
//  MatchRevealView.swift
//  SecretSanta
//
//  Created by Kristian Emil on 03/12/2024.
//

import SwiftUI

struct MatchRevealView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SecretSantaViewModel
    
    // Store the match locally when the view appears
    @State private var matchReceiver: String = ""
    @State private var isRevealed = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.2, green: 0.3, blue: 0.5),
                    Color(red: 0.3, green: 0.4, blue: 0.6),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Snow effect
//            SnowfallView()
//                .opacity(0.7)
            
            // Content
            VStack(spacing: 32) {
                Spacer()
                
                if !isRevealed {
                    Text("Ready to see who you got?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                } else {
                    Text("You will be Secret Santa for")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(.bottom, 8)
                    
                    Text(matchReceiver)
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    if !isRevealed {
                        Button {
                            if let match = viewModel.pendingMatch {
                                matchReceiver = match.receiver
                                withAnimation(.spring(duration: 0.5)) {
                                    isRevealed = true
                                }
                                // Confirm match after reveal
                                viewModel.confirmMatch()
                            }
                        } label: {
                            Label("Reveal Match", systemImage: "gift")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.ultraThinMaterial)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                        
                        Button {
                            viewModel.cancelMatch()
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.ultraThinMaterial)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.ultraThinMaterial)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(32)
        }
        .onAppear {
            // Store the match receiver when view appears
            if let match = viewModel.pendingMatch {
                matchReceiver = match.receiver
            }
        }
    }
}
