// core/constants/app_constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'VOTYFY';
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // Colors
  static const Color primaryColor = Color(0xFF2d6fcf);
  static const Color secondaryColor = Color(0xFF00ACC1);
  static const Color textLight = Color(0xFF666666); // Texte secondaire
  static const Color accentColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF333333);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);

  static const String fontFamily = 'Roboto'; // Utilisez une police système
  
  // API Endpoints
  static const String concoursEndpoint = '/concours';
  static const String candidatesEndpoint = '/candidates';
  static const String votesEndpoint = '/v1/votes';
}