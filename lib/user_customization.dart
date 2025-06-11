import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'audio.dart';

class UserCustomizationScreen extends StatefulWidget {
  final String extractedText;
  final String fileName;

  const UserCustomizationScreen({
    super.key,
    required this.extractedText,
    required this.fileName,
  });

  @override
  State<UserCustomizationScreen> createState() => _UserCustomizationScreenState();
}

class _UserCustomizationScreenState extends State<UserCustomizationScreen> {
  String? selectedNarrationStyle;
  String? selectedLanguage;

  late List<String> slideTexts;

  @override
  void initState() {
    super.initState();
    // Split extractedText into slides assuming '\n---\n' as separator (you can adjust as needed)
    slideTexts = widget.extractedText.split(RegExp(r'\n\s*\n+'));
  }

  Future<void> downloadExtractedText() async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory.createSync(recursive: true);
        }

        final filePath = '${downloadsDirectory.path}/extracted_text.txt';
        final file = File(filePath);
        await file.writeAsString(widget.extractedText);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved to Downloads folder at:\n$filePath'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save file: $e')));
    }
  }

  // Only navigate and pass data — no backend call here
  void sendToBackendAndNavigate() {
    if (selectedNarrationStyle == null || selectedLanguage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioScreen(
          slideTexts: slideTexts,
          style: selectedNarrationStyle!,
          language: selectedLanguage!,
          fileName: widget.fileName,
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Exit'),
          content: const Text('Do you want to go back? Unsaved progress may be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Stay on page
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Leave page
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      return shouldPop ?? false; // If dialog dismissed without choosing, stay
    },
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Exit'),
                content: const Text('Do you want to go back? Unsaved progress may be lost.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Yes'),
                  ),
                ],
              ),
            );
            if (shouldPop ?? false) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Center(
          child: Image.asset(
            'assets/images/audify_logo.png',
            height: 40,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 8),
            const Text(
              'Text from slides extracted successfully',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.extractedText.isNotEmpty
                          ? widget.extractedText
                          : "No extracted text available",
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.extractedText),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Text copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 34, 229, 255),
              ),
              icon: const Icon(Icons.download),
              label: const Text('Download Extracted Text'),
              onPressed: downloadExtractedText,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Image.asset(
                  'assets/images/audio_icon.png',
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, color: Colors.red),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Audio Customization:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue[700],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownColor: Colors.blue[700],
              value: selectedNarrationStyle,
              hint: const Text(
                'Select Narration Style',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'formal',
                  child: Text(
                    'Formal Lecture',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: 'ted',
                  child: Text(
                    'TED Talk Style',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: 'casual',
                  child: Text('Casual', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (value) => setState(() => selectedNarrationStyle = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownColor: Colors.blue[300],
              value: selectedLanguage,
              hint: const Text(
                'Select Language for Audio',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 'zh',
                  child: Text('Chinese', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 'ja',
                  child: Text('Japanese', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (value) => setState(() => selectedLanguage = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (selectedNarrationStyle == null || selectedLanguage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please select all customization options before proceeding',
                      ),
                    ),
                  );
                  return;
                }
                sendToBackendAndNavigate();
              },
              child: const Text(
                'Convert to Audio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ));
    
  }
}
