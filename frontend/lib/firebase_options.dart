// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCxKccA6knzjd63tiXhrhqRmMPvAfKvR0Y',
    appId: '1:465022479910:web:2fe63f554ee9cd7c2440e7',
    messagingSenderId: '465022479910',
    projectId: 'levelup-d5d59',
    authDomain: 'levelup-d5d59.firebaseapp.com',
    storageBucket: 'levelup-d5d59.firebasestorage.app',
    measurementId: 'G-L3P0VVDHE0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCxKccA6knzjd63tiXhrhqRmMPvAfKvR0Y', // Taki sam jak web lub pobierz z Firebase Console
    appId: '1:465022479910:android:2fe63f554ee9cd7c2440e7', // Zmień na Android app ID
    messagingSenderId: '465022479910',
    projectId: 'levelup-d5d59',
    storageBucket: 'levelup-d5d59.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCxKccA6knzjd63tiXhrhqRmMPvAfKvR0Y', // Taki sam jak web lub pobierz z Firebase Console
    appId: '1:465022479910:ios:2fe63f554ee9cd7c2440e7', // Zmień na iOS app ID
    messagingSenderId: '465022479910',
    projectId: 'levelup-d5d59',
    storageBucket: 'levelup-d5d59.firebasestorage.app',
    iosBundleId: 'com.example.wkmobile', // Zmień na swój Bundle ID
  );
}