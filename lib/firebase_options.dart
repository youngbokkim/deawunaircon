// 웹앱 추가 시 Firebase Console에서 발급한 설정입니다.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAvsIOg1ULprylkURhOQcQG05Dqs8ZWJMA',
    appId: '1:810192741805:web:316ec02530d90ad4272d24',
    messagingSenderId: '810192741805',
    projectId: 'deawunaircon',
    authDomain: 'deawunaircon.firebaseapp.com',
    storageBucket: 'deawunaircon.firebasestorage.app',
    measurementId: 'G-QDSWMBXJ3E',
  );
}
