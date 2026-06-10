import 'package:flutter/material.dart';
import '../../data/models/slot.dart';
import '../../theme/app_theme.dart';

class SlotTile extends StatelessWidget {
  final Slot slot;
  final VoidCallback? onTap;

  const SlotTile({super.key, required this.slot, this.onTap});

  @override
  Widget build(BuildContext context) {
    final booked = slot.isBooked;
    final color = booked ? AppTheme.booked : AppTheme.available;
    final bgColor = booked
        ? AppTheme.booked.withValues(alpha: 0.08)
        : AppTheme.available.withValues(alpha: 0.08);
    final borderColor = booked
        ? AppTheme.booked.withValues(alpha: 0.3)
        : AppTheme.available.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: booked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: booked
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.available.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // status icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                booked ? Icons.lock_rounded : Icons.check_circle_outline_rounded,
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(height: 6),
            // time
            Text(
              slot.startTime,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              booked ? 'Taken' : 'Open',
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
