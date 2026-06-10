import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/booking_provider.dart';
import '../providers/user_provider.dart';
import '../providers/venue_provider.dart';
import '../widgets/booking_card.dart';
import '../widgets/skeleton_loaders.dart';
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
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Booking?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel Booking', style: TextStyle(color: Color(0xFFFF1744))),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final userId = context.read<UserProvider>().userId;
      await context.read<BookingProvider>().cancelBooking(bookingId, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking cancelled'),
            backgroundColor: Colors.grey[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          if (provider.listState == ViewState.data && provider.bookings.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  '${provider.bookings.length}',
                  style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12,
                  ),
                ),
                backgroundColor: const Color(0xFF00C853),
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(BookingProvider provider) {
    return switch (provider.listState) {
      ViewState.loading || ViewState.idle => const BookingListSkeleton(),
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
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
      ViewState.data => RefreshIndicator(
          color: const Color(0xFF00C853),
          onRefresh: () {
            final userId = context.read<UserProvider>().userId;
            return context.read<BookingProvider>().fetchBookings(userId);
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: provider.bookings.length,
            itemBuilder: (_, i) => BookingCard(
              booking: provider.bookings[i],
              onCancel: () => _cancel(provider.bookings[i].id),
            ).animate().fadeIn(delay: (i * 80).ms, duration: 400.ms).slideX(begin: 0.1),
          ),
        ),
    };
  }
}
