// GENERATED PLACEHOLDER — replace this whole file by running:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// That command connects to YOUR Firebase project, creates the real
// config for Android/iOS/Web, and overwrites this file automatically.
// Do not edit the values below by hand — they are fake.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyDKyuyIf7cL8bMErucJwEiX1tdyDf3TIdw',
    appId: '1:395676311455:web:e9e553eadd1d2a9b1927aa',
    messagingSenderId: '395676311455',
    projectId: 'trackedu',
    authDomain: 'trackedu.firebaseapp.com',
    storageBucket: 'trackedu.firebasestorage.app',
  );

  static const android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'trackedu',
    storageBucket: 'trackedu.firebasestorage.app',
  );

  static const ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'trackedu',
    storageBucket: 'trackedu.firebasestorage.app',
    iosBundleId: 'com.example.learntrack',
  );
}
