# Firebase Project Registration

To set up Firebase for your Dart project, follow these steps:

### 1. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Log in or out of Firebase to ensure you are using the correct Google account:

```bash
firebase login/logout
```

### 2. Configure Firebase

Run the following command and choose Android and iOS platforms to automatically register your app with Firebase and download configuration files:

```bash
flutterfire configure
```

### 3. Add Firebase Core

Add the basic Firebase configuration to your project:

```bash
flutter pub add firebase_core
```

Use the version `^2.22.0` as of the last documentation update:

```yaml
dependencies:
  firebase_core: ^2.22.0
```

### 4. Set Up Push Notification Handling

For push notification handling, add the following dependencies:

```bash
flutter pub add firebase_messaging
flutter pub add flutter_local_notifications:9.6.1
```

**Note:** The version `9.6.1` is used for `flutter_local_notifications`. Be aware that there are changes in newer versions; use this version for compatibility.

Check your `android/build.gradle` file for the following versions:

```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:7.4.2'
    classpath 'com.google.gms:google-services:4.3.14'
}
```

Ensure these versions are up-to-date to avoid build issues.

### 5. Android Configuration

In your `app/src/main/AndroidManifest.xml`, add the following to create a notification channel:

```xml
<meta-data
    android:name="flutterEmbedding"
    android:value="2" />
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="push_notification_channel" />
```

### 6. iOS Configuration

Open your iOS project in Xcode and add the following capabilities:

- Push notifications
- Background modes
  - Background fetch
  - Remote notifications

For additional iOS and Firebase configuration, follow these steps:

- Generate a push notification certificate from Apple Developer account.
- Upload the certificate to Firebase.
- Download the generated certificate from Firebase.

### 7. Import Code

In your Dart code, initialize the `NotificationService` in your mail file:

```dart
import 'path_to_notification_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initNotificationService();

  final token = await NotificationService.requestPermissionWithTokenOrNull();
  print("$token");
  //If subscribe based sent notification then use this token

  runApp(MaterialApp(
    home: NotificationService(child: OnboardingPage()),
  ));
}

```

Now, you can request the token using the `NotificationService` in your app.

Remember to replace `path_to_notification_service.dart` with the actual path to your notification service file.

repository: https://github.com/radikris/push_notification_service
