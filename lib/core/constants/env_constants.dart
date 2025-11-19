// core/constants/env_constants.dart
class EnvConstants {
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  
  // Configuration API
  static const String apiBaseUrl = 'http://192.168.0.42:8000/api';
  static const int apiTimeout = 30;
  
  // Configuration FedaPay (à remplir avec vos clés)
  static const String fedapayPublicKey = 'pk_sandbox_...';
  static const String fedapaySecretKey = 'sk_sandbox_...';
  static const String fedapayEnvironment = 'sandbox'; // ou 'live'
  
  // URLs de callback
  static const String paymentCallbackUrl = '$apiBaseUrl/v1/fedapay/webhook';
  static const String paymentSuccessUrl = 'votyfy://payment/success';
  static const String paymentErrorUrl = 'votyfy://payment/error';
}