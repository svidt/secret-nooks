# Secret Nooks - iOS Secret Santa App

The application represents a practical solution to organizing Secret Santa events while maintaining the element of surprise and providing a delightful user experience. It demonstrates the application of CS50 principles in creating a real-world application that solves a specific problem.

This project was developed as the final project for Harvard's CS50 course, implementing the knowledge gained throughout the course in a practical, user-focused application.

<br>
<a href="url"><img src="SecretSanta/Assets.xcassets/AppIcon.appiconset/SecretSantaAppIconBlue.png" height="200" width="200" ></a>
<br>

#### Video Demo: https://youtube.com/shorts/7MvNrnT-r64
#### Description:

Secret Nooks is an iOS application built using Swift and SwiftUI that simplifies the organization of Secret Santa gift exchanges. The app provides an intuitive and festive interface for managing participants and automatically matching gift givers with recipients while maintaining the surprise element essential to Secret Santa exchanges.

### Core Features

The application implements several key features that make Secret Santa organization seamless:

1. **Participant Management**
   - Add and remove participants with duplicate name prevention
   - Real-time validation of participant names
   - Ability to clear all participants when needed
   - Clean interface for viewing current participants

2. **Smart Gift Matching**
   - Automatic matching algorithm that prevents self-matches
   - Ensures fair distribution of gift assignments
   - Handles edge cases to prevent invalid matching scenarios
   - Option to reset matches if needed

3. **Privacy-Focused Design**
   - Tap-to-reveal mechanism for viewing matches
   - Individual match deletion capability
   - Temporary match reveals that auto-hide
   - Secure local storage of participant data

4. **User Interface**
   - Festive dark and cozy winter colors, dark blue and warm red
   - Dynamic snowfall animation
   - Floating participant names in background
   - Frosted glass effect for UI elements (SwiftUI Material)
   - Smooth transitions and animations

### Technical Deep Dive

The project implements several sophisticated technical solutions that demonstrate key computer science principles learned in CS50:

#### Data Structures and Algorithms
Building on CS50's lessons about data structures, the app uses a combination of arrays and dictionaries (hash tables) to manage participants and matches:

```swift
struct Person: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    var hasReceivedMatch = false
}

// Efficient O(1) lookup for matches using dictionary
@Published var matches: [String: String] = [:]  // giver: receiver
```

The matching algorithm implements principles from CS50's graph theory lessons, ensuring no cycles in gift-giving and preventing deadlocks:

1. Maintains separate pools for available givers and receivers
2. Implements random selection with constraints
3. Includes deadlock detection and resolution
4. Uses backtracking when matches become impossible

#### Memory Management
Following CS50's emphasis on efficient memory usage:
- Uses value types (structs) for models to prevent memory leaks
- Implements copy-on-write semantics for collections
- Efficiently manages view lifecycle using SwiftUI's declarative syntax
- Uses lazy loading for expensive UI elements like animations

#### Database Management
Applied CS50 SQL knowledge in a mobile context:
- Implemented CRUD operations using UserDefaults
- Structured data with clear relationships
- Used encoding/decoding for data persistence
- Maintained data integrity with transaction-like operations

```swift
func saveMatches() {
    let matchList = matches.map { SantaMatch(giver: $0.key, receiver: $0.value, timestamp: Date()) }
    do {
        let encoded = try JSONEncoder().encode(matchList)
        UserDefaults.standard.set(encoded, forKey: "santaMatches")
        UserDefaults.standard.synchronize()
    } catch {
        print("Error saving matches: \(error)")
    }
}
```

#### Algorithms and Problem-Solving
The matching algorithm demonstrates several CS50 concepts:

1. **Random Selection with Constraints**
```swift
func attemptMatch(for giver: String) -> Bool {
    let validReceivers = availableReceivers.filter {
        $0.name != giver && !$0.hasReceivedMatch
    }
    guard !validReceivers.isEmpty else { return false }
    
    if let receiver = validReceivers.randomElement() {
        pendingMatch = (giver: giver, receiver: receiver.name)
        return true
    }
    return false
}
```

2. **Edge Case Handling**
- Prevents self-matches
- Handles last participant scenarios
- Manages group sizes of 2 or more
- Implements rollback for failed matches

### Application of CS50 Principles

This project directly applies several key concepts from CS50, translating them into real-world mobile development:

1. **Week 1: C Programming Fundamentals**
   - Boolean logic and conditional statements transformed into Swift's type-safe conditions
   - Loop structures adapted for participant management
   - Variable scope understanding applied to SwiftUI's state management

2. **Week 2: Arrays and Memory**
   - Array manipulation techniques used for participant lists
   - Memory management principles applied through Swift's value types
   - String manipulation for name validation and formatting

3. **Week 3: Algorithms**
   - Implemented sorting for participant lists
   - Random selection algorithm for Secret Santa matching
   - Search algorithms for participant validation

4. **Week 4: Memory Management**
   - Proper memory allocation using Swift's ARC
   - Value vs. reference types for data models
   - Memory-efficient animations using SwiftUI Canvas

5. **Week 5: Data Structures**
   - Hash tables concept applied through Swift dictionaries for O(1) lookups
   - Linked list principles adapted for match history
   - Tree structure concepts applied to view hierarchy

6. **Week 7: SQL and Data Management**
   - CRUD operations implemented using UserDefaults
   - Data relationship management between participants and matches
   - Transaction-like operations for match updates

7. **Week 8: HTML/CSS/JavaScript**
   - UI layout principles applied through SwiftUI
   - Styling techniques adapted from CSS to SwiftUI modifiers
   - Interactive elements similar to JavaScript functionality

### Development Challenges and Solutions

The project presented several significant challenges that required creative solutions:

1. **iOS Version Compatibility**
   - **Challenge**: Initial implementation only worked on iOS 18.2
   - **Solution**: Refactored code to use more basic SwiftUI features
   - **Implementation**:
     ```swift
     if #available(iOS 17.0, *) {
         // Use newer APIs
     } else {
         // Fallback implementation
     }
     ```
   - Resulted in support back to iOS 16.0

2. **Consistent Design Language**
   - **Challenge**: Maintaining visual consistency across different views
   - **Solution**: Created a centralized style system
   - **Implementation**:
     ```swift
     enum AppStyle {
         static let backgroundGradient = LinearGradient(
             colors: [
                 Color(red: 0.1, green: 0.2, blue: 0.4),
                 Color(red: 0.2, green: 0.3, blue: 0.5)
             ],
             startPoint: .top,
             endPoint: .bottom
         )
     }
     ```
   - Applied CS50's lessons on code reusability and abstraction

3. **Matching Algorithm Integrity**
   - **Challenge**: Ensuring valid Secret Santa matches without self-matches
   - **Solution**: Implemented validation and backtracking
   - **Implementation**:
     ```swift
     func canMatchParticipant(_ name: String) -> Bool {
         let validReceivers = availableReceivers.filter {
             $0.name != name && !$0.hasReceivedMatch
         }
         return !validReceivers.isEmpty
     }
     ```
   - Applied CS50's algorithm design principles

4. **Name Uniqueness**
   - **Challenge**: Preventing duplicate names while maintaining good UX
   - **Solution**: Case-insensitive comparison and real-time validation
   - **Implementation**:
     ```swift
     func addPerson(name: String) -> Bool {
         let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
         let nameExists = allParticipants.contains {
             $0.name.lowercased() == cleanedName.lowercased()
         }
         guard !nameExists else {
             nameErrorMessage = "This name is already in use"
             showingNameError = true
             return false
         }
         // ... rest of implementation
     }
     ```
   - Applied CS50's input validation concepts

5. **App Store Review Process**
   - **Challenge**: Meeting Apple's strict guidelines for approval
   - **Solution**:
     - Implemented proper error handling
     - Added clear privacy descriptions
     - Ensured accessibility support
     - Optimized performance
   - Applied CS50's emphasis on code quality and user experience

These challenges demonstrated the practical application of CS50's problem-solving methodology:
1. Break down complex problems into smaller components
2. Implement systematic solutions
3. Test thoroughly
4. Optimize based on results
5. Document clearly

### Technical Implementation

The project consists of several key Swift files, each serving a specific purpose:

1. **Models.swift**
   - Defines core data structures: `Person` and `SantaMatch`
   - Implements `Codable` protocol for data persistence
   - Handles UUID generation for unique identification

2. **SecretSantaViewModel.swift**
   - Manages application state and business logic
   - Implements matching algorithm
   - Handles data persistence using UserDefaults
   - Manages participant and match lists
   - Provides methods for adding/removing participants

3. **ContentView.swift**
   - Main interface implementation
   - Manages navigation and view hierarchy
   - Implements primary action buttons
   - Coordinates between different view components

4. **MatchHistoryView.swift**
   - Displays complete match history
   - Implements reveal mechanism
   - Manages match deletion
   - Provides clear all functionality

5. **SharedStyles.swift**
   - Defines consistent styling across the app
   - Implements reusable view components
   - Manages color schemes and gradients

6. **SnowfallView.swift & NameSnowView.swift**
   - Implements particle system for snow animation
   - Creates floating name animation
   - Uses SwiftUI Canvas for efficient rendering

### Design Decisions

Several key design decisions were made during development:

1. **Data Persistence**
   - Chose UserDefaults for storage due to:
     - Small data footprint
     - Simple data structure
     - No need for complex querying
     - Built-in iOS support

2. **MVVM Architecture**
   - Separated concerns between views and logic
   - Improved testability and maintenance
   - Clean data flow and state management
   - Follows SwiftUI best practices

3. **Privacy Implementation**
   - Implemented temporary reveals to maintain surprise
   - Added confirmation dialogs for destructive actions
   - Kept all data local to the device

4. **UI/UX Considerations**
   - Used dark theme for winter/holiday atmosphere
   - Implemented subtle animations for engagement
   - Added visual feedback for all actions
   - Followed iOS Human Interface Guidelines

### Learning Outcomes

This project provided valuable experience in:
- SwiftUI development
- State management in iOS applications
- User interface design principles
- Data persistence techniques using iOS's built-in database
- Animation and graphics programming
- Privacy-conscious application design, no data leaves the device

### Resources Used

- Swift Programming Language - https://www.swift.org/
- SwiftUI Framework - https://developer.apple.com/xcode/swiftui/
- Apple Human Interface Guidelines - https://designsystems.surf/design-systems/apple
- CS50 Course Materials - https://cs50.harvard.edu/x/2024
- Claude AI Assistant for code review and documentation - https://claude.ai
