import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    _initializeNotifications();
    seedDummyPromotionNotification();
  }

  Future<void> _initializeNotifications() async {
    if (kIsWeb) return;
    // Configure notification channels (Android only)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'loyalty_notifications',
      'Loyalty Notifications',
      description: 'Notifications for loyalty requests and transactions',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!kIsWeb) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'loyalty_notifications',
        'Loyalty Notifications',
        channelDescription: 'Notifications for loyalty requests and transactions',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    }

    // Add to notifications list
    _notifications.insert(
      0,
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        timestamp: DateTime.now(),
        isRead: false,
        payload: payload,
      ),
    );
    _unreadCount++;
    notifyListeners();
  }

  /// Seeds a dummy promotion notification (e.g. latest shoe offer) if not already present.
  void seedDummyPromotionNotification() {
    const dummyId = 'dummy_promotion_shoe_offer';
    if (_notifications.any((n) => n.id == dummyId)) return;
    _notifications.insert(
      0,
      NotificationModel(
        id: dummyId,
        title: 'Latest shoe offer with 25% discount',
        body: 'SampathCards: 25% off with credit cards, 15% off with debit cards at dsifootcandy.lk. Valid 20th–23rd Feb 2026. Online only.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        payload: 'promotion:shoe_offer',
      ),
    );
    _unreadCount++;
    notifyListeners();
  }

  Future<void> sendSMSNotification(String phoneNumber, String message) async {
    // TODO: Integrate with SMS API (e.g., Twilio, AWS SNS, or local SMS gateway)
    debugPrint('Sending SMS to $phoneNumber: $message');
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    _unreadCount = 0;
    notifyListeners();
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  /// Optional payload for navigation (e.g. "promotion:shoe_offer").
  final String? payload;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.payload,
  });
}
