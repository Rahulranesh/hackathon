import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/venue.dart';
import '../../data/models/slot.dart';
import '../providers/slot_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/user_provider.dart';
import '../providers/venue_provider.dart';
import '../widgets/slot_tile.dart';
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
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BookingSheet(
        slot: slot,
        venue: widget.venue,
        date: _slotProvider.formattedDate,
        userId: user.userId,
        slotProvider: _slotProvider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SlotProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.venue.name)),
      body: Column(
        children: [
          _DateStrip(date: provider.selectedDate, onTap: _pickDate),
          const SizedBox(height: 8),
          _Legend(),
          const SizedBox(height: 8),
          Expanded(child: _buildGrid(provider)),
        ],
      ),
    );
  }

  Widget _buildGrid(SlotProvider provider) {
    return switch (provider.state) {
      ViewState.loading || ViewState.idle => const AppLoading(),
      ViewState.error => AppError(
          message: provider.errorMessage ?? 'Failed to load slots',
          onRetry: () => _slotProvider.loadSlots(widget.venue.id),
        ),
      ViewState.data when provider.slots.isEmpty =>
        const EmptyState(message: 'No slots available for this date'),
      ViewState.data => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: provider.slots.length,
            itemBuilder: (_, i) => SlotTile(
              slot: provider.slots[i],
              onTap: () => _onSlotTap(provider.slots[i]),
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF242424),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF00C853)),
                const SizedBox(width: 10),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(date),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                const Icon(Icons.expand_more_rounded, color: Colors.grey),
              ],
            ),
          ),
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
            const Text('Available', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(width: 16),
            _dot(const Color(0xFFFF1744)),
            const SizedBox(width: 4),
            const Text('Booked', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );

  Widget _dot(Color c) =>
      Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}

class _BookingSheet extends StatefulWidget {
  final Slot slot;
  final Venue venue;
  final String date;
  final String userId;
  final SlotProvider slotProvider;

  const _BookingSheet({
    required this.slot,
    required this.venue,
    required this.date,
    required this.userId,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Slot booked successfully!'),
          backgroundColor: Color(0xFF00C853),
        ),
      );
    } else if (bookingProvider.actionState == BookingAction.slotTaken) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ Slot just taken! Try another.'),
          backgroundColor: Color(0xFFFF1744),
        ),
      );
      widget.slotProvider.refresh(widget.venue.id);
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const Text('Confirm Booking',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _Row(icon: Icons.stadium_rounded, label: widget.venue.name),
            const SizedBox(height: 10),
            _Row(icon: Icons.calendar_today_rounded, label: widget.date),
            const SizedBox(height: 10),
            _Row(
              icon: Icons.access_time_rounded,
              label: '${widget.slot.startTime} – ${widget.slot.endTime}',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _confirm,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Book Now'),
              ),
            ),
          ],
        ),
      );
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Row({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00C853)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15)),
        ],
      );
}
