import 'package:flutter/foundation.dart';
import '../../core/result.dart';
import '../../data/models/app_user.dart';
import '../../data/services/api_service.dart';
import 'venue_provider.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _api;
  UserProvider(this._api);

  String _userId = '';
  String _userName = '';
  ViewState state = ViewState.idle;
  List<AppUser> users = [];
  String? errorMessage;

  String get userId => _userId;
  String get userName => _userName;
  bool get isLoggedIn => _userId.isNotEmpty;

  Future<void> fetchUsers() async {
    state = ViewState.loading;
    notifyListeners();

    final result = await _api.getUsers();
    result.when(
      success: (data) {
        users = data.map((json) => AppUser.fromJson(json)).toList();
        state = ViewState.data;
        errorMessage = null;
      },
      failure: (message) {
        errorMessage = message;
        state = ViewState.error;
      },
    );

    notifyListeners();
  }

  void login(String id, String name) {
    _userId = id;
    _userName = name;
    notifyListeners();
  }

  void logout() {
    _userId = '';
    _userName = '';
    notifyListeners();
  }
}
