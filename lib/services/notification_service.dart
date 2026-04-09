import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/plant.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    try {
      await _plugin.initialize(initSettings);
      _initialized = true;
    } catch (e) {
      // Notifications may not be supported on this platform
      _initialized = false;
    }
  }

  Future<void> showWateringReminder(Plant plant) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'watering_channel',
      'Watering Reminders',
      channelDescription: 'Reminders to water your plants',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _plugin.show(
        plant.id.hashCode,
        '💧 Time to water ${plant.name}!',
        'Your ${plant.name} needs watering today.',
        notificationDetails,
      );
    } catch (_) {}
  }

  Future<void> cancelReminder(String plantId) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(plantId.hashCode);
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  Future<void> checkAndNotify(List<Plant> plants) async {
    if (!_initialized) return;

    for (final plant in plants) {
      if (plant.needsWatering) {
        await showWateringReminder(plant);
      }
    }
  }
}
