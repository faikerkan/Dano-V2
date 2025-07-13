import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> saveTokenToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('FCM token kaydedilemedi: $e');
    }
  }

  static Future<void> initialize() async {
    await _messaging.requestPermission();
    await saveTokenToFirestore();
    _messaging.onTokenRefresh.listen((token) async {
      await saveTokenToFirestore();
    });
  }
} 