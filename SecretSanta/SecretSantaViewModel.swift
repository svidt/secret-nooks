import SwiftUI

class SecretSantaViewModel: ObservableObject {
    @Published var availableReceivers: [Person]
    @Published var availableGivers: [Person]
    @Published var allParticipants: [Person] {
        didSet {
            updateAvailablePeople()
        }
    }
    @Published var matches: [String: String] = [:] {
        didSet {
            saveMatches()
            updateAvailablePeople()
        }
    }
    
    @Published var pendingMatch: (giver: String, receiver: String)?
    
    @Published var currentMatch: String?
    @Published var showingMatch = false
    @Published var needsReset = false
    @Published var showingAddPerson = false
    @Published var newPersonName = ""
    @Published var showingMatchHistory = false
    @Published var showingResetConfirmation = false
    @Published var showingNameError = false
    @Published var nameErrorMessage = ""
    
    init() {
        self.allParticipants = []
        self.availableReceivers = []
        self.availableGivers = []
        loadParticipants()
        loadMatches()
        updateAvailablePeople()
    }
    
    func attemptMatch(for giver: String) -> Bool {
            guard !availableReceivers.isEmpty else { return false }
            
            // If this is the last giver and only their name is left as receiver, we need to reset
            if availableGivers.count == 1 && availableReceivers.count == 1 &&
                availableReceivers.first?.name == giver {
                needsReset = true
                return false
            }
            
            let validReceivers = availableReceivers.filter { $0.name != giver && !$0.hasReceivedMatch }
            if let receiver = validReceivers.randomElement() {
                pendingMatch = (giver: giver, receiver: receiver.name)
                showingMatch = true
                return true
            }
            
            needsReset = true
            return false
        }
        
        func confirmMatch() {
            guard let match = pendingMatch else { return }
            
            // Mark receiver as matched
            if let index = availableReceivers.firstIndex(where: { $0.name == match.receiver }) {
                availableReceivers[index].hasReceivedMatch = true
            }
            
            // Remove giver from available givers
            availableGivers.removeAll { $0.name == match.giver }
            
            matches[match.giver] = match.receiver
            pendingMatch = nil
        }
        
        func cancelMatch() {
            pendingMatch = nil
        }
    
    func addPerson(name: String) -> Bool {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedName.isEmpty else {
            nameErrorMessage = "Name cannot be empty"
            showingNameError = true
            return false
        }
        
        let nameExists = allParticipants.contains { $0.name.lowercased() == cleanedName.lowercased() }
        
        if nameExists {
            nameErrorMessage = "This name is already in use"
            showingNameError = true
            return false
        }
        
        let newPerson = Person(name: cleanedName)
        allParticipants.append(newPerson)
        saveParticipants()
        return true
    }
    
    func deletePerson(_ indexSet: IndexSet) {
        let sortedParticipants = allParticipants.sorted(by: { $0.name < $1.name })
        indexSet.forEach { index in
            let person = sortedParticipants[index]
            
            // Remove person from matches if they're involved
            if let receiverName = matches[person.name] {
                matches.removeValue(forKey: person.name)
            }
            if let giverName = matches.first(where: { $0.value == person.name })?.key {
                matches.removeValue(forKey: giverName)
            }
            
            // Remove person from participants
            allParticipants.removeAll { $0.name == person.name }
        }
        saveParticipants()
        saveMatches()
    }
    
    func isPersonMatched(_ person: Person) -> Bool {
        matches.keys.contains(person.name) || matches.values.contains(person.name)
    }
    
    func updateAvailablePeople() {
        let matchedGivers = Set(matches.keys)
        availableGivers = allParticipants.filter { !matchedGivers.contains($0.name) }
        
        let matchedReceivers = Set(matches.values)
        availableReceivers = allParticipants.filter { !matchedReceivers.contains($0.name) }
    }
    
    // MARK: - Match Assignment
    
    func assignReceiver(to giver: String) -> Bool {
        guard !availableReceivers.isEmpty else { return false }
        
        // If this is the last giver and only their name is left as receiver, we need to reset
        if availableGivers.count == 1 && availableReceivers.count == 1 &&
            availableReceivers.first?.name == giver {
            needsReset = true
            return false
        }
        
        let validReceivers = availableReceivers.filter { $0.name != giver && !$0.hasReceivedMatch }
        if let receiver = validReceivers.randomElement() {
            // Mark receiver as matched
            if let index = availableReceivers.firstIndex(where: { $0.name == receiver.name }) {
                availableReceivers[index].hasReceivedMatch = true
            }
            
            // Remove giver from available givers
            availableGivers.removeAll { $0.name == giver }
            
            matches[giver] = receiver.name
            currentMatch = receiver.name
            showingMatch = true
            return true
        }
        
        needsReset = true
        return false
    }
    
    // MARK: - Persistence
    
    func saveParticipants() {
        if let encoded = try? JSONEncoder().encode(allParticipants) {
            UserDefaults.standard.set(encoded, forKey: "participants")
        }
    }
    
    func loadParticipants() {
        if let data = UserDefaults.standard.data(forKey: "participants"),
           let decoded = try? JSONDecoder().decode([Person].self, from: data) {
            allParticipants = decoded
        }
    }
    
    func saveMatches() {
        let matchList = matches.map { SantaMatch(giver: $0.key, receiver: $0.value, timestamp: Date()) }
        if let encoded = try? JSONEncoder().encode(matchList) {
            UserDefaults.standard.set(encoded, forKey: "santaMatches")
        }
    }
    
    func loadMatches() -> [SantaMatch] {
        if let data = UserDefaults.standard.data(forKey: "santaMatches"),
           let decoded = try? JSONDecoder().decode([SantaMatch].self, from: data) {
            return decoded
        }
        return []
    }
    
    func deleteMatch(giver: String) {
        if let receiver = matches.removeValue(forKey: giver) {
            saveMatches()
            updateAvailablePeople()
        }
    }
    
    func reset() {
        matches = [:]
        updateAvailablePeople()
        needsReset = false
    }
    
    func resetAll() {
        UserDefaults.standard.removeObject(forKey: "santaMatches")
        matches.removeAll()
        updateAvailablePeople()
        currentMatch = nil
        needsReset = false
        showingMatchHistory = false
    }
}

extension SecretSantaViewModel {
    func isPersonGiver(_ person: String) -> Bool {
        // Check if the person exists as a giver (key) in the matches dictionary
        return matches.keys.contains(person)
    }
    
    // If you want to be explicit about receivers too, you can add:
    func isPersonReceiver(_ person: String) -> Bool {
        // Check if the person exists as a receiver (value) in the matches dictionary
        return matches.values.contains(person)
    }
}
