import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class UploadSlideScreen extends StatefulWidget {
  const UploadSlideScreen({super.key});

  @override
  State<UploadSlideScreen> createState() => _UploadSlideScreenState();
}

class _UploadSlideScreenState extends State<UploadSlideScreen> {
  File? selectedFile;
  String? fileName;

  /// Picks a file (PDF/PPTX) from the system
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pptx', 'pdf'], // Only allow PPTX & PDF
    );

    // Ensure the widget is still in the tree
    if (!mounted) return;

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileSizeInBytes = await file.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      // Check if file exceeds 5MB
      if (fileSizeInMB > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your slide not more than 5MB'),
          ),
        );
      } else {
        setState(() {
          selectedFile = file;
          fileName = result.files.single.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selected: $fileName'),
          ),
        );
      }
    } else {
      // No file selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your slide (in PPTX or PDF format)'),
        ),
      );
    }
  }

  /// Uploads the selected file to the Flask API
  Future<void> _uploadFile() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file first'),
        ),
      );
      return;
    }

    // Create the multipart request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:5000/extract'),
    );

    // Detect MIME type
    final mimeType = lookupMimeType(selectedFile!.path);
    final fileToUpload = await http.MultipartFile.fromPath(
      'file',
      selectedFile!.path,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    );

    request.files.add(fileToUpload);

    // Send request
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      print('Response: $responseBody');
      _showUploadSuccessDialog();
    } else {
      print('Error: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${response.statusCode}')),
      );
    }
  }

  /// Shows a dialog when the file is uploaded successfully
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
                  Navigator.of(dialogContext).pop(); // Close dialog
                  Navigator.pushNamed(context, '/userCustomization'); // Navigate
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

  /// Deletes the selected file
  void _deleteFile() {
    setState(() {
      selectedFile = null;
      fileName = null;
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Banner
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A4A4A),
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Title
          const Text(
            'Upload your files',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'File should be PPTX/PDF',
            style: TextStyle(
              color: Color(0xFF4A4A4A),
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 20),

          // File Upload Container
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              height: 220,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF90E0EF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue, style: BorderStyle.solid),
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
                        ? const Text(
                            'Max file size 5MB\nDrag or drop your file or tap to select',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF4A4A4A),
                              fontFamily: 'Roboto',
                            ),
                          )
                        : Text(
                            fileName!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Upload Button
          ElevatedButton(
            onPressed: _uploadFile,
            child: const Text('Upload File'),
          ),

          // Delete Button
          ElevatedButton(
            onPressed: fileName != null ? _deleteFile : null,
            child: const Text('Delete File'),
          ),
        ],
      ),
    );
  }
}
