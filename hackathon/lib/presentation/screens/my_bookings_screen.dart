import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/user_provider.dart';
import '../providers/venue_provider.dart';
import '../widgets/booking_card.dart';
import '../widgets/app_states.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserProvider>().userId;
      context.read<BookingProvider>().fetchBookings(userId);
    });
  }

  Future<void> _cancel(int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final userId = context.read<UserProvider>().userId;
      await context.read<BookingProvider>().cancelBooking(bookingId, userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(BookingProvider provider) {
    return switch (provider.listState) {
      ViewState.loading || ViewState.idle => const AppLoading(),
      ViewState.error => AppError(
          message: provider.errorMessage ?? 'Failed to load bookings',
          onRetry: () {
            final userId = context.read<UserProvider>().userId;
            context.read<BookingProvider>().fetchBookings(userId);
          },
        ),
      ViewState.data when provider.bookings.isEmpty => const EmptyState(
          message: 'No bookings yet.\nHead to a venue to book a slot!',
          icon: Icons.event_busy_outlined,
        ),
      ViewState.data => ListView.builder(
          itemCount: provider.bookings.length,
          itemBuilder: (_, i) => BookingCard(
            booking: provider.bookings[i],
            onCancel: () => _cancel(provider.bookings[i].id),
          ),
        ),
    };
  }
}
