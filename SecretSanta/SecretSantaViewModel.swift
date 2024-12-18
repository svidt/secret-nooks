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
        restoreMatches() // Call new restore function instead of loadMatches
        updateAvailablePeople()
    }
    
    func attemptMatch(for giver: String) -> Bool {
        // First check if there are any available receivers other than the giver
        let validReceivers = availableReceivers.filter { $0.name != giver && !$0.hasReceivedMatch }
        
        if validReceivers.isEmpty {
            // Instead of resetting, show an error message
            nameErrorMessage = "No available recipients. Everyone is already matched!"
            showingNameError = true
            return false
        }
        
        // Proceed with matching only if we have valid receivers
        if let receiver = validReceivers.randomElement() {
            pendingMatch = (giver: giver, receiver: receiver.name)
            showingMatch = true
            return true
        }
        
        return false
    }
    
    private func restoreMatches() {
        if let data = UserDefaults.standard.data(forKey: "santaMatches"),
           let decoded = try? JSONDecoder().decode([SantaMatch].self, from: data) {
            // Convert the loaded matches back into the dictionary format
            var restoredMatches: [String: String] = [:]
            for match in decoded {
                restoredMatches[match.giver] = match.receiver
            }
            self.matches = restoredMatches // This will trigger didSet and updateAvailablePeople
        }
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
        saveMatches() // Explicit save after confirming match
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
        
        // Create new person
        let newPerson = Person(name: cleanedName)
        
        // Temporarily store existing matches
        let existingMatches = self.matches
        
        // Add new person
        allParticipants.append(newPerson)
        
        // Restore existing matches
        self.matches = existingMatches
        
        // Save both participants and matches
        saveParticipants()
        saveMatches()
        
        // Update available people only for the new addition
        updateAvailablePeople()
        
        return true
    }
    
//    func addPerson(name: String) -> Bool {
//        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        guard !cleanedName.isEmpty else {
//            nameErrorMessage = "Name cannot be empty"
//            showingNameError = true
//            return false
//        }
//        
//        let nameExists = allParticipants.contains { $0.name.lowercased() == cleanedName.lowercased() }
//        
//        if nameExists {
//            nameErrorMessage = "This name is already in use"
//            showingNameError = true
//            return false
//        }
//        
//        let newPerson = Person(name: cleanedName)
//        allParticipants.append(newPerson)
//        saveParticipants()
//        return true
//    }
    
    func deletePerson(_ indexSet: IndexSet) {
        let sortedParticipants = allParticipants.sorted(by: { $0.name < $1.name })
        indexSet.forEach { index in
            let person = sortedParticipants[index]
            
            // Remove person from matches if they're involved
            if matches[person.name] != nil {
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
        do {
            let encoded = try JSONEncoder().encode(allParticipants)
            UserDefaults.standard.set(encoded, forKey: "participants")
            UserDefaults.standard.synchronize()
            print("Successfully saved \(allParticipants.count) participants")
        } catch {
            print("Error saving participants: \(error)")
        }
    }
    
    func loadParticipants() {
        do {
            guard let data = UserDefaults.standard.data(forKey: "participants") else {
                print("No saved participants found")
                return
            }
            allParticipants = try JSONDecoder().decode([Person].self, from: data)
            print("Successfully loaded \(allParticipants.count) participants")
        } catch {
            print("Error loading participants: \(error)")
        }
    }
    
    func saveMatches() {
        let matchList = matches.map { SantaMatch(giver: $0.key, receiver: $0.value, timestamp: Date()) }
        do {
            let encoded = try JSONEncoder().encode(matchList)
            UserDefaults.standard.set(encoded, forKey: "santaMatches")
            UserDefaults.standard.synchronize()
            print("Successfully saved \(matchList.count) matches")
        } catch {
            print("Error saving matches: \(error)")
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
        if matches.removeValue(forKey: giver) != nil {
            saveMatches()
            updateAvailablePeople()
        }
    }
    
    func reset() {
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
    
    func exportData() -> Data? {
        struct BackupData: Codable {
            let participants: [Person]
            let matches: [SantaMatch]
        }
        
        do {
            let matchList = matches.map { SantaMatch(giver: $0.key, receiver: $0.value, timestamp: Date()) }
            let backup = BackupData(participants: allParticipants, matches: matchList)
            return try JSONEncoder().encode(backup)
        } catch {
            print("Error creating backup: \(error)")
            return nil
        }
    }
    
    func canMatchParticipant(_ name: String) -> Bool {
        let validReceivers = availableReceivers.filter { $0.name != name && !$0.hasReceivedMatch }
        return !validReceivers.isEmpty
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
