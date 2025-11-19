// core/constants/app_constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'VOTYFY';
  static const String baseUrl = 'http://192.168.0.42:8000/api';
  
  // Colors
  static const Color primaryColor = Color(0xFF6A1B9A);
  static const Color secondaryColor = Color(0xFF00ACC1);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF333333);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  
  // API Endpoints
  static const String concoursEndpoint = '/concours';
  static const String candidatesEndpoint = '/candidates';
  static const String votesEndpoint = '/v1/votes';
}