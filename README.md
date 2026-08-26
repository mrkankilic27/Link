# Link Application

Link is a cross-platform mobile application developed with Flutter, designed to intelligently pair clothing items with corresponding transaction receipts using Optical Character Recognition (OCR) technology.

## Architecture & Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Stateful Widget & Local State Management
- **Local Storage:** SharedPreferences & Path Provider for persistent file handling
- **Backend & Cloud:** Firebase Core & Firebase Services integration
- **Localization:** Easy Localization (Supports Turkish, English, and German)
- **Image Processing & OCR:** Image Picker, Flutter Image Compress, and Google ML Kit OCR integration
- **Network Services:** Custom API Service architecture for server synchronization

## Core Features

1. **Smart Pairing System:** Allows users to link a clothing item photo with its corresponding receipt/invoice photo.
2. **OCR Integration:** Automatically scans and extracts text notes from receipt images during the upload process.
3. **Record Management:** Dynamic renaming of saved pairs and local persistence via JSON serialization.
4. **Advanced Search:** Real-time filtering across record titles and OCR-extracted text notes.
5. **Multi-Language Support:** Full localization implementation supporting Turkish (tr), English (en), and German (de).
6. **Feedback Mechanism:** Built-in reporting and user feedback dialog system.

## Project Structure

lib/
│
├── screens/
│   ├── detail_screen.dart
│   └── new_link_screen.dart
│
├── services/
│   ├── api_service.dart
│   ├── image_service.dart
│   └── ocr_service.dart
│
└── main.dart

## Getting Started

### Prerequisites

Ensure you have the following installed on your local machine:
- Flutter SDK (Latest Stable Version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Git

### Installation & Setup

1. Clone the repository:
   ```bash
   git clone [https://github.com/mrkankilic27/Link.git](https://github.com/mrkankilic27/Link.git)

2. Navigate to the project directory:

```bash
cd Link
3. Install dependencies:

```bash
flutter pub get
4. Run the application:

```bash
flutter run

License
This project is open-source and available under the terms of the MIT License.