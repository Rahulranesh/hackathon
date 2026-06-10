import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/api_service.dart';
import 'data/repositories/venue_repository.dart';
import 'data/repositories/booking_repository.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/venue_provider.dart';
import 'presentation/providers/slot_provider.dart';
import 'presentation/providers/booking_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiService();
  final venueRepo = VenueRepository(api);
  final bookingRepo = BookingRepository(api);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
