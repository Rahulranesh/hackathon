import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../data/models/slot.dart';
import '../../data/models/venue.dart';
import '../../data/repositories/venue_repository.dart';
import 'venue_provider.dart';

class SlotProvider extends ChangeNotifier {
  final VenueRepository _repo;
  SlotProvider(this._repo);

  ViewState state = ViewState.idle;
  List<Slot> slots = [];
  Venue? venue;
  String? errorMessage;
  DateTime selectedDate = DateTime.now();
  Timer? _pollingTimer;

  String get formattedDate => DateFormat('yyyy-MM-dd').format(selectedDate);

  Future<void> loadSlots(int venueId) async {
    state = ViewState.loading;
    notifyListeners();
    await _fetchSlots(venueId);
    _startPolling(venueId);
  }

  Future<void> changeDate(DateTime date, int venueId) async {
    selectedDate = date;
    state = ViewState.loading;
    notifyListeners();
    await _fetchSlots(venueId);
  }

  Future<void> refresh(int venueId) => _fetchSlots(venueId);

  Future<void> _fetchSlots(int venueId) async {
    final result = await _repo.getSlotsForDate(venueId, formattedDate);
    result.when(
      success: (data) {
        venue = data.$1;
        slots = data.$2;
        state = ViewState.data;
      },
      failure: (msg) {
        errorMessage = msg;
        state = ViewState.error;
      },
    );
    notifyListeners();
  }

  void _startPolling(int venueId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchSlots(venueId);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
