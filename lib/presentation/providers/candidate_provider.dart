// presentation/providers/candidate_provider.dart
import 'package:flutter/foundation.dart';
import 'package:votyfy/data/models/candidate.dart';
import 'package:votyfy/data/services/api_service.dart';

class CandidateProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Candidate> _candidates = [];
  bool _isLoading = false;
  String _error = '';

  List<Candidate> get candidates => _candidates;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;

  Future<void> loadCandidatesByConcour(int concourId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiService.getCandidatesByConcour(concourId);
      _candidates = (response as List)
          .map((item) => Candidate.fromJson(item))
          .toList();
      _error = '';
    } catch (e) {
      _error = e.toString();
      _candidates = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour récupérer un candidat spécifique
  Candidate? getCandidateById(int candidateId) {
    try {
      return _candidates.firstWhere((candidate) => candidate.id == candidateId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Méthode pour trier les candidats par votes (décroissant)
  void sortCandidatesByVotes() {
    _candidates.sort((a, b) => b.votesCount.compareTo(a.votesCount));
    notifyListeners();
  }
}