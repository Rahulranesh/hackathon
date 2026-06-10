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
import '../widgets/slot_tile.dart';
import '../widgets/skeleton_loaders.dart';
import '../widgets/app_states.dart';
import '../../theme/app_theme.dart';

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
          colorScheme: ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.cardBg,
            onSurface: AppTheme.textPrimary,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: AppTheme.cardBg,
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
    final sportColor = AppTheme.sportColor(widget.venue.sport);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.venue.name),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sportColor.withValues(alpha: 0.1),
              AppTheme.background,
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 56),
            
            _buildVenueHeader(sportColor, provider),
            _buildDatePicker(provider),
            const SizedBox(height: 16),
            _buildLegend(provider),
            const SizedBox(height: 12),
            Expanded(child: _buildGrid(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueHeader(Color sportColor, SlotProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: sportColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: sportColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.sportGradient(widget.venue.sport),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppTheme.glowShadow(sportColor),
                ),
                child: Icon(
                  widget.venue.sport == 'badminton'
                      ? Icons.sports_tennis_rounded
                      : Icons.sports_soccer_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.venue.locality != null)
                      Text(
                        widget.venue.locality!,
                        style: TextStyle(
                          color: sportColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      widget.venue.address,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (provider.state == ViewState.data)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.successGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${provider.slots.where((s) => !s.isBooked).length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'OPEN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                label: widget.venue.sport.toUpperCase(),
                icon: Icons.sports,
                gradient: AppTheme.sportGradient(widget.venue.sport),
              ),
              _InfoChip(
                label: '${widget.venue.openTime ?? "06:00"} - ${widget.venue.closeTime ?? "22:00"}',
                icon: Icons.access_time,
                color: AppTheme.textSecondary,
              ),
              if (widget.venue.rating != null)
                _InfoChip(
                  label: '${widget.venue.rating!.toStringAsFixed(1)} ⭐',
                  icon: Icons.star_rounded,
                  color: const Color(0xFFFFA726),
                ),
            ],
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms)
    .slideY(begin: -0.1, duration: 400.ms);
  }

  Widget _buildDatePicker(SlotProvider provider) {
    final isToday = DateFormat('yyyy-MM-dd').format(provider.selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMM d, yyyy').format(provider.selectedDate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.expand_more_rounded,
                color: AppTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(SlotProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _legendDot(AppTheme.success),
          const SizedBox(width: 6),
          Text(
            'Available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 20),
          _legendDot(AppTheme.error),
          const SizedBox(width: 6),
          Text(
            'Booked',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Icon(Icons.refresh_rounded, size: 14, color: AppTheme.textTertiary),
          const SizedBox(width: 6),
          Text(
            'Auto-refresh',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildGrid(SlotProvider provider) {
    return switch (provider.state) {
      ViewState.idle => const SlotGridSkeleton(),
      ViewState.loading => const SlotGridSkeleton(),
      ViewState.error => AppError(
        message: provider.errorMessage ?? 'Failed to load slots',
        onRetry: () => _slotProvider.loadSlots(widget.venue.id),
      ),
      ViewState.data when provider.slots.isEmpty => const EmptyState(
        message: 'No slots available for this date',
      ),
      ViewState.data => RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.cardBg,
        onRefresh: () => _slotProvider.refresh(widget.venue.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: provider.slots.length,
            itemBuilder: (_, i) => SlotTile(
              slot: provider.slots[i],
              onTap: () => _onSlotTap(provider.slots[i]),
            )
            .animate(delay: (i * 25).ms)
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 300.ms),
          ),
        ),
      ),
    };
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final LinearGradient? gradient;

  const _InfoChip({
    required this.label,
    required this.icon,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null && color != null
            ? color!.withValues(alpha: 0.15)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: gradient != null ? Colors.white : color,
          ),
          const SizedBox(width: 5),
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
      widget.slotProvider.refresh(widget.venue.id);
    } else if (bookingProvider.actionState == BookingAction.slotTaken) {
      Navigator.pop(context);
      _showTakenSnackbar();
      widget.slotProvider.refresh(widget.venue.id);
    } else {
      setState(() => _loading = false);
      _showErrorSnackbar(bookingProvider.errorMessage ?? 'Booking failed');
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Booking Confirmed!',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${widget.slot.startTime} - ${widget.slot.endTime}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showTakenSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Slot Already Taken!',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Text(
                    'Someone just booked it. Try another slot.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
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
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Confirm Booking',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.stadium_rounded,
                    label: widget.venue.name,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: widget.date,
                    color: AppTheme.success,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: '${widget.slot.startTime} - ${widget.slot.endTime}',
                    color: AppTheme.accent,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.person_rounded,
                    label: widget.userName,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _loading ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt_rounded, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Confirm Booking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    )
    .animate()
    .slideY(begin: 0.3, duration: 350.ms, curve: Curves.easeOutCubic)
    .fadeIn(duration: 350.ms);
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
