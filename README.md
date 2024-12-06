# Secret Nooks 🎁

A beautifully crafted iOS app for organizing Secret Santa gift exchanges, featuring a modern interface with smooth animations, festive design elements, and an intuitive user experience.

![App Preview](SecretSanta/Assets.xcassets/AppIcon.appiconset/SecretSantaAppIconBlue.png)
<a href="url"><img src="SecretSanta/Assets.xcassets/AppIcon.appiconset/SecretSantaAppIconBlue.png" align="left" height="48" width="48" ></a>

## Features ✨

### Core Functionality
- **Smart Gift Matching**: Prevents participants from being matched with themselves and ensures fair distribution
- **Real-time Match Status**: Clear indicators showing how many participants still need to draw names
- **Match History**: Complete overview of all Secret Santa assignments with privacy-focused reveal interactions
- **Participant Management**: Easy addition and removal of participants with duplicate name prevention

### User Experience
- **Festive Atmosphere**: 
  - Dynamic snowfall animation
  - Floating participant names in the background
  - Soothing dark blue color scheme
  - Frosted glass effect for UI elements
- **Privacy-Focused**: 
  - Tap-to-reveal mechanism for viewing matches
  - Individual match deletion
  - Option to reset all matches
- **Smooth Animations**: 
  - Fluid transitions between views
  - Playful gift icon animations
  - Seamless match reveal interactions

### Technical Details
- **Swift and SwiftUI**: Built using modern iOS development practices
- **MVVM Architecture**: Clean separation of concerns with a robust view model
- **Local Storage**: Efficient data persistence using UserDefaults
- **Responsive Design**: Adapts beautifully to different iOS devices
- **Human Interface Guidelines**: Follows Apple's design principles while maintaining unique aesthetics

## Requirements 📱

- iOS 15.0 or later
- Xcode 13.0 or later
- Swift 5.5 or later

## Installation 🚀

1. Clone the repository
```bash
git clone https://github.com/svidt/secret-nooks.git
```

2. Open the project in Xcode
```bash
cd secret-nooks
open SecretSanta.xcodeproj
```

3. Build and run the project in Xcode

## Usage 🎯

1. **Adding Participants**
   - Tap the "Add Participant" button
   - Enter participant names
   - Duplicate names are automatically prevented

2. **Drawing Names**
   - Tap the large gift icon to start
   - Select your name from the list
   - View your assigned person
   - Names are saved automatically

3. **Managing Matches**
   - View all matches in the history view
   - Tap to reveal individual matches
   - Delete specific matches if needed
   - Option to reset all matches

## Architecture 🏗

The app follows the MVVM (Model-View-ViewModel) pattern:

- **Models**: `Person`, `SantaMatch`, `Participant`
- **Views**: SwiftUI views for each screen and component
- **ViewModel**: `SecretSantaViewModel` handling business logic and state
- **Utils**: Snowfall and name animation effects

## Contributing 🤝

We welcome contributions to Secret Nooks! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Areas for Contribution

- Additional animation effects
- Theme customization options
- Alternative matching algorithms
- Enhanced privacy features
- Localization support
- Widget support
- Share sheet integration
- iCloud sync support

## License 📄

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments 🙏

- Inspired by the joy of holiday gift exchanges
- Built with SwiftUI's modern declarative syntax
- Designed with accessibility in mind
- Community feedback and contributions

## Contact 📱

Svidt - [@hellosvidt](https://twitter.com/hellosvidt)

Project Link: [https://github.com/svidt/secret-nooks](https://github.com/svidt/secret-nooks)

---

Made with ❤️ for the iOS developer community
