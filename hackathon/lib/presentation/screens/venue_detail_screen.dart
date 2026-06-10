import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/venue.dart';
import '../../data/models/slot.dart';
import '../providers/slot_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/user_provider.dart';
import '../providers/venue_provider.dart';
import '../../core/notifications.dart';
import '../widgets/slot_tile.dart';
import '../widgets/skeleton_loaders.dart';
import '../widgets/app_states.dart';

class VenueDetailScreen extends StatefulWidget {
  final Venue venue;
  const VenueDetailScreen({super.key, required this.venue});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  late final SlotProvider _slotProvider;

  @override
  void initState() {
    super.initState();
    _slotProvider = context.read<SlotProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slotProvider.loadSlots(widget.venue.id);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _slotProvider.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00C853),
            surface: Color(0xFF1A1A1A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      _slotProvider.changeDate(picked, widget.venue.id);
    }
  }

  void _onSlotTap(Slot slot) {
    final user = context.read<UserProvider>();
    final bookingProvider = context.read<BookingProvider>();
    bookingProvider.resetAction();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(
        slot: slot,
        venue: widget.venue,
        date: _slotProvider.formattedDate,
        userId: user.userId,
        userName: user.userName,
        slotProvider: _slotProvider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SlotProvider>();
    final sportColor = widget.venue.sport == 'badminton'
        ? const Color(0xFF00BCD4)
        : const Color(0xFF66BB6A);

    return Scaffold(
      appBar: AppBar(title: Text(widget.venue.name)),
      body: Column(
        children: [
          // venue info header
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  sportColor.withValues(alpha: 0.15),
                  sportColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: sportColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  widget.venue.sport == 'badminton'
                      ? Icons.sports_tennis_rounded
                      : Icons.sports_soccer_rounded,
                  color: sportColor,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.venue.address,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      if (widget.venue.locality != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.venue.locality!,
                          style: TextStyle(
                            color: sportColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _HeaderPill(
                            label: widget.venue.sport.toUpperCase(),
                            color: sportColor,
                          ),
                          if (widget.venue.rating != null)
                            _HeaderPill(
                              label: widget.venue.reviewCount == null
                                  ? widget.venue.rating!.toStringAsFixed(1)
                                  : '${widget.venue.rating!.toStringAsFixed(1)} (${widget.venue.reviewCount})',
                              color: const Color(0xFFFFB300),
                              icon: Icons.star_rounded,
                            ),
                          if (widget.venue.sourceName != null)
                            _HeaderPill(
                              label: widget.venue.sourceName!,
                              color: const Color(0xFF00C853),
                              icon: Icons.verified_rounded,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // slot count badge
                if (provider.state == ViewState.data)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.slots.where((s) => !s.isBooked).length} open',
                      style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          // date picker strip
          _DateStrip(date: provider.selectedDate, onTap: _pickDate),
          const SizedBox(height: 4),
          _Legend(),
          const SizedBox(height: 8),
          Expanded(child: _buildGrid(provider)),
        ],
      ),
    );
  }

  Widget _buildGrid(SlotProvider provider) {
    return switch (provider.state) {
      ViewState.loading || ViewState.idle => const SlotGridSkeleton(),
      ViewState.error => AppError(
        message: provider.errorMessage ?? 'Failed to load slots',
        onRetry: () => _slotProvider.loadSlots(widget.venue.id),
      ),
      ViewState.data when provider.slots.isEmpty => const EmptyState(
        message: 'No slots available for this date',
      ),
      ViewState.data => RefreshIndicator(
        color: const Color(0xFF00C853),
        onRefresh: () => _slotProvider.refresh(widget.venue.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: provider.slots.length,
            itemBuilder: (_, i) =>
                SlotTile(
                      slot: provider.slots[i],
                      onTap: () => _onSlotTap(provider.slots[i]),
                    )
                    .animate()
                    .fadeIn(delay: (i * 30).ms, duration: 300.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      delay: (i * 30).ms,
                      duration: 300.ms,
                    ),
          ),
        ),
      ),
    };
  }
}

class _DateStrip extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  const _DateStrip({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isToday =
        DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF242424),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: Color(0xFF00C853),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  DateFormat('EEEE, d MMM yyyy').format(date),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      color: Color(0xFF00C853),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              const Icon(Icons.expand_more_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _HeaderPill({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 3),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 90),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        _dot(const Color(0xFF00C853)),
        const SizedBox(width: 4),
        const Text(
          'Available',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(width: 16),
        _dot(const Color(0xFFFF1744)),
        const SizedBox(width: 4),
        const Text(
          'Booked',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const Spacer(),
        Icon(Icons.refresh_rounded, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          'Auto-refresh',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    ),
  );

  Widget _dot(Color c) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}

class _BookingSheet extends StatefulWidget {
  final Slot slot;
  final Venue venue;
  final String date;
  final String userId;
  final String userName;
  final SlotProvider slotProvider;

  const _BookingSheet({
    required this.slot,
    required this.venue,
    required this.date,
    required this.userId,
    required this.userName,
    required this.slotProvider,
  });

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    final bookingProvider = context.read<BookingProvider>();
    final success = await bookingProvider.bookSlot(
      widget.slot.id,
      widget.date,
      widget.userId,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      _showSuccessSnackbar();
      NotificationService().showBookingConfirmed(
        widget.venue.name,
        '${widget.slot.startTime} – ${widget.slot.endTime}',
      );
      widget.slotProvider.refresh(widget.venue.id);
    } else if (bookingProvider.actionState == BookingAction.slotTaken) {
      Navigator.pop(context);
      _showTakenSnackbar();
      widget.slotProvider.refresh(widget.venue.id);
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage ?? 'Booking failed'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.black,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Booked ${widget.slot.startTime} – ${widget.slot.endTime}!',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showTakenSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Slot just taken by someone else! Try another.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF1744),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Color(0xFF1A1A1A),
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Confirm Booking',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          // booking details card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF242424),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.stadium_rounded,
                  label: widget.venue.name,
                ),
                const SizedBox(height: 14),
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: widget.date,
                ),
                const SizedBox(height: 14),
                _DetailRow(
                  icon: Icons.access_time_rounded,
                  label: '${widget.slot.startTime} – ${widget.slot.endTime}',
                ),
                const SizedBox(height: 14),
                _DetailRow(icon: Icons.person_rounded, label: widget.userName),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // book button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _loading ? null : _confirm,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Book Now', style: TextStyle(fontSize: 16)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    ),
  ).animate().slideY(begin: 0.3, duration: 300.ms, curve: Curves.easeOutCubic);
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF00C853).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF00C853)),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );
}
