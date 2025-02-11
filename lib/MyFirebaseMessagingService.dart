import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyFirebaseMessagingService {
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print("Background Message: ${message.messageId}");
  }
}
