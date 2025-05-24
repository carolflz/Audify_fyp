//new, 12.5.2025
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class AudioScreen extends StatefulWidget {
//   final List<String> slideTexts;
//   final String style;
//   final String language;
//   final String fileName;

//   const AudioScreen({
//     super.key,
//     required this.slideTexts,
//     required this.style,
//     required this.language,
//     required this.fileName,
//   });

//   @override
//   State<AudioScreen> createState() => _AudioScreenState();
// }

// class _AudioScreenState extends State<AudioScreen> {
//   List<Map<String, String>> _slideResults = [];
//   String? _audioUrl;
//   final List<AudioPlayer> _audioPlayers = [];
//   final List<bool> _isPlaying = [];
//   final List<bool> _isSlideLoading = [];
//   final List<bool> _hasSlideError = [];
//   bool _isLoading = true;
//   int _currentIndex = 0;
//   bool _isGeneratingFullAudio = true;
//   StreamSubscription<String>? _subscription;

//   @override
//   void initState() {
//     super.initState();
//     _startProcessing();
//   }

//   @override
//   void dispose() {
//     _subscription?.cancel();
//     for (var player in _audioPlayers) {
//       player.dispose();
//     }
//     super.dispose();
//   }

//   void _startProcessing() async {
//     final uri = Uri.parse("http://10.0.2.2:5000/narrate_stream");

//     final client = http.Client();
//     final request = http.Request("POST", uri)
//       ..headers['Content-Type'] = 'application/json'
//       ..body = jsonEncode({
//         "slide_texts": widget.slideTexts,
//         "style": widget.style,
//         "language": widget.language,
//         "file_name": widget.fileName,
//       });

//     try {
//       final response = await client.send(request);

//       if (response.statusCode != 200) {
//         throw Exception("Failed to load stream, status code: ${response.statusCode}");
//       }

//       _subscription = response.stream
//           .transform(utf8.decoder)
//           .transform(const LineSplitter())
//           .listen((line) {
//         if (line.startsWith('data: ')) {
//           final dataString = line.substring(6).trim();
//           if (dataString == '[DONE]') {
//             setState(() {
//               _isLoading = false;
//               _isGeneratingFullAudio = false;
//             });
//             return;
//           }

//           try {
//             final decoded = jsonDecode(dataString);
//             if (decoded.containsKey("audio_url")) {
//               setState(() {
//                 _audioUrl = decoded["audio_url"];
//               });
//             } else {
//               setState(() {
//                 _slideResults.add({
//                   "original_text": decoded["original_text"] ?? "",
//                   "narrated_text": decoded["narrated_text"] ?? "",
//                   "translated_text": decoded["translated_text"] ?? "",
//                 });
//                 _audioPlayers.add(AudioPlayer());
//                 _isPlaying.add(false);
//                 _isSlideLoading.add(false);
//                 _hasSlideError.add(false);
//               });
//             }
//           } catch (e) {
//             print("Error decoding data: $e");
//           }
//         }
//       }, onError: (error) {
//         print("Stream error: $error");
//         setState(() {
//           _isLoading = false;
//           _isGeneratingFullAudio = false;
//         });
//       }, onDone: () {
//         print("Stream finished");
//       });
//     } catch (e) {
//       print("Error starting stream: $e");
//       setState(() {
//         _isLoading = false;
//         _isGeneratingFullAudio = false;
//       });
//     }
//   }

//   void _togglePlayback(int index) async {
//     if (_isPlaying[index]) {
//       await _audioPlayers[index].pause();
//     } else {
//       await _audioPlayers[index].play(UrlSource(_audioUrl!));
//     }

//     setState(() {
//       _isPlaying[index] = !_isPlaying[index];
//     });

//     _audioPlayers[index].onPlayerComplete.listen((event) {
//       setState(() {
//         _isPlaying[index] = false;
//       });
//     });
//   }

//   Future<void> _downloadAudioFile() async {
//     var status = await Permission.storage.request();
//     if (!status.isGranted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Storage permission is required to download")),
//       );
//       return;
//     }

//     final dir = await getExternalStorageDirectory();
//     final taskId = await FlutterDownloader.enqueue(
//       url: _audioUrl!,
//       savedDir: dir!.path,
//       fileName: '${widget.fileName}_audio.mp3',
//       showNotification: true,
//       openFileFromNotification: true,
//     );

//     if (taskId != null && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Download started...")),
//       );
//     }
//   }

//   Widget _buildSlideCard(int index) {
//     final slide = _slideResults[index];
//     return Column(
//       children: [
//         Card(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           elevation: 4,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Slide ${index + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
//                 const SizedBox(height: 8),
//                 const Text('Original:', style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text(slide["original_text"] ?? ''),
//                 const SizedBox(height: 8),
//                 const Text('Narrated:', style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text(slide["narrated_text"] ?? ''),
//                 const SizedBox(height: 8),
//                 const Text('Translated:', style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text(slide["translated_text"] ?? ''),
//               ],
//             ),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.arrow_back_ios),
//               onPressed: _currentIndex > 0
//                   ? () => setState(() => _currentIndex--)
//                   : null,
//             ),
//             IconButton(
//               icon: const Icon(Icons.arrow_forward_ios),
//               onPressed: _currentIndex < _slideResults.length - 1
//                   ? () => setState(() => _currentIndex++)
//                   : null,
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildControlButtons() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Column(
//         children: [
//           if (_isGeneratingFullAudio)
//             const LinearProgressIndicator(minHeight: 6),
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton.icon(
//                 onPressed: _audioUrl != null
//                     ? () => _togglePlayback(_currentIndex)
//                     : null,
//                 icon: Icon(_isPlaying[_currentIndex]
//                     ? Icons.pause_circle
//                     : Icons.play_circle),
//                 label: const Text("Play Slide"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.purple,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: _audioUrl != null
//                     ? () => AudioPlayer().play(UrlSource(_audioUrl!))
//                     : null,
//                 icon: const Icon(Icons.queue_music),
//                 label: const Text("Play Full"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//               IconButton(
//                 onPressed: _audioUrl != null ? _downloadAudioFile : null,
//                 icon: const Icon(Icons.download),
//                 color: Colors.green,
//                 tooltip: "Download Full Audio",
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFDDF1FF),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.purple),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Image.asset('assets/images/audify_logo.png', height: 40),
//         centerTitle: true,
//         actions: [
//           if (_audioUrl != null)
//             IconButton(
//               icon: const Icon(Icons.download, color: Colors.green),
//               onPressed: _downloadAudioFile,
//             ),
//         ],
//       ),
//       body: _isLoading && _slideResults.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Expanded(
//                   child: _slideResults.isEmpty
//                       ? const Center(child: Text("No slides available."))
//                       : SingleChildScrollView(
//                           child: _buildSlideCard(_currentIndex),
//                         ),
//                 ),
//                 _buildControlButtons(),
//               ],
//             ),
//     );
//   }
// }

// ignore_for_file: prefer_final_fields, avoid_print, use_build_context_synchronously, sized_box_for_whitespace

//new: 16/5/25
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

// Import your upload screen
import 'upload_slide.dart';

class AudioScreen extends StatefulWidget {
  final List<String> slideTexts;
  final String style;
  final String language;
  final String fileName;

  const AudioScreen({
    super.key,
    required this.slideTexts,
    required this.style,
    required this.language,
    required this.fileName,
  });

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  List<Map<String, String>> _slideResults = [];
  String? _audioUrl;
  String? _localAudioPath;
  bool _isLoading = true;
  bool _isGeneratingFullAudio = true;
  int _currentIndex = 0;
  StreamSubscription<String>? _subscription;

  final AudioPlayer _fullAudioPlayer = AudioPlayer();
  bool _isFullAudioPlaying = false;

  AndroidDeviceInfo? androidInfo;
  bool _notifiedAudioReady = false; // <-- track if we've shown the SnackBar

  @override
  void initState() {
    super.initState();
    _initAndroidVersion();
    _startProcessing();
  }

  void _initAndroidVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.androidInfo;
    setState(() {
      androidInfo = info;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _fullAudioPlayer.dispose();
    super.dispose();
  }

  void _startProcessing() async {
    final uri = Uri.parse("http://10.0.2.2:5000/narrate_stream");

    final client = http.Client();
    final request =
        http.Request("POST", uri)
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode({
            "slide_texts": widget.slideTexts,
            "style": widget.style,
            "language": widget.language,
            "file_name": widget.fileName,
          });

    try {
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception("Failed to load stream");
      }

      _subscription = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.startsWith('data: ')) {
                final dataString = line.substring(6).trim();
                if (dataString == '[DONE]') {
                  setState(() {
                    _isLoading = false;
                    _isGeneratingFullAudio = false;
                  });
                  return;
                }

                try {
                  final decoded = jsonDecode(dataString);
                  if (decoded.containsKey("audio_url")) {
                    setState(() {
                      _audioUrl = decoded["audio_url"];
                    });
                    // Show SnackBar once when full audio is ready
                    if (!_notifiedAudioReady) {
                      _notifiedAudioReady = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Full audio has been generated successfully!",
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  } else {
                    setState(() {
                      _slideResults.add({
                        "original_text": decoded["original_text"] ?? "",
                        "narrated_text": decoded["narrated_text"] ?? "",
                        "translated_text": decoded["translated_text"] ?? "",
                      });
                    });
                  }
                } catch (e) {
                  print("Error decoding line: $e");
                }
              }
            },
            onError: (e) {
              print("Stream error: $e");
              setState(() {
                _isLoading = false;
                _isGeneratingFullAudio = false;
              });
            },
          );
    } catch (e) {
      print("Error starting stream: $e");
      setState(() {
        _isLoading = false;
        _isGeneratingFullAudio = false;
      });
    }
  }

  void _toggleFullAudio() async {
    if (_isFullAudioPlaying) {
      await _fullAudioPlayer.pause();
    } else {
      if (_localAudioPath != null && File(_localAudioPath!).existsSync()) {
        await _fullAudioPlayer.play(DeviceFileSource(_localAudioPath!));
      } else if (_audioUrl != null) {
        await _fullAudioPlayer.play(UrlSource(_audioUrl!));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Audio not ready")));
        return;
      }
    }

    setState(() {
      _isFullAudioPlaying = !_isFullAudioPlaying;
    });

    _fullAudioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isFullAudioPlaying = false;
      });
    });
  }

  Future<void> _downloadAudioFile() async {
    if (_audioUrl == null) return;

    if (Platform.isAndroid) {
      if (await Permission.storage.request().isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission required")),
        );
        return;
      }

      if ((androidInfo?.version.sdkInt ?? 0) >= 30) {
        var manageStorageStatus =
            await Permission.manageExternalStorage.request();
        if (!manageStorageStatus.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Manage External Storage permission required"),
            ),
          );
          return;
        }
      }
    }

    final dirPath = '/storage/emulated/0/Download';
    final fileName = '${widget.fileName}_audio.mp3';
    final savedPath = '$dirPath/$fileName';

    try {
      final taskId = await FlutterDownloader.enqueue(
        url: _audioUrl!,
        savedDir: dirPath,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );

      setState(() {
        _localAudioPath = savedPath;
      });

      if (taskId != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Download started: $fileName")));
      }
    } catch (e) {
      print("Download error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Download failed")));
    }
  }

  Widget _buildTopControls() {
    String statusText = "";
    if (_isGeneratingFullAudio) {
      statusText =
          "Audio is generating (Slide ${_slideResults.length} / ${widget.slideTexts.length})";
    } else if (_audioUrl != null) {
      statusText = "Full audio is generated successfully";
    }

    return Column(
      children: [
        if (statusText.isNotEmpty)
          Text(
            statusText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
            ),
          ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed:
                  _audioUrl != null || _localAudioPath != null
                      ? _toggleFullAudio
                      : null,
              icon: Icon(_isFullAudioPlaying ? Icons.pause : Icons.play_arrow),
              label: const Text("Play Full"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _audioUrl != null ? _downloadAudioFile : null,
              color: Colors.green,
              tooltip: "Download Full Audio",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlideCard(int index) {
    final slide = _slideResults[index];
    final original = slide["original_text"] ?? '';
    final narrated = slide["narrated_text"] ?? '';
    final translated = slide["translated_text"] ?? '';

    // Helper widget to build section title with copy icon
    Widget sectionTitle(String title, String textToCopy) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
            tooltip: 'Copy $title',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: textToCopy));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title copied to clipboard')),
              );
            },
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.69,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Slide ${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Original with copy icon
                    sectionTitle('Original:', original),
                    Text(original),
                    const SizedBox(height: 8),

                    // Narrated with copy icon
                    sectionTitle('Narrated:', narrated),
                    Text(narrated),
                    const SizedBox(height: 8),

                    // Translated with copy icon
                    sectionTitle('Translated:', translated),
                    Text(translated),
                  ],
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed:
                  _currentIndex > 0
                      ? () => setState(() => _currentIndex--)
                      : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed:
                  _currentIndex < _slideResults.length - 1
                      ? () => setState(() => _currentIndex++)
                      : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTopControls(),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDF1FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.purple),
          tooltip: "Go to Home",
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const UploadSlideScreen(),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Image.asset('assets/images/audify_logo.png', height: 40),
        centerTitle: true,
      ),
      body:
          _isLoading && _slideResults.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child:
                        _slideResults.isEmpty
                            ? const Center(child: Text("No slides available."))
                            : SingleChildScrollView(
                              child: _buildSlideCard(_currentIndex),
                            ),
                  ),
                ],
              ),
    );
  }
}
