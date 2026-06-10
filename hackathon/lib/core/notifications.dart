import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initSettings = InitializationSettings(android: androidInitSettings);
    await _notificationsPlugin.initialize(settings: initSettings);
  }

  Future<void> showBookingConfirmed(String venueName, String time) async {
    const androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'Booking Notifications',
      channelDescription: 'Notifications for confirmed bookings',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      id: DateTime.now().millisecond,
      title: 'Booking Confirmed!',
      body: 'You are confirmed for $venueName at $time.',
      notificationDetails: details,
    );
  }
}
