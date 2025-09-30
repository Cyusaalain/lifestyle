import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initNotifications(String uid) async {
    // Request permission
    await _fcm.requestPermission();

    // Get FCM token
    final token = await _fcm.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'pushTokens': FieldValue.arrayUnion([token]),
      });
    }
  }
}
