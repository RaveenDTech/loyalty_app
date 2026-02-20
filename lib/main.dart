import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/loyalty_provider.dart';
import 'core/providers/voucher_provider.dart';
import 'core/widgets/splash_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Light (white) status bar and system nav bar icons for entire app
  // Android: statusBarIconBrightness. iOS: statusBarBrightness (dark bar = light content)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light, // iOS: dark bar → white icons
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize local notifications (mobile only; web uses browser notifications)
  if (!kIsWeb) {
    await _initializeNotifications();
  }

  runApp(const MyApp());
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  static const _lightSystemUi = SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark, // iOS: dark bar → white icons
    statusBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  );

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: _lightSystemUi,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen(
            onInitializationComplete: _onSplashComplete,
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _lightSystemUi,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => LoyaltyProvider()),
          ChangeNotifierProvider(create: (_) => VoucherProvider()),
        ],
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp.router(
              title: 'DSI Loyalty App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
