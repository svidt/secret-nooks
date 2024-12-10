//
//  DetailedStatusView.swift
//  SecretSanta
//
//  Created by Kristian Emil on 03/12/2024.
//
import SwiftUI


struct DetailedStatusView: View {
    
    @ObservedObject var viewModel: SecretSantaViewModel
    
    var body: some View {
        // MARK: - Status Indicator
        Group {
            if viewModel.allParticipants.isEmpty {
                Label {
                    Text("Add participants to start the game")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.white)
                }
                
            } else if viewModel.allParticipants.count == 1 {
                Label {
                    Text("Need at least one more person to start")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.white)
                }

            } else if viewModel.availableGivers.isEmpty && !viewModel.allParticipants.isEmpty {
                Label {
                    Text("All Secret Santas have been assigned")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                }
                
            } else {
                Label {
                    Text("\(viewModel.availableGivers.count) of \(viewModel.allParticipants.count) still need to draw")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "person.3.fill")
                        .symbolRenderingMode(.multicolor)
                        .foregroundStyle(.white)
                }
                
            }
        }
        .font(.footnote)
    }
}
