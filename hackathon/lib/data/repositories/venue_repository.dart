import '../../core/result.dart';
import '../models/venue.dart';
import '../models/slot.dart';
import '../services/api_service.dart';

class VenueRepository {
  final ApiService _api;
  VenueRepository(this._api);

  Future<Result<List<Venue>>> getVenues() async {
    final result = await _api.getVenues();
    return result.when(
      success: (data) => Success(data.map((j) => Venue.fromJson(j)).toList()),
      failure: Failure.new,
    );
  }

  Future<Result<(Venue, List<Slot>)>> getSlotsForDate(int venueId, String date) async {
    final result = await _api.getSlots(venueId, date);
    return result.when(
      success: (data) {
        final venue = Venue.fromJson(data['venue']);
        final slots = (data['slots'] as List)
            .map((j) => Slot.fromJson(j))
            .toList();
        return Success((venue, slots));
      },
      failure: Failure.new,
    );
  }
}
