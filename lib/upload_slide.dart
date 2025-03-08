import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  UploadScreenState createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  // Function to handle file upload
  void _uploadFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a file first')),
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

          Container(
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
                  Image.asset('assets/images/upload_icon.png', height: 50),
                  const SizedBox(height: 10),
                  const Text(
                    'Max file size 15MB\nDrag or drop your file or tap to select',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
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
