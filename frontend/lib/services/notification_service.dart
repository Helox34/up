// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _notifications;

  Future<void> initialize() async {
    _notifications = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  // Zaplanuj codzienne przypomnienie
  Future<void> scheduleDailyReminder() async {
    await _notifications.zonedSchedule(
      0,
      'Czas na trening! 💪',
      'Sprawdź swoje wyzwania i zaktualizuj postępy',
      _nextInstanceOfTime(18, 0), // 18:00
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          channelDescription: 'Daily workout reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Powiadomienie o postępie
  Future<void> showProgressNotification(String challengeName, double progress) async {
    await _notifications.show(
      1,
      'Postęp w wyzwaniu! 🎯',
      '$challengeName: ${(progress * 100).round()}% ukończone',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'progress_updates',
          'Progress Updates',
          channelDescription: 'Challenge progress notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  // Powiadomienie o ukończeniu
  Future<void> showCompletionNotification(String challengeName) async {
    await _notifications.show(
      2,
      'Wyzwanie ukończone! 🏆',
      'Gratulacje! Ukończyłeś: $challengeName',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'completions',
          'Challenge Completions',
          channelDescription: 'Challenge completion notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  // Pomocnicza metoda do obliczania czasu
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}