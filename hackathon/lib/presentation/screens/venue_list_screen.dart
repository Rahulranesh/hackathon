import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/venue_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/admob_banner.dart';
import '../widgets/venue_card.dart';
import '../widgets/skeleton_loaders.dart';
import '../widgets/app_states.dart';
import 'venue_detail_screen.dart';
import 'my_bookings_screen.dart';
import 'login_screen.dart';

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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.sports_rounded, size: 20, color: Color(0xFF00C853)),
            ),
            const SizedBox(width: 10),
            const Text('QuickSlot'),
          ],
        ),
        actions: [
          // my bookings button
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.confirmation_num_outlined),
              tooltip: 'My Bookings',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
              ),
            ),
          ),
          // logout
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, size: 20),
              tooltip: 'Logout',
              onPressed: () {
                user.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // greeting + stats
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                Hero(
                  tag: 'avatar_${user.userId}',
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF00C853),
                    radius: 18,
                    child: Text(
                      user.userName.isNotEmpty ? user.userName[0] : '?',
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey ${user.userName}! 👋',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    Text(
                      'Find your perfect court',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const AdMobBanner(),
          // section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'VENUES NEAR YOU',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildBody(VenueProvider provider) {
    return switch (provider.state) {
      ViewState.loading || ViewState.idle => const VenueListSkeleton(),
      ViewState.error => AppError(
          message: provider.errorMessage ?? 'Something went wrong',
          onRetry: () => context.read<VenueProvider>().fetchVenues(),
        ),
      ViewState.data when provider.venues.isEmpty =>
        const EmptyState(message: 'No venues available', icon: Icons.stadium_outlined),
      ViewState.data => RefreshIndicator(
          color: const Color(0xFF00C853),
          onRefresh: () => context.read<VenueProvider>().fetchVenues(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: provider.venues.length,
            itemBuilder: (_, i) => VenueCard(
              venue: provider.venues[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VenueDetailScreen(venue: provider.venues[i]),
                ),
              ),
            ).animate().fadeIn(delay: (i * 80).ms, duration: 400.ms).slideY(begin: 0.1),
          ),
        ),
    };
  }
}
