//
//  Participant.swift
//  SecretSanta
//
//  Created by Kristian Emil on 03/12/2024.
//

import Foundation

struct Participant: Identifiable, Codable {
    let id: UUID
    let name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
