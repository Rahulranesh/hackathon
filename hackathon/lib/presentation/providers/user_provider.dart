import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String _userId = '';
  String _userName = '';

  String get userId => _userId;
  String get userName => _userName;
  bool get isLoggedIn => _userId.isNotEmpty;

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
