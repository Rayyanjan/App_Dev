import 'package:flutter/foundation.dart'; 
import 'dart:async'; 
import '../models/user_model.dart';
import '../services/api_service.dart';

enum ViewState { loading, success, error }

class UserViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  
  ViewState _state = ViewState.loading;
  List<UserModel> _allUsers = [];       
  String _errorMessage = '';
  String _searchQuery = '';
  final Set<int> _favoriteIds = {};    
  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<UserModel> get filteredUsers {
    if (_searchQuery.isEmpty) return _allUsers;
    return _allUsers
        .where((user) =>
            user.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<UserModel> get favoriteUsers {
    return filteredUsers
        .where((user) => _favoriteIds.contains(user.id))
        .toList();
  }

  bool isFavorite(int userId) => _favoriteIds.contains(userId);

  Future<void> fetchUsers() async {
    _state = ViewState.loading;
    notifyListeners(); 
    try {
      final users = await _apiService.fetchUsers();
      _allUsers = users;
      _state = ViewState.success;
    } on NoInternetException catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
    } on DataParsingException catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
    } on TimeoutException {
      _errorMessage = 'Request timed out. Please try again.';
      _state = ViewState.error;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _state = ViewState.error;
    }

    notifyListeners();
  }

  
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners(); 
  }
  void toggleFavorite(int userId) {
    if (_favoriteIds.contains(userId)) {
      _favoriteIds.remove(userId);
    } else {
      _favoriteIds.add(userId);
    }
    notifyListeners();
  }
}