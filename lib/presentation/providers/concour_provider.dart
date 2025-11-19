// presentation/providers/concour_provider.dart
import 'package:flutter/foundation.dart';
import 'package:votyfy/data/models/concour.dart';
import 'package:votyfy/data/services/api_service.dart';

class ConcourProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Concour> _concours = [];
  bool _isLoading = false;
  String _error = '';

  List<Concour> get concours => _concours;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;

  // Récupérer les concours actifs seulement
  List<Concour> get activeConcours => _concours.where((concour) => concour.isActive).toList();

  Future<void> loadConcours() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiService.getConcours();
      _concours = (response as List)
          .map((item) => Concour.fromJson(item))
          .toList();
      _error = '';
    } catch (e) {
      _error = e.toString();
      _concours = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Récupérer un concours spécifique par ID
  Concour? getConcourById(int concourId) {
    try {
      return _concours.firstWhere((concour) => concour.id == concourId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Rafraîchir les données
  Future<void> refreshConcours() async {
    await loadConcours();
  }
}