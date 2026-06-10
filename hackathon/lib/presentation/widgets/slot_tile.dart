import 'package:flutter/material.dart';
import '../../data/models/slot.dart';
import '../../theme/app_theme.dart';

class SlotTile extends StatelessWidget {
  final Slot slot;
  final VoidCallback? onTap;

  const SlotTile({super.key, required this.slot, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = slot.isBooked ? AppTheme.booked : AppTheme.available;
    final bg = slot.isBooked
        ? AppTheme.booked.withValues(alpha: 0.12)
        : AppTheme.available.withValues(alpha: 0.12);

    return GestureDetector(
      onTap: slot.isBooked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              slot.isBooked ? Icons.lock_rounded : Icons.access_time_rounded,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              slot.startTime,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              slot.isBooked ? 'Booked' : 'Open',
              style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
