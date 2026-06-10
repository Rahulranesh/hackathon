import 'package:flutter/material.dart';
import '../../data/models/venue.dart';
import '../../theme/app_theme.dart';
import 'card_3d.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback onTap;

  const VenueCard({super.key, required this.venue, required this.onTap});

  IconData get _sportIcon => venue.sport == 'badminton'
      ? Icons.sports_tennis_rounded
      : Icons.sports_soccer_rounded;

  Color get _sportColor =>
      venue.sport == 'badminton' ? AppTheme.courtBlue : AppTheme.available;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Card3D(
      width: MediaQuery.of(context).size.width - 32,
      height: 160,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppTheme.surface,
              AppTheme.cardBg,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: _sportColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _sportColor.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -35,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _sportColor.withValues(alpha: 0.15),
                      _sportColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _sportColor.withValues(alpha: 0.4),
                          _sportColor.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _sportColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _sportColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(_sportIcon, color: _sportColor, size: 32),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _VenueCardBody(
                      venue: venue,
                      sportColor: _sportColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _sportColor.withValues(alpha: 0.2),
                          _sportColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: _sportColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _VenueCardBody extends StatelessWidget {
  final Venue venue;
  final Color sportColor;

  const _VenueCardBody({required this.venue, required this.sportColor});

  String get _hours =>
      '${venue.openTime ?? '06:00'} – ${venue.closeTime ?? '22:00'}';

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        venue.name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      if (venue.locality != null) ...[
        Text(
          venue.locality!,
          style: TextStyle(
            fontSize: 12,
            color: sportColor,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
      ],
      Row(
        children: [
          Icon(Icons.location_on_outlined, size: 13, color: Colors.grey[500]),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              venue.address,
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: sportColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              venue.sport.toUpperCase(),
              style: TextStyle(
                color: sportColor,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 10, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  _hours,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (venue.rating != null)
            _MetaPill(
              icon: Icons.star_rounded,
              label: venue.reviewCount == null
                  ? venue.rating!.toStringAsFixed(1)
                  : '${venue.rating!.toStringAsFixed(1)} (${venue.reviewCount})',
              color: AppTheme.highlight,
            ),
          if (venue.sourceName != null)
            _MetaPill(
              icon: Icons.verified_rounded,
              label: venue.sourceName!,
              color: AppTheme.available,
            ),
        ],
      ),
    ],
  );
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 72),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
