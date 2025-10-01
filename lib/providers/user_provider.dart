import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await ApiService.fetchUsers();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void searchUser(String query) {
    if (query.isEmpty) {
      fetchUsers();
    } else {
      _users = _users.where((user) =>
          user.name.toLowerCase().contains(query.toLowerCase())).toList();
      notifyListeners();
    }
  }
}
