import 'dart:convert';

class Helper {
  static String getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) throw Exception('Invalid token format');

      final payloadBase64 = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(payloadBase64));
      final Map<String, dynamic> payloadMap = jsonDecode(payloadJson);

      return payloadMap['userId'] ?? '';
    } catch (e) {
      print('Failed to decode token: $e');
      return '';
    }
  }
}
