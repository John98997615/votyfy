// presentation/providers/vote_provider.dart
import 'package:flutter/foundation.dart';
import 'package:votyfy/data/services/api_service.dart';

class VoteProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isSubmitting = false;
  String _error = '';

  bool get isSubmitting => _isSubmitting;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;

  Future<Map<String, dynamic>> submitVote(Map<String, dynamic> voteData) async {
    _isSubmitting = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiService.submitVote(voteData);
      _error = '';
      return response;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}