import 'package:flutter/foundation.dart';
import '../../core/result.dart';
import '../../data/models/venue.dart';
import '../../data/repositories/venue_repository.dart';

enum ViewState { idle, loading, data, error }

class VenueProvider extends ChangeNotifier {
  final VenueRepository _repo;
  VenueProvider(this._repo);

  ViewState state = ViewState.idle;
  List<Venue> venues = [];
  String? errorMessage;

  Future<void> fetchVenues() async {
    state = ViewState.loading;
    notifyListeners();
    final result = await _repo.getVenues();
    result.when(
      success: (data) {
        venues = data;
        state = ViewState.data;
      },
      failure: (msg) {
        errorMessage = msg;
        state = ViewState.error;
      },
    );
    notifyListeners();
  }
}
