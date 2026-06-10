import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/venue_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/admob_banner.dart';
import '../widgets/venue_card.dart';
import '../widgets/skeleton_loaders.dart';
import '../widgets/app_states.dart';
import '../../theme/app_theme.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: AppTheme.primaryGradientBox(radius: 12),
              child: const Icon(
                Icons.sports_rounded,
                size: 20,
                color: Colors.white,
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(
              duration: 2000.ms,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 12),
            const Text('QuickSlot'),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.border,
                ),
              ),
              child: const Icon(
                Icons.confirmation_num_outlined,
                size: 20,
              ),
            ),
            tooltip: 'My Bookings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.border,
                ),
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 20,
              ),
            ),
            tooltip: 'Logout',
            onPressed: () {
              user.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.surface.withValues(alpha: 0.3),
              AppTheme.background,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 56),
            
            _buildUserGreeting(user),
            
            const SizedBox(height: 16),
            const AdMobBanner(),
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'AVAILABLE VENUES',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  if (provider.state == ViewState.data)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${provider.venues.length} Venues',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGreeting(UserProvider user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Hero(
            tag: 'avatar_${user.userId}',
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.glowShadow(AppTheme.primary),
              ),
              child: Center(
                child: Text(
                  user.userName.isNotEmpty ? user.userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back! 👋',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  user.userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms)
    .slideX(begin: -0.2, duration: 400.ms);
  }

  Widget _buildBody(VenueProvider provider) {
    return switch (provider.state) {
      ViewState.loading || ViewState.idle => const VenueListSkeleton(),
      ViewState.error => AppError(
          message: provider.errorMessage ?? 'Something went wrong',
          onRetry: () => context.read<VenueProvider>().fetchVenues(),
        ),
      ViewState.data when provider.venues.isEmpty =>
        const EmptyState(
          message: 'No venues available',
          icon: Icons.stadium_outlined,
        ),
      ViewState.data => RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.cardBg,
          onRefresh: () => context.read<VenueProvider>().fetchVenues(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: provider.venues.length,
            padding: const EdgeInsets.only(bottom: 20),
            itemBuilder: (_, i) => VenueCard(
              venue: provider.venues[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VenueDetailScreen(venue: provider.venues[i]),
                ),
              ),
            )
            .animate(delay: (i * 80).ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, duration: 400.ms),
          ),
        ),
    };
  }
}
