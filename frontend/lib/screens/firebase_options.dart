// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'TWOJ_API_KEY_Z_FIREBASE_CONSOLE',
    appId: 'TWOJ_APP_ID_Z_FIREBASE_CONSOLE',
    messagingSenderId: 'TWOJ_SENDER_ID',
    projectId: 'TWOJ_PROJECT_ID',
    authDomain: 'TWOJ_PROJECT_ID.firebaseapp.com',
    storageBucket: 'TWOJ_PROJECT_ID.appspot.com',
  );

  // Dla innych platform możesz na razie zostawić puste wartości
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'android-api-key',
    appId: 'android-app-id',
    messagingSenderId: 'sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'ios-api-key',
    appId: 'ios-app-id',
    messagingSenderId: 'sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.yourapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'macos-api-key',
    appId: 'macos-app-id',
    messagingSenderId: 'sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.yourapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'windows-api-key',
    appId: 'windows-app-id',
    messagingSenderId: 'sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
  );
}