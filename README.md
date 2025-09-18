# Random Word Name Generator

A Flutter application that generates random word combinations and allows users to create custom word pairs with a beautiful, intuitive interface.

![App Screenshot](https://via.placeholder.com/400x800/2E7D32/FFFFFF?text=Random+Word+Generator)
*Example of the app interface*

## Features

- 🔄 **Random Word Generation**: Automatically generates random word combinations using the `english_words` package
- ✨ **Custom Word Creation**: Create your own custom word pairs with optional second words
- ❤️ **Favorites System**: Save your favorite word combinations for quick access
- 🔍 **Search Functionality**: Search through all available words (both random and custom)
- 🎨 **Beautiful UI**: Material Design 3 with a green color scheme and smooth animations
- 📱 **Responsive Design**: Works on both mobile and tablet devices
- 🏷️ **Custom Labels**: Custom words are clearly marked with special badges
- 📋 **Dedicated Sections**: Separate views for custom words and saved favorites

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0 or higher)
- Dart (version 2.17 or higher)

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd random_word_generator
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## How to Use

### Generating Random Words

1. Open the app to see a list of randomly generated word combinations
2. Scroll down to load more suggestions
3. Tap the heart icon to save any word you like

![Generation Demo](https://via.placeholder.com/400x800/2E7D32/FFFFFF?text=Generation+Demo)

### Creating Custom Words

1. Tap the + floating action button
2. Enter your first word (required)
3. Optionally add a second word
4. Tap "Create" to add your custom word to the list

### Searching Words

1. Tap the search icon in the app bar
2. Type your search query
3. View filtered results in real-time

### Managing Favorites

1. Tap the heart icon in the app bar to view all saved words
2. Remove items individually or clear all at once
3. Note: Maximum of 500 saved items allowed

## Code Structure

The main components of the application:

- `MyApp`: Root widget with theme configuration
- `RandomWords`: Stateful widget that manages the main content
- `RandomWordsState`: Handles business logic and UI state
- `CustomWordPair`: Custom class for handling user-created word pairs

## Dependencies

- `flutter/material.dart`: Flutter's material design components
- `english_words: ^4.0.0`: Library for generating English words

## Customization

You can customize the app's appearance by modifying the `ThemeData` in `MyApp`:

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2E7D32), // Primary green color
    // Customize other colors as needed
  ),
  // Other theme properties
)
```

## Features in Detail

### Word Generation
- Automatically generates 10 word pairs on startup
- "Load More" button fetches additional suggestions
- Words are displayed in PascalCase format

### Custom Words Management
- Create, edit, and delete custom word pairs
- Dedicated view for all custom words
- Visual distinction with orange badges

### Search Capabilities
- Real-time search across both random and custom words
- Visual feedback for no results
- Smooth animations when showing/hiding search bar

### Favorites System
- Persistent saving of preferred words
- Capacity indicator (500 max)
- Bulk management options

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Screenshots

![Main Screen](image1.jpeg)
![Main Screen](image2.jpeg)
![Main Screen](image3.jpeg)
![Main Screen](image4.jpeg)
![Main Screen](image5.jpeg)
![Main Screen](image6.jpeg)
![Main Screen](image7.jpeg)
![Main Screen](image8.jpeg)
![Main Screen](image9.jpeg)
## Support

If you encounter any problems or have suggestions, please open an issue on the GitHub repository.

---

**Enjoy creating interesting word combinations!**