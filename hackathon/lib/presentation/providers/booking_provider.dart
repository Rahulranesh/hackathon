import 'package:flutter/foundation.dart';
import '../../core/result.dart';
import '../../data/models/booking.dart';
import '../../data/repositories/booking_repository.dart';
import 'venue_provider.dart';

enum BookingAction { idle, loading, success, slotTaken, error }

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repo;
  BookingProvider(this._repo);

  ViewState listState = ViewState.idle;
  BookingAction actionState = BookingAction.idle;
  List<Booking> bookings = [];
  Booking? lastBooking;
  String? errorMessage;

  Future<void> fetchBookings(String userId) async {
    listState = ViewState.loading;
    notifyListeners();
    final result = await _repo.getUserBookings(userId);
    result.when(
      success: (data) {
        bookings = data;
        listState = ViewState.data;
      },
      failure: (msg) {
        errorMessage = msg;
        listState = ViewState.error;
      },
    );
    notifyListeners();
  }

  Future<bool> bookSlot(int slotId, String date, String userId) async {
    actionState = BookingAction.loading;
    notifyListeners();
    final result = await _repo.bookSlot(slotId, date, userId);
    return result.when(
      success: (booking) {
        lastBooking = booking;
        actionState = BookingAction.success;
        notifyListeners();
        return true;
      },
      failure: (msg) {
        if (msg == 'SLOT_TAKEN') {
          actionState = BookingAction.slotTaken;
        } else {
          errorMessage = msg;
          actionState = BookingAction.error;
        }
        notifyListeners();
        return false;
      },
    );
  }

  Future<void> cancelBooking(int bookingId, String userId) async {
    final result = await _repo.cancelBooking(bookingId, userId);
    result.when(
      success: (_) {
        bookings.removeWhere((b) => b.id == bookingId);
        notifyListeners();
      },
      failure: (msg) {
        errorMessage = msg;
        notifyListeners();
      },
    );
  }

  void resetAction() {
    actionState = BookingAction.idle;
    errorMessage = null;
    notifyListeners();
  }
}
