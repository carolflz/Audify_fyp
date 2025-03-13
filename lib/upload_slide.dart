import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  UploadScreenState createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  File? selectedFile;
  String? fileName;

  // Function to pick file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pptx', 'pdf'], // Only allow pptx and pdf
    );

    if (!mounted) return;

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      int fileSizeInBytes = await file.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024); // Convert to MB

      if (!mounted) return;

      if (fileSizeInMB > 5) {
        // File exceeds 5MB
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your slide not more than 5MB'),
          ),
        );
      } else {
        // Valid file
        setState(() {
          selectedFile = file;
          fileName = result.files.single.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selected: ${result.files.single.name}'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your slide (in pptx or pdf format)'),
        ),
      );
    }
  }

  // Function to handle file upload (Placeholder)
  void _uploadFile() {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file first'),
        ),
      );
      return;
    }

    // TODO: Implement actual upload to Firebase Storage and get URL

    // Show success dialog and navigate to customization
    _showUploadSuccessDialog();
  }

  // Function to show dialog and navigate
  void _showUploadSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.pushNamed(context, '/userCustomization'); // Navigate
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03045E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text('Proceed to Customize', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to delete file
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
                  style: TextStyle(fontSize: 14, color: Color(0xFF4A4A4A), fontFamily: 'Roboto'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Upload your files',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Color(0xFF4A4A4A)),
          ),
          const SizedBox(height: 5),
          const Text(
            'File should be PPTX/PDF',
            style: TextStyle(color: Color(0xFF4A4A4A), fontFamily: 'Roboto'),
          ),
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
                            style: TextStyle(color: Color(0xFF4A4A4A), fontFamily: 'Roboto'),
                          )
                        : Text(
                            '$fileName',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                          ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploadFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03045E),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Upload File', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Roboto')),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // ✅ Delete button, 50% width and centered
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80), // Adjust width here
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: fileName != null ? _deleteFile : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400, // Soft red
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Delete File', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
