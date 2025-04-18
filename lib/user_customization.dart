// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// /*import 'package:path_provider/path_provider.dart';*/
// import 'package:permission_handler/permission_handler.dart';

// class UserCustomizationScreen extends StatefulWidget {
//   final String extractedText;

//   const UserCustomizationScreen({super.key, required this.extractedText});

//   @override
//   State<UserCustomizationScreen> createState() =>
//       _UserCustomizationScreenState();
// }

// class _UserCustomizationScreenState extends State<UserCustomizationScreen> {
//   String? selectedNarrationStyle;
//   String? selectedLanguage;

//   Future<void> downloadExtractedText() async {
//     try {
//       // Request storage permission
//       var status = await Permission.storage.request();

//       if (status.isGranted) {
//         final downloadsDirectory = Directory('/storage/emulated/0/Download');

//         if (!downloadsDirectory.existsSync()) {
//           downloadsDirectory.createSync(recursive: true);
//         }

//         final filePath = '${downloadsDirectory.path}/extracted_text.txt';
//         final file = File(filePath);

//         await file.writeAsString(widget.extractedText);

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('File saved to Downloads folder at:\n$filePath'),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Storage permission denied')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to save file: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.lightBlue[100],
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications, color: Colors.black87),
//             onPressed: () {},
//           ),
//         ],
//         title: Center(
//           child: Image.asset(
//             'assets/images/audify_logo.png',
//             height: 40,
//             errorBuilder:
//                 (context, error, stackTrace) =>
//                     const Icon(Icons.error, color: Colors.red),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 16),
//             const Icon(Icons.check_circle, color: Colors.green, size: 48),
//             const SizedBox(height: 8),
//             const Text(
//               'Text from slides extracted successfully',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             Stack(
//               alignment: Alignment.topRight,
//               children: [
//                 Container(
//                   width: double.infinity,
//                   height: 150,
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: SingleChildScrollView(
//                     child: Text(
//                       widget.extractedText.isNotEmpty
//                           ? widget.extractedText
//                           : "No extracted text available",
//                       style: const TextStyle(fontSize: 16),
//                       textAlign: TextAlign.left,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.copy, size: 20),
//                   onPressed: () {
//                     Clipboard.setData(
//                       ClipboardData(text: widget.extractedText),
//                     );
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Text copied to clipboard')),
//                     );
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.teal[700],
//               ),
//               icon: const Icon(Icons.download),
//               label: const Text('Download Extracted Text'),
//               onPressed: downloadExtractedText,
//             ),
//             const SizedBox(height: 24),
//             Row(
//               children: const [
//                 Icon(Icons.mic, color: Colors.blue),
//                 SizedBox(width: 8),
//                 Text(
//                   'Audio Customization:',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.blue[700],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               dropdownColor: Colors.blue[700],
//               value: selectedNarrationStyle,
//               hint: const Text(
//                 'Select Narration Style',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               items: const [
//                 DropdownMenuItem(
//                   value: 'formal',
//                   child: Text(
//                     'Formal Lecture',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 DropdownMenuItem(
//                   value: 'ted',
//                   child: Text(
//                     'TED Talk Style',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 DropdownMenuItem(
//                   value: 'casual',
//                   child: Text('Casual', style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   selectedNarrationStyle = value;
//                 });
//               },
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.blue[300],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               dropdownColor: Colors.blue[300],
//               value: selectedLanguage,
//               hint: const Text(
//                 'Select Language for Audio',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               items: const [
//                 DropdownMenuItem(
//                   value: 'en',
//                   child: Text('English', style: TextStyle(color: Colors.white)),
//                 ),
//                 DropdownMenuItem(
//                   value: 'zh',
//                   child: Text('Chinese', style: TextStyle(color: Colors.white)),
//                 ),
//                 DropdownMenuItem(
//                   value: 'ms',
//                   child: Text('Malay', style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   selectedLanguage = value;
//                 });
//               },
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue[900],
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 16,
//                   horizontal: 32,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: () {
//                 if (selectedNarrationStyle == null ||
//                     selectedLanguage == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text(
//                         'Please select all customization options before proceeding',
//                       ),
//                     ),
//                   );
//                   return;
//                 }

//                 debugPrint("Extracted Text: ${widget.extractedText}");
//                 debugPrint("Narration Style: $selectedNarrationStyle");
//                 debugPrint("Language: $selectedLanguage");

//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Audio conversion started!')),
//                 );
//               },
//               child: const Text(
//                 'Convert to Audio',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


//latest 18/4/2025 with send post request to backend (customization settings selected by user)

// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class UserCustomizationScreen extends StatefulWidget {
  final String extractedText;

  const UserCustomizationScreen({super.key, required this.extractedText});

  @override
  State<UserCustomizationScreen> createState() =>
      _UserCustomizationScreenState();
}

class _UserCustomizationScreenState extends State<UserCustomizationScreen> {
  String? selectedNarrationStyle;
  String? selectedLanguage;
  bool isLoading = false;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save file: $e')),
      );
    }
  }

  Future<void> sendToBackend() async {
    setState(() {
      isLoading = true;
    });

    final uri = Uri.parse('http://your_backend_ip:5000/narrate'); // Change this to your backend URL
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "text": widget.extractedText,
        "narration_style": selectedNarrationStyle,
        "language": selectedLanguage,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio conversion completed!')),
      );
      // TODO: handle the audio download if backend returns audio URL or binary
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to convert text to audio')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black87),
            onPressed: () {},
          ),
        ],
        title: Center(
          child: Image.asset(
            'assets/images/audify_logo.png',
            height: 40,
            errorBuilder:
                (context, error, stackTrace) =>
                    const Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                            const SnackBar(
                                content: Text('Text copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text('Download Extracted Text'),
                    onPressed: downloadExtractedText,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: const [
                      Icon(Icons.mic, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Audio Customization:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                        child:
                            Text('Casual', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedNarrationStyle = value;
                      });
                    },
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
                        child:
                            Text('English', style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: 'zh',
                        child:
                            Text('Chinese', style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: 'ms',
                        child:
                            Text('Malay', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value;
                      });
                    },
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
                      if (selectedNarrationStyle == null ||
                          selectedLanguage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select all customization options before proceeding',
                            ),
                          ),
                        );
                        return;
                      }

                      sendToBackend(); // Send to Flask
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
    );
  }
}
