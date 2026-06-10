import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;
import 'data/services/api_service.dart';
import 'data/repositories/venue_repository.dart';
import 'data/repositories/booking_repository.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/venue_provider.dart';
import 'presentation/providers/slot_provider.dart';
import 'presentation/providers/booking_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'theme/app_theme.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log('🔔 Background message: ${message.notification?.title}', name: 'Firebase');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0E27),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize services
  await MobileAds.instance.initialize();
  await NotificationService().init();

  final api = ApiService();
  final venueRepo = VenueRepository(api);
  final bookingRepo = BookingRepository(api);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(api)),
        ChangeNotifierProvider(create: (_) => VenueProvider(venueRepo)),
        ChangeNotifierProvider(create: (_) => SlotProvider(venueRepo)),
        ChangeNotifierProvider(create: (_) => BookingProvider(bookingRepo)),
      ],
      child: const QuickSlotApp(),
    ),
  );
}

class QuickSlotApp extends StatelessWidget {
  const QuickSlotApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'QuickSlot',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: const LoginScreen(),
  );
}
