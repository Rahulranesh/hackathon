import 'package:flutter/material.dart';
import '../../data/models/booking.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onCancel;

  const BookingCard({super.key, required this.booking, required this.onCancel});

  Color get _sportColor =>
      booking.sport == 'badminton' ? const Color(0xFF00BCD4) : const Color(0xFF66BB6A);

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // sport icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _sportColor.withValues(alpha: 0.2),
                          _sportColor.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      booking.sport == 'badminton'
                          ? Icons.sports_tennis_rounded
                          : Icons.sports_soccer_rounded,
                      color: _sportColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.venueName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        if (booking.address != null)
                          Text(
                            booking.address!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
                    onPressed: onCancel,
                    tooltip: 'Cancel',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFF1744).withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // date and time chips
              Row(
                children: [
                  _Chip(
                    icon: Icons.calendar_today_rounded,
                    label: booking.bookingDate,
                    color: const Color(0xFF00C853),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    icon: Icons.access_time_rounded,
                    label: '${booking.startTime} – ${booking.endTime}',
                    color: const Color(0xFF00BCD4),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
