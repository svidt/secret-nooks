//
//  SharedStyles.swift
//  SecretSanta
//
//  Created by Kristian Emil on 18/12/2024.
//

import SwiftUI

// MARK: - Common Constants
enum AppStyle {
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.1, green: 0.2, blue: 0.4),
            Color(red: 0.2, green: 0.3, blue: 0.5),
            Color(red: 0.3, green: 0.4, blue: 0.6),
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Reusable Header Component
struct ViewHeader: View {
    let iconName: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 44))
                .foregroundStyle(.white)
            
            Text(title)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.white)
        }
        .padding(.vertical, 32)
    }
}

// MARK: - Reusable List Row Container
struct ListRowContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
