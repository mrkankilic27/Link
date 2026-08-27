# Link

Link is a Flutter application for pairing a clothing photo with its receipt or invoice. It is designed for people who want to keep a visual record of purchases and quickly find receipt details later.

The app supports Turkish, English, and German. It can authenticate users with email/password, Google, or anonymous guest accounts, extract receipt text with OCR, store records locally, and synchronize records with a PHP/MySQL API.

## Features

- Pair one clothing photo with one receipt photo.
- Extract receipt text with Google ML Kit OCR.
- Add, rename, search, view, and delete pairings.
- Search both record names and OCR text.
- Local persistence for records created while offline.
- Firebase Authentication with email/password, Google, and anonymous sign-in.
- Guest record migration to the authenticated user's Firestore collection.
- Firestore-backed feedback submission.
- Light and dark themes.
- Turkish, English, and German localization.
- Android, iOS, and web targets through Flutter.

## Technology

| Area | Technology |
| --- | --- |
| Client | Flutter and Dart |
| Authentication | Firebase Authentication |
| Cloud data | Cloud Firestore |
| Local data | SharedPreferences and Path Provider |
| Images | Image Picker and Flutter Image Compress |
| OCR | Google ML Kit Text Recognition |
| API client | Dart `http` and multipart uploads |
| Backend API | PHP and MySQL |
| Localization | Easy Localization |

## Repository Structure

```text
lib/
  main.dart                         Application entry point and home screen
  screens/
    login_screen.dart               Authentication and guest mode
    new_link_screen.dart             Image selection and OCR workflow
    detail_screen.dart               Pair detail and deletion
    profile_screen.dart              Language, theme, and account settings
    feedback_screen.dart             Feedback form
  services/
    api_service.dart                 Authenticated PHP API client
    image_service.dart               Image compression
    local_storage_service.dart       Local guest record persistence
    ocr_service.dart                 Receipt text recognition
    theme_service.dart               Theme preference management
assets/translations/                 tr-TR, en-US, and de-DE translations
firestore.rules                      Firestore access rules
firebase.json                        Firebase Hosting and Firestore config
backend/link_api/                    Authenticated PHP/MySQL API
test/                                 Flutter tests
```

The PHP API source is versioned in `backend/link_api`. For a local XAMPP setup, copy that directory to `C:\xampp\htdocs\link_api` or configure Apache to serve it directly.

## Requirements

- Flutter SDK compatible with Dart `^3.13.1`.
- Android Studio and an Android SDK for Android builds.
- Xcode and CocoaPods for iOS builds on macOS.
- Firebase CLI for Hosting and Firestore deployment.
- A Firebase project with Authentication and Firestore enabled.
- PHP 8 or later, MySQL, and Apache for the local API.

## Local Setup

```bash
git clone https://github.com/mrkankilic27/Link.git
cd Link
flutter pub get
flutter analyze
flutter test
```

Run a development target with:

```bash
flutter run
flutter run -d chrome
```

### Firebase setup

1. Create or select the Firebase project used by the application.
2. Enable Email/Password, Google, and Anonymous providers in Firebase Authentication.
3. Add the local and production domains to Authentication's authorized domains.
4. Configure the native Firebase files for each platform:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
5. Confirm the web Firebase options in `lib/main.dart` match the intended project.
6. Deploy Firestore rules after reviewing them:

```bash
firebase deploy --only firestore:rules
```

The rules allow users to access only their own `users/{uid}/hooks` documents. Authenticated users can create feedback, but feedback cannot be read, edited, or deleted from the client.

## Local PHP API

The current development client uses:

- Web: `http://localhost/link_api`
- Android emulator: `http://10.0.2.2/link_api`

The PHP directory must be served by Apache and must contain an `uploads` directory. Create the `links` table in MySQL with at least:

```sql
CREATE TABLE links (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(128) NULL,
  baslik VARCHAR(200) NOT NULL,
  kiyafet_yolu VARCHAR(255) NOT NULL,
  fis_yolu VARCHAR(255) NOT NULL,
  not_metni TEXT NOT NULL,
  created_at DATETIME NOT NULL
);
```

The API adds the `user_id` column automatically when an older table is detected. The PHP runtime must have PDO MySQL, cURL, Fileinfo, and secure HTTPS certificate support enabled.

Configure the database connection with the `LINK_DB_HOST`, `LINK_DB_NAME`, `LINK_DB_USER`, and `LINK_DB_PASSWORD` environment variables. Do not commit production credentials.

### API endpoints

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `POST` | `add_link.php` | Upload two validated images and create a record |
| `GET` | `get_links.php` | Return records belonging to the authenticated user |
| `POST` | `delete.php` | Delete an owned record and its uploaded images |

All endpoints require a Firebase ID token in the header:

```text
Authorization: Bearer <firebase-id-token>
```

Uploads are limited to JPG, PNG, and WEBP images up to 10 MB per file. The server generates random filenames and never trusts the original client filename.

## Security Notes

- Never commit Firebase Admin credentials, service-account JSON files, signing keys, keystores, passwords, or `.env` files.
- Firebase web configuration values are client configuration, not server credentials. API authorization is enforced separately with Firebase ID tokens.
- Use HTTPS for the production PHP API. The local HTTP addresses are for development only.
- Restrict the PHP API's CORS origin to the production application domain instead of `*` before production deployment.
- Protect the PHP management panel with server-side authentication and CSRF protection before exposing it publicly.
- Keep the MySQL account limited to the application database and avoid using a blank production password.
- Review `firestore.rules` before every deployment.

## Platform Notes

The receipt OCR and file-based image workflow uses native plugins and is primarily intended for Android and iOS. A complete web-specific implementation should use browser image bytes, web-compatible compression, and a web OCR provider or a server-side OCR endpoint.

For a physical Android or iOS device, replace the development API host with a reachable HTTPS host or a LAN address. `10.0.2.2` is only the Android emulator alias for the host machine.

## Deployment

Build the web application and deploy Hosting with:

```bash
flutter clean
flutter pub get
flutter build web
firebase deploy --only hosting,firestore:rules
```

Before deployment, verify that:

- The production API uses HTTPS and is reachable from the deployed domain.
- Firebase Authentication authorized domains include the deployed domain.
- Firestore rules are deployed.
- The PHP API has cURL, Fileinfo, PDO MySQL, and a valid TLS certificate.
- Uploaded files are outside executable server paths or are configured as non-executable.

## Testing

Run the available checks with:

```bash
flutter analyze
flutter test
flutter build web
```

The PHP endpoints can be syntax-checked from an XAMPP installation with:

```powershell
Get-ChildItem 'C:\xampp\htdocs\link_api' -Filter '*.php' |
  ForEach-Object { & 'C:\xampp\php\php.exe' -l $_.FullName }
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for the complete license text.
