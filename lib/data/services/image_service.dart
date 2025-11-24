// data/services/image_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ImageService {
  static final Map<String, Uint8List> _imageCache = {};

  static Future<Uint8List?> loadImage(String url) async {
    if (_imageCache.containsKey(url)) {
      return _imageCache[url];
    }

    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Flutter-App',
          'Accept': 'image/*',
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        _imageCache[url] = bytes;
        return bytes;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur image: $e');
      }
    }

    return null;
  }

  static void clearCache() {
    _imageCache.clear();
  }
}