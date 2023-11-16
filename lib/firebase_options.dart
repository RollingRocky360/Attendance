// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyDnlRBMSrrrFyho3FpKneBQsdX9BLAyw9U',
    appId: '1:852269452607:web:691aaba669c426460e178a',
    messagingSenderId: '852269452607',
    projectId: 'attendance-e29fe',
    authDomain: 'attendance-e29fe.firebaseapp.com',
    storageBucket: 'attendance-e29fe.appspot.com',
    measurementId: 'G-WKTTK95ST0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBeJSDB1QFfvK-llvdJVE9xlsDeYssvvA4',
    appId: '1:852269452607:android:20b967508c4aedc90e178a',
    messagingSenderId: '852269452607',
    projectId: 'attendance-e29fe',
    storageBucket: 'attendance-e29fe.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAAnRmmO9EStAq7FlkIOcvBOH3toUkea8',
    appId: '1:852269452607:ios:5caa4b1d653190b40e178a',
    messagingSenderId: '852269452607',
    projectId: 'attendance-e29fe',
    storageBucket: 'attendance-e29fe.appspot.com',
    iosClientId: '852269452607-uaugpp9l92t0k8u54d8fc984kluunneq.apps.googleusercontent.com',
    iosBundleId: 'com.example.attendance',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBAAnRmmO9EStAq7FlkIOcvBOH3toUkea8',
    appId: '1:852269452607:ios:2a0afa44e8cf8aed0e178a',
    messagingSenderId: '852269452607',
    projectId: 'attendance-e29fe',
    storageBucket: 'attendance-e29fe.appspot.com',
    iosClientId: '852269452607-0hks79gjhovk182o2u1p90lsvusfr7tf.apps.googleusercontent.com',
    iosBundleId: 'com.example.attendance.RunnerTests',
  );
}