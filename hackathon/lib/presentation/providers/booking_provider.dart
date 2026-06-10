import 'package:flutter/foundation.dart';
import '../../core/result.dart';
import '../../core/notifications.dart';
import '../../data/models/booking.dart';
import '../../data/repositories/booking_repository.dart';
import 'venue_provider.dart';
import 'package:intl/intl.dart';

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
        
        _sendBookingSuccessNotification(booking);
        
        return true;
      },
      failure: (msg) {
        if (msg == 'SLOT_TAKEN') {
          actionState = BookingAction.slotTaken;
          
          if (lastBooking != null) {
            _sendSlotTakenNotification(lastBooking!);
          }
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
    final booking = bookings.firstWhere((b) => b.id == bookingId);
    
    final result = await _repo.cancelBooking(bookingId, userId);
    result.when(
      success: (_) {
        bookings.removeWhere((b) => b.id == bookingId);
        notifyListeners();
        
        _sendCancellationNotification(booking);
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

  void _sendBookingSuccessNotification(Booking booking) {
    final formattedDate = DateFormat('EEE, MMM d').format(
      DateTime.parse(booking.bookingDate),
    );
    
    NotificationService().showBookingConfirmed(
      venueName: booking.venueName,
      time: '${booking.startTime} - ${booking.endTime}',
      date: formattedDate,
      sport: booking.sport.toUpperCase(),
    );
  }

  void _sendSlotTakenNotification(Booking booking) {
    NotificationService().showSlotTaken(
      venueName: booking.venueName,
      time: '${booking.startTime} - ${booking.endTime}',
    );
  }

  void _sendCancellationNotification(Booking booking) {
    NotificationService().showBookingCancelled(
      venueName: booking.venueName,
      time: '${booking.startTime} - ${booking.endTime}',
    );
  }
}
