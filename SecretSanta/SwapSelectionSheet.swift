//
//  SwapSelectionView.swift
//  SecretSanta
//
//  Created by Kristian Emil on 09/12/2024.
//

import SwiftUI

struct SwapSelectionSheet: View {
    @Environment(\.dismiss) var dismiss
    let currentSanta: String
    let availableSantas: [String]
    let onSwapSelected: (String) -> Void
    
    var body: some View {
        NavigationView {
            List(availableSantas, id: \.self) { santa in
                Button(action: {
                    onSwapSelected(santa)
                    dismiss()
                }) {
                    Text(santa)
                }
            }
            .navigationTitle("Select Santa to Swap With")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
