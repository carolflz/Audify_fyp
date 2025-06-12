// ignore_for_file: prefer_final_fields, use_build_context_synchronously, avoid_print, sized_box_for_whitespace

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
  int _currentGeneratingIndex = 0;
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

                    if (!_notifiedAudioReady) {
                      _notifiedAudioReady = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Full audio has been generated successfully!")),
                      );
                    }
                  } else {
                    //to avoid extra slide
                    if (_slideResults.length >= widget.slideTexts.length) return;

                    setState(() {
                      _slideResults.add({
                        "original_text": decoded["original_text"] ?? "",
                        "narrated_text": decoded["narrated_text"] ?? "",
                        "translated_text": decoded["translated_text"] ?? "",
                      });

                      _currentGeneratingIndex++;
                    });
                    assert(
                      _slideResults.length <= widget.slideTexts.length,
                      'Received more slides than expected!',
                    );
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
      final totalSlides = widget.slideTexts.length;
      final current = (_currentGeneratingIndex < totalSlides)
        ? _currentGeneratingIndex + 1
        : totalSlides;
        
      statusText = "Audio is generating (Slide $current / $totalSlides)";
    }
    else if (_audioUrl != null) {
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
          icon: const Icon(Icons.arrow_back, color: Colors.purple),
          tooltip: "Back to Customization",
          onPressed: () async {
            final shouldGoBack = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text("Go Back?"),
                    content: const Text(
                      "Any unsaved progress will be lost. Do you want to go back?",
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      ElevatedButton(
                        child: const Text("Yes, go back"),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
            );

            if (shouldGoBack == true) {
              Navigator.pop(context); // Go back to user_customization.dart
            }
          },
        ),
        title: Image.asset('assets/images/audify_logo.png', height: 40),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.purple),
            tooltip: "Go to Home",
            onPressed: () async {
              final shouldLeave = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Return to Home?"),
                      content: const Text(
                        "Any unsaved progress will be lost. Do you want to continue?",
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        ElevatedButton(
                          child: const Text("Yes, go home"),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
              );

              if (shouldLeave == true) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadSlideScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
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
