import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'user_customization.dart'; // Import the screen

class UploadSlideScreen extends StatefulWidget {
  const UploadSlideScreen({super.key});

  @override
  State<UploadSlideScreen> createState() => _UploadSlideScreenState();
}

class _UploadSlideScreenState extends State<UploadSlideScreen> {
  File? selectedFile;
  String? fileName;
  String? extractedText; // Store extracted text

  /// Picks a file (PDF/PPTX) from the system
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pptx', 'pdf'],
    );

    if (!mounted) return; // Ensure widget is still in the tree

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileSizeInBytes = await file.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a file not more than 5MB')),
        );
      } else {
        setState(() {
          selectedFile = file;
          fileName = result.files.single.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File selected: $fileName')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a slide (PPTX/PDF)')),
      );
    }
  }

  /// Uploads the file and retrieves extracted text
  Future<void> _uploadFile() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first')),
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:5000/extract'),
    );

    final mimeType = lookupMimeType(selectedFile!.path);
    final fileToUpload = await http.MultipartFile.fromPath(
      'file',
      selectedFile!.path,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    );

    request.files.add(fileToUpload);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      setState(() {
        extractedText = jsonResponse['extracted_text']; // Store extracted text
      });

      _showUploadSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${response.statusCode}')),
      );
    }
  }

  /// Shows success dialog and navigates to UserCustomizationScreen
  void _showUploadSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Image.asset('assets/images/file_upload_success.png', height: 80),
              const SizedBox(height: 16),
              const Text(
                'Slide uploaded successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fileName ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserCustomizationScreen(
                        extractedText: extractedText ?? "", // Ensure this is correctly passed
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03045E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                ),
                child: const Text(
                  'Proceed to Customize',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Deletes selected file
  void _deleteFile() {
    setState(() {
      selectedFile = null;
      fileName = null;
      extractedText = null; // Clear extracted text
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE4FAFF),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.blue),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              color: const Color(0xFFE4FAFF),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/audify_logo.png', height: 50),
                  const SizedBox(height: 8),
                  const Text(
                    'Listen. Learn. Succeed.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              'Upload your files',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text('File should be PPTX/PDF'),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                height: 220,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF90E0EF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        fileName == null
                            ? 'assets/images/upload icon.png'
                            : 'assets/images/file_upload_success.png',
                        height: 50,
                      ),
                      const SizedBox(height: 10),
                      fileName == null
                          ? const Text('Max file size 5MB\nTap to select a file')
                          : Text(fileName!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ElevatedButton(onPressed: _uploadFile, child: const Text('Upload File')),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: fileName != null ? _deleteFile : null, child: const Text('Delete File')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
