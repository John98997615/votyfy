// core/constants/env_constants.dart
class EnvConstants {
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  
  // Configuration API
  static const String apiBaseUrl = 'http://127.0.0.1:8000/api';
  static const int apiTimeout = 30;
  
  // Configuration FedaPay (à remplir avec vos clés)
  static const String fedapayPublicKey = 'pk_sandbox_4ohjqxGvYUBB-v9tOl57VRjm';
  static const String fedapaySecretKey = 'sk_sandbox_DbOEa80nH3khTMjvUNLuG37l';
  static const String fedapayEnvironment = 'wh_sandbox_zK7miKFjE_kB9rrLG3-mSX5q'; // ou 'live'
  
  // URLs de callback
  static const String paymentCallbackUrl = '$apiBaseUrl/v1/fedapay/webhook';
  static const String paymentSuccessUrl = 'votyfy://payment/success';
  static const String paymentErrorUrl = 'votyfy://payment/error';
}