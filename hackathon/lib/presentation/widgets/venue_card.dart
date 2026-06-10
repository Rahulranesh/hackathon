import 'package:flutter/material.dart';
import '../../data/models/venue.dart';
import '../../theme/app_theme.dart';

class VenueCard extends StatefulWidget {
  final Venue venue;
  final VoidCallback onTap;

  const VenueCard({super.key, required this.venue, required this.onTap});

  @override
  State<VenueCard> createState() => _VenueCardState();
}

class _VenueCardState extends State<VenueCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _sportColor => AppTheme.sportColor(widget.venue.sport);
  LinearGradient get _sportGradient => AppTheme.sportGradient(widget.venue.sport);
  
  IconData get _sportIcon => widget.venue.sport == 'badminton'
      ? Icons.sports_tennis_rounded
      : Icons.sports_soccer_rounded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _controller.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _controller.reverse();
            widget.onTap();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _sportColor.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _sportColor.withValues(alpha: _isPressed ? 0.2 : 0.1),
                  blurRadius: _isPressed ? 25 : 20,
                  offset: Offset(0, _isPressed ? 6 : 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background decoration
                Positioned(
                  right: -50,
                  top: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _sportColor.withValues(alpha: 0.1),
                          _sportColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Sport icon with gradient
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: _sportGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _sportColor.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _sportIcon,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Venue name and locality
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.venue.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.venue.locality != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: _sportColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          widget.venue.locality!,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: _sportColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          // Arrow button
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _sportColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: _sportColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Address
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 14,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.venue.address,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Sport tag
                          _Tag(
                            label: widget.venue.sport.toUpperCase(),
                            icon: _sportIcon,
                            color: _sportColor,
                            gradient: _sportGradient,
                          ),
                          
                          // Hours tag
                          _Tag(
                            label: '${widget.venue.openTime ?? "06:00"} - ${widget.venue.closeTime ?? "22:00"}',
                            icon: Icons.access_time,
                            color: AppTheme.textSecondary,
                          ),
                          
                          // Rating tag
                          if (widget.venue.rating != null)
                            _Tag(
                              label: '${widget.venue.rating!.toStringAsFixed(1)} ⭐',
                              icon: Icons.star_rounded,
                              color: const Color(0xFFFFA726),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final LinearGradient? gradient;
  
  const _Tag({
    required this.label,
    required this.icon,
    required this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? color.withValues(alpha: 0.15) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: gradient != null ? Colors.white : color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: gradient != null ? Colors.white : color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
