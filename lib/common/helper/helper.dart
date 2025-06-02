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
  static String getFileType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'wmv':
        return 'video';
      case 'mp3':
      case 'wav':
      case 'ogg':
        return 'audio';
      case 'pdf':
        return 'document';
      case 'doc':
      case 'docx':
        return 'word';
      case 'xls':
      case 'xlsx':
        return 'excel';
      case 'ppt':
      case 'pptx':
        return 'powerpoint';
      default:
        return 'file';
    }
  }

  static String getFileName(String? originalName, String url) {
    if (originalName != null && originalName.isNotEmpty) {
      return originalName;
    }
    
    // Extract filename from URL
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      final lastSegment = pathSegments.last;
      // Remove any query parameters or hash
      final fileName = lastSegment.split('?')[0].split('#')[0];
      if (fileName.isNotEmpty) {
        return fileName;
      }
    }
    
    // Generate a default name with timestamp if no name can be extracted
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'file_$timestamp';
  }

}
