import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../providers/user_provider.dart';
import 'venue_list_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Icon(Icons.sports_rounded, size: 52, color: Color(0xFF00C853)),
              const SizedBox(height: 24),
              Text(
                'QuickSlot',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Book your sports slot instantly.',
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
              ),
              const SizedBox(height: 64),
              Text(
                'Sign in as',
                style: TextStyle(color: Colors.grey[400], fontSize: 13, letterSpacing: 1),
              ),
              const SizedBox(height: 16),
              ...kUsers.map((user) => _UserTile(user: user)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final Map<String, String> user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = [const Color(0xFF00C853), const Color(0xFF00BCD4), const Color(0xFFFFB300)];
    final idx = ['u1', 'u2', 'u3'].indexOf(user['id']!);
    final color = colors[idx];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.read<UserProvider>().login(user['id']!, user['name']!);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VenueListScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 22,
                child: Text(
                  user['name']![0],
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                user['name']!,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
