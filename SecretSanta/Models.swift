//
//  Models.swift
//  SecretSanta
//
//  Created by Kristian Emil on 02/12/2024.
//

import Foundation

struct Person: Identifiable, Hashable, Codable {
    let id = UUID()
    let name: String
    var hasReceivedMatch = false
}

struct SantaMatch: Codable {
    let giver: String
    let receiver: String
    let timestamp: Date
}
