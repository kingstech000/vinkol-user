import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupLocalNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  factory NotificationService() => _instance;
  // Add a field to hold the ProviderContainer
  late ProviderContainer _container;

  NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void setProviderContainer(ProviderContainer container) {
    _container = container;
  }

  Future<void> initialize() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);
    });

    // Configure background & terminated notification clicks
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigation(message.data);
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notifications when app is launched from terminated state
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNavigation(initialMessage.data);
    }

    setupLocalNotifications();
  }

  Future<void> setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap-hdpi/ic_launcher.png');

    final DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings();

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNavigation(jsonDecode(response.payload!));
      },
    );
  }

  Future<String> getToken() async {
    final token = await _firebaseMessaging.getToken() ?? '';
    print(token);
    return token;
  }

  Future<void> showNotification(RemoteMessage message) async {
    final data = message.data;
    final String? sound = data['sound'];
    final String title = message.notification?.title ?? "New Notification";
    final String body = message.notification?.body ?? "";

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
    );

    DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      sound: sound != null ? '$sound.wav' : '',
    );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: jsonEncode(data),
    );
  }

  void _handleNavigation(Map<String, dynamic> data) {
    final String? orderId = data['order'];

    final String? page = data['page'];
    final String? orderType = data['orderType'];

    // Now you can access providers using _container.read() or _container.watch()
    if (page != null) {
      _container.read(navigationIndexProvider.notifier).state = int.parse(page);
    }

    if (orderId != null && orderType != null) {
      debugPrint('Order Type: $orderType');
      if (orderType.toLowerCase() == 'delivery') {
        NavigationService.instance
            .navigateTo(NavigatorRoutes.bookingOrderScreen);
      } else {
        NavigationService.instance.navigateTo(NavigatorRoutes.storeOrderScreen);
      }
    }

    return;
  }
}
