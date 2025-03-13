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

    if (!mounted) return; // Ensure widget is still mounted

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      int fileSizeInBytes = await file.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024); // Convert to MB

      if (!mounted) return; // Check again after async call

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
      // User canceled or invalid file
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

    // TODO: Implement upload to Firebase Storage and get URL

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uploading: ${selectedFile!.path.split('/').last}'),
      ),
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
                    // ✅ Enlarged icon when file is uploaded
                    Image.asset(
                      fileName == null
                          ? 'assets/images/upload icon.png'
                          : 'assets/images/file_upload_success.png', // <-- Success icon
                      height: fileName == null ? 50 : 100, // Enlarged to 80 if file uploaded
                      width: fileName == null ? 50 : 100,  // Optional width adjustment
                    ),
                    const SizedBox(height: 10),
                    // ✅ Change message dynamically
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
                            'Slide uploaded successfully:\n$fileName',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploadFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03045E),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Upload File',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
