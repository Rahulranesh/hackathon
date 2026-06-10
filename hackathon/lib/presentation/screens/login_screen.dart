import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../data/models/app_user.dart';
import '../providers/user_provider.dart';
import '../providers/venue_provider.dart';
import '../widgets/app_states.dart';
import '../widgets/skeleton_loaders.dart';
import '../widgets/card_3d.dart';
import 'venue_list_screen.dart';
import '../../theme/app_theme.dart';

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
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // 3D app icon with animated glow
                Card3D(
                  width: 80,
                  height: 80,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.gradientStart,
                          AppTheme.gradientEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sports_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
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
                // Animated title with typewriter effect
                Row(
                  children: [
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'QuickSlot',
                          textStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          speed: const Duration(milliseconds: 150),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Book sports slots instantly.\nNo waiting, no double-bookings.',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 15,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 1200.ms).slideX(begin: -0.1),
                const SizedBox(height: 56),
                Text(
                  'CONTINUE AS',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn(delay: 1400.ms),
                const SizedBox(height: 16),
                Expanded(child: _buildUsers(provider)),
              ],
            ),
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
    AppTheme.gradientStart,
    AppTheme.gradientEnd,
    AppTheme.accent,
  ];
  static const _icons = [Icons.person, Icons.person_outline, Icons.face];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card3D(
        width: double.infinity,
        height: 90,
        onTap: () {
          context.read<UserProvider>().login(user.id, user.name);
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, a, secondaryAnimation) => const VenueListScreen(),
              transitionsBuilder: (_, a, secondaryAnimation, child) =>
                  FadeTransition(opacity: a, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassMorphism,
          child: Row(
            children: [
              Hero(
                tag: 'avatar_${user.id}',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 28,
                    child: Icon(
                      _icons[index % _icons.length],
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.phone ?? 'User ${user.id}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 22,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(delay: (1600 + index * 120).ms, duration: 400.ms)
    .slideX(begin: 0.15, delay: (1600 + index * 120).ms, duration: 400.ms)
    .shimmer(delay: (2000 + index * 120).ms, duration: 1500.ms);
  }
}
