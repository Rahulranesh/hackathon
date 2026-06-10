import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/app_user.dart';
import '../providers/user_provider.dart';
import '../providers/venue_provider.dart';
import '../widgets/app_states.dart';
import '../widgets/skeleton_loaders.dart';
import 'venue_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // app icon with glow
              Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00C853).withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sports_rounded,
                      size: 40,
                      color: Color(0xFF00C853),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    curve: Curves.elasticOut,
                    duration: 800.ms,
                  ),
              const SizedBox(height: 32),
              Text(
                'QuickSlot',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
              const SizedBox(height: 8),
              Text(
                'Book sports slots instantly.\nNo waiting, no double-bookings.',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 15,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
              const SizedBox(height: 56),
              Text(
                'CONTINUE AS',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 16),
              Expanded(child: _buildUsers(provider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsers(UserProvider provider) {
    return switch (provider.state) {
      ViewState.idle || ViewState.loading => const UserListSkeleton(),
      ViewState.error => AppError(
        message: provider.errorMessage ?? 'Failed to load users',
        onRetry: provider.fetchUsers,
      ),
      ViewState.data when provider.users.isEmpty => const EmptyState(
        message: 'No users found. Start the backend seed first.',
        icon: Icons.person_off_outlined,
      ),
      ViewState.data => ListView.builder(
        itemCount: provider.users.length,
        itemBuilder: (_, i) => _UserTile(user: provider.users[i], index: i),
      ),
    };
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  final int index;
  const _UserTile({required this.user, required this.index});

  static const _colors = [
    Color(0xFF00C853),
    Color(0xFF00BCD4),
    Color(0xFFFFB300),
  ];
  static const _icons = [Icons.person, Icons.person_outline, Icons.face];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];

    return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.read<UserProvider>().login(user.id, user.name);
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, a, _) => const VenueListScreen(),
                    transitionsBuilder: (_, a, _, child) =>
                        FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.12),
                      color.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: 'avatar_${user.id}',
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 24,
                        child: Icon(
                          _icons[index % _icons.length],
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.phone ?? 'User ${user.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (600 + index * 120).ms, duration: 400.ms)
        .slideX(begin: 0.15, delay: (600 + index * 120).ms, duration: 400.ms);
  }
}
