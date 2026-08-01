import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/supabase_config.dart';
import 'services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  // Supabase başlatma
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
  );

  // Bildirim servisini başlatma
  await NotificationService.initialize();

  // Android 13+ (API 33) için bildirim izni isteme
  await _requestNotificationPermission();

  runApp(const ProviderScope(child: AracKiralamaApp()));
}

/// Android 13 (API 33) ve üzeri cihazlarda bildirim göndermek için
/// kullanıcıdan açık izin ister. İzin verilmezse bildirimler gösterilmez.
Future<void> _requestNotificationPermission() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin != null) {
    // 'Bildirimlere izin veriyor musunuz?' sistem dialogunu gösterir
    final bool? granted = await androidPlugin.requestNotificationsPermission();
    debugPrint('Bildirim izni: ${granted == true ? "Verildi ✅" : "Reddedildi ❌"}');

    // Tam zamanlı alarm izni de iste (Android 14+ için)
    final bool? exactAlarmGranted =
        await androidPlugin.requestExactAlarmsPermission();
    debugPrint(
        'Tam zamanlı alarm izni: ${exactAlarmGranted == true ? "Verildi ✅" : "Reddedildi ❌"}');
  }
}
