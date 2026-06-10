import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/venue_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/venue_card.dart';
import '../widgets/app_states.dart';
import 'venue_detail_screen.dart';
import 'my_bookings_screen.dart';

class VenueListScreen extends StatefulWidget {
  const VenueListScreen({super.key});

  @override
  State<VenueListScreen> createState() => _VenueListScreenState();
}

class _VenueListScreenState extends State<VenueListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VenueProvider>().fetchVenues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final provider = context.watch<VenueProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickSlot'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              icon: const Icon(Icons.confirmation_num_outlined, size: 18),
              label: const Text('My Bookings'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Hello, ${user.userName} 👋',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildBody(VenueProvider provider) {
    return switch (provider.state) {
      ViewState.loading || ViewState.idle => const AppLoading(),
      ViewState.error => AppError(
          message: provider.errorMessage ?? 'Something went wrong',
          onRetry: () => context.read<VenueProvider>().fetchVenues(),
        ),
      ViewState.data when provider.venues.isEmpty =>
        const EmptyState(message: 'No venues available', icon: Icons.stadium_outlined),
      ViewState.data => ListView.builder(
          itemCount: provider.venues.length,
          itemBuilder: (_, i) => VenueCard(
            venue: provider.venues[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VenueDetailScreen(venue: provider.venues[i]),
              ),
            ),
          ),
        ),
    };
  }
}
