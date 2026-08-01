import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (kIsWeb) return;
    
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
    
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleRentalEndNotification({
    required String rentalId,
    required DateTime endTime,
    required String carName,
  }) async {
    if (kIsWeb) return;
    
    final int notificationId = rentalId.hashCode;

    await _plugin.zonedSchedule(
      notificationId,
      'Süre Doldu!',
      '$carName aracının kiralama süresi sona erdi!',
      tz.TZDateTime.from(endTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rental_channel',
          'Kiralama Bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          fullScreenIntent: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(String rentalId) async {
    if (kIsWeb) return;
    await _plugin.cancel(rentalId.hashCode);
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_channel',
        'Anlık Bildirimler',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }
}
