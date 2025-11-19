// data/services/api_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:votyfy/core/constants/app_constants.dart';
import 'package:votyfy/core/constants/env_constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConstants.apiBaseUrl, // Utilisation de EnvConstants
        connectTimeout: const Duration(seconds: EnvConstants.apiTimeout),
        receiveTimeout: const Duration(seconds: EnvConstants.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor pour le logging (seulement en développement)
    if (EnvConstants.fedapayEnvironment == 'sandbox') {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }

    // Interceptor pour la gestion globale des erreurs
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Ajouter un token d'authentification si nécessaire
          // options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Gestion centralisée des erreurs
          if (error.response?.statusCode == 401) {
            // Gérer l'expiration du token
            // await _refreshToken();
            // return handler.resolve(await _retry(error.requestOptions));
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Méthode privée pour gérer les réponses
  dynamic _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else if (response.statusCode == 400) {
      throw Exception('Requête invalide: ${response.data}');
    } else if (response.statusCode == 401) {
      throw Exception('Non authentifié');
    } else if (response.statusCode == 403) {
      throw Exception('Accès non autorisé');
    } else if (response.statusCode == 404) {
      throw Exception('Ressource non trouvée');
    } else if (response.statusCode == 500) {
      throw Exception('Erreur interne du serveur');
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}: ${response.statusMessage}');
    }
  }

  // GET Concours
  Future<List<dynamic>> getConcours() async {
    try {
      final response = await _dio.get(AppConstants.concoursEndpoint);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw Exception('Erreur lors de la récupération des concours: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  // GET Concour by ID
  Future<dynamic> getConcourById(int id) async {
    try {
      final response = await _dio.get('${AppConstants.concoursEndpoint}/$id');
      return _handleResponse(response);
    } on DioException catch (e) {
      throw Exception('Erreur lors de la récupération du concours: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  // GET Candidates
  Future<List<dynamic>> getCandidates() async {
    try {
      final response = await _dio.get(AppConstants.candidatesEndpoint);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw Exception('Erreur lors de la récupération des candidats: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  // GET Candidates by Concour ID
  Future<List<dynamic>> getCandidatesByConcour(int concourId) async {
    try {
      final response = await _dio.get(AppConstants.candidatesEndpoint);
      final allCandidates = _handleResponse(response) as List;
      
      // Filtrer les candidats par concourId
      return allCandidates.where((candidate) {
        return candidate['concour_id'] == concourId;
      }).toList();
    } on DioException catch (e) {
      throw Exception('Erreur lors de la récupération des candidats: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  // POST Vote
  Future<dynamic> submitVote(Map<String, dynamic> voteData) async {
    try {
      final response = await _dio.post(
        AppConstants.votesEndpoint,
        data: jsonEncode(voteData),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      // Gestion détaillée des erreurs Dio
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Timeout de connexion. Vérifiez votre connexion internet.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Timeout de réponse du serveur.');
      } else if (e.type == DioExceptionType.badResponse) {
        if (e.response?.statusCode == 403) {
          throw Exception('Ce concours n\'est pas actuellement ouvert aux votes.');
        } else if (e.response?.statusCode == 400) {
          throw Exception('Données de vote invalides: ${e.response?.data}');
        }
      }
      throw Exception('Erreur lors du vote: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  // Méthode pour vérifier la connexion internet
  Future<bool> checkConnection() async {
    try {
      final response = await _dio.get('${AppConstants.concoursEndpoint}?test=1');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}