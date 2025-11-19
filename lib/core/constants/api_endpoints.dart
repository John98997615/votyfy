// core/constants/api_endpoints.dart
class ApiEndpoints {
  // Endpoints de base
  static const String concours = '/concours';
  static const String candidates = '/candidates';
  static const String votes = '/v1/votes';
  
  // Endpoints d'authentification (si nécessaire plus tard)
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String profile = '/profile';
  
  // Endpoints d'administration (pour éventuelle extension)
  static const String adminConcours = '/v1/admin/concours';
  static const String adminTransactions = '/v1/admin/transactions/summary';
  static const String adminDashboard = '/v1/admin/dashboard/stats';
}