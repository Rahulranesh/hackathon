import '../../core/result.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class BookingRepository {
  final ApiService _api;
  BookingRepository(this._api);

  Future<Result<Booking>> bookSlot(int slotId, String date, String userId) async {
    final result = await _api.postBooking(slotId, date, userId);
    return result.when(
      success: (data) => Success(Booking.fromJson(data['booking'])),
      failure: Failure.new,
    );
  }

  Future<Result<List<Booking>>> getUserBookings(String userId) async {
    final result = await _api.getUserBookings(userId);
    return result.when(
      success: (data) => Success(data.map((j) => Booking.fromJson(j)).toList()),
      failure: Failure.new,
    );
  }

  Future<Result<String>> cancelBooking(int bookingId, String userId) =>
      _api.deleteBooking(bookingId, userId);
}
