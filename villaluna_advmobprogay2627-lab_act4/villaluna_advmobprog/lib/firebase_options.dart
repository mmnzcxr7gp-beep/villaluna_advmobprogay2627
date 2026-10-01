// File generated for FlutterFire configuration.
// ignore_for_file: type=lint
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
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCBeJVWswXSzZW51JS9Q1ZLgsQI38vdXec',
    appId: '1:308278103038:web:d6f2d9e14921717086ceaf',
    messagingSenderId: '308278103038',
    projectId: 'villalunaadvmobprog2627',
    authDomain: 'villalunaadvmobprog2627.firebaseapp.com',
    storageBucket: 'villalunaadvmobprog2627.firebasestorage.app',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_ANDROID_DEMO_API_KEY_1234567890a',
    appId: '1:102938475612:android:abcdef1234567890abcdef',
    messagingSenderId: '102938475612',
    projectId: 'villaluna-advmobprog2627',
    storageBucket: 'villaluna-advmobprog2627.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_IOS_DEMO_API_KEY_1234567890abcdef',
    appId: '1:102938475612:ios:abcdef1234567890abcdef',
    messagingSenderId: '102938475612',
    projectId: 'villaluna-advmobprog2627',
    storageBucket: 'villaluna-advmobprog2627.appspot.com',
    iosBundleId: 'com.villaluna.villalunaAdvmobprog',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA_MACOS_DEMO_API_KEY_1234567890abcd',
    appId: '1:102938475612:ios:abcdef1234567890abcdef',
    messagingSenderId: '102938475612',
    projectId: 'villaluna-advmobprog2627',
    storageBucket: 'villaluna-advmobprog2627.appspot.com',
    iosBundleId: 'com.villaluna.villalunaAdvmobprog',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCBeJVWswXSzZW51JS9Q1ZLgsQI38vdXec',
    appId: '1:308278103038:web:d287f7f23a09bdb086ceaf',
    messagingSenderId: '308278103038',
    projectId: 'villalunaadvmobprog2627',
    authDomain: 'villalunaadvmobprog2627.firebaseapp.com',
    storageBucket: 'villalunaadvmobprog2627.firebasestorage.app',
  );
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyA_LINUX_DEMO_API_KEY_1234567890abcd',
    appId: '1:102938475612:web:abcdef1234567890abcdef',
    messagingSenderId: '102938475612',
    projectId: 'villaluna-advmobprog2627',
    authDomain: 'villaluna-advmobprog2627.firebaseapp.com',
    storageBucket: 'villaluna-advmobprog2627.appspot.com',
  );
}
