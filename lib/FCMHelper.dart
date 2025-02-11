import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Helper class to manage Firebase Cloud Messaging (FCM) notifications
/// Handles notifications in foreground, background, and terminated states.
class FCMHelper {
// Private constructor for singleton pattern
  FCMHelper._();

// Singleton instance
  static final FCMHelper instance = FCMHelper._();



// FlutterLocalNotificationsPlugin instance for showing notifications
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Notification settings for Android
  static const AndroidInitializationSettings _initializationSettingsAndroid =
  AndroidInitializationSettings('ic_launcher_foreground');

  // Notification settings for iOS
  static const DarwinInitializationSettings _initializationSettingsIOS =
  DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: false,
    requestAlertPermission: true,
  );

  // Combined initialization settings
  static const InitializationSettings _initializationSettings =
  InitializationSettings(
    android: _initializationSettingsAndroid,
    iOS: _initializationSettingsIOS,
  );

  /// Initializes FCM and requests notification permissions
  Future<void> init() async {
    // Request notification permissions from the user
    NotificationSettings notificationSettings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Check if the user granted permissions
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      dev.log('User granted permission');
      _setFirebaseMessagingListener(); // Setup foreground and background listeners
      listenFirebaseTerminateState(); // Handle terminated state
    } else {
      dev.log('User declined or has not accepted permission');
    }

    // Initialize the local notifications plugin
    await _flutterLocalNotificationsPlugin.initialize(
      _initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Log the device FCM token
    getToken();
  }

  /// Sets up listeners for FCM notifications
  void _setFirebaseMessagingListener() {
    // Listener for foreground notifications
    FirebaseMessaging.onMessage.listen((message) {
      dev.log("Firebase onMessage: ${message.data}");
      showNotification(message); // Show notification in the foreground
    });

    // Listener for notifications tapped when the app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      dev.log("Firebase onMessageOpenedApp: ${message.data}");
      _handleNotificationClick(message.data); // Handle notification click
    });
  }

  /// Handles notifications when the app is launched from a terminated state
  void listenFirebaseTerminateState() {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        dev.log("Firebase terminate state message: ${message.data}");
        _handleNotificationClick(message.data); // Handle notification click
      }
    });
  }

  /// Shows a notification using FlutterLocalNotificationsPlugin
  Future<void> showNotification(RemoteMessage message) async {
    // Android-specific notification details
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'com.example.fcm', // Channel ID
      'High Importance Notifications', // Channel name
      channelDescription:
      "This channel is responsible for all the local notifications",
      importance: Importance.max,
      priority: Priority.high,
      icon: "@mipmap/ic_launcher",
    );

    // iOS-specific notification details
    const DarwinNotificationDetails iOSNotificationDetails =
    DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    // Combined notification details
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    // Show the notification
    await _flutterLocalNotificationsPlugin.show(
      Random().nextInt(100), // Generate a random ID for the notification
      message.notification?.title ?? "No Title", // Notification title
      message.notification?.body ?? "No Body", // Notification body
      notificationDetails,
      payload: jsonEncode(message.data), // Include notification data as payload
    );
  }

  /// Handles notification click when app is in the foreground
  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse details) async {
    if (details.payload != null) {
      final data = jsonDecode(details.payload!); // Parse payload JSON
      _handleNotificationClick(data); // Process the notification data
    }
  }

  /// Processes notification clicks and redirects the user based on notification data
  void _handleNotificationClick(Map<String, dynamic> data) {
    dev.log("Handle notification click with data: $data");
    // Add custom redirection logic here based on your app requirements
  }

  /// Retrieves and logs the FCM token for the device
  Future<String> getToken() async {
    String? token = Platform.isIOS
        ? await FirebaseMessaging.instance.getAPNSToken()
        : await FirebaseMessaging.instance.getToken();
    dev.log("FCM Token: $token");
    return token ?? "No Token Found";
  }

  /// Handles notifications when the app is in the background
  static Future<void> handleBackgroundNotification(RemoteMessage message) async {
    dev.log("Handling background notification: ${message.data}");
    await FCMHelper.instance.showNotification(message); // Show the notification
  }
}

// Background handler for FCM notifications
Future<void> backgroundHandler(RemoteMessage message) async {
  await FCMHelper.handleBackgroundNotification(message);
}