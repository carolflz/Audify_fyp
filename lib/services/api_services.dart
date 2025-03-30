import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart'; 

class ApiService {
  static Future<String> uploadFile(File file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:5000/extract'), 
    );

    var mimeType = lookupMimeType(file.path);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null, // ✅ Corrected
      ),
    );

    var response = await request.send();
    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    } else {
      throw Exception('Failed to upload file: ${response.statusCode}');
    }
  }
}

