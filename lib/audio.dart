// // old 
// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class AudioConversionSuccessScreen extends StatefulWidget {
//   const AudioConversionSuccessScreen({super.key});

//   @override
//   AudioConversionSuccessScreenState createState() =>
//       AudioConversionSuccessScreenState();
// }

// class AudioConversionSuccessScreenState
//     extends State<AudioConversionSuccessScreen> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool isPlaying = false;
//   Duration duration = Duration.zero;
//   Duration position = Duration.zero;

//   @override
//   void initState() {
//     super.initState();

//     _audioPlayer.onDurationChanged.listen((newDuration) {
//       setState(() {
//         duration = newDuration;
//       });
//     });

//     _audioPlayer.onPositionChanged.listen((newPosition) {
//       setState(() {
//         position = newPosition;
//       });
//     });

//     _audioPlayer.onPlayerComplete.listen((event) {
//       setState(() {
//         isPlaying = false;
//         position = Duration.zero;
//       });
//     });
//   }

//   // Play or pause the audio
//   void _togglePlayback() async {
//     if (isPlaying) {
//       await _audioPlayer.pause();
//     } else {
//       await _audioPlayer.play(AssetSource('audio/sample.mp3'));
//     }
//     setState(() {
//       isPlaying = !isPlaying;
//     });
//   }

//   // Download audio file to local storage (Files app)
//   Future<void> _downloadAudioFile() async {
//     // Request storage permission
//     var status = await Permission.storage.request();
//     if (!status.isGranted) {
//       // Handle permission denied
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Storage permission is required to download")),
//         );
//       }
//       return;
//     }

//     // Get the local directory to save the file
//     final dir = await getExternalStorageDirectory();

//     // Start the download
//     final taskId = await FlutterDownloader.enqueue(
//       url:
//           'https://www.example.com/audio/sample.mp3', // Replace with your audio file URL
//       savedDir: dir!.path,
//       fileName: 'audio_sample.mp3',
//       showNotification: true,
//       openFileFromNotification: true,
//     );

//     // Check if download was successful
//     if (taskId != null && mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Download started...")));
//     }
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Color(0xFFDDF1FF),
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.purple),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Image.asset('assets/images/audify_logo.png', height: 40),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notifications, color: Colors.purple),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(height: 20),
//           Image.asset('assets/images/audio_convert.png', height: 120),
//           SizedBox(height: 20),
//           Text(
//             "Conversion to audio\ncompleted successfully!",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 30.0),
//             child: Column(
//               children: [
//                 Slider(
//                   value: position.inSeconds.toDouble(),
//                   min: 0,
//                   max: duration.inSeconds.toDouble(),
//                   onChanged: (value) async {
//                     final newPosition = Duration(seconds: value.toInt());
//                     await _audioPlayer.seek(newPosition);
//                     await _audioPlayer.resume();
//                     setState(() {
//                       position = newPosition;
//                     });
//                   },
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}",
//                       style: TextStyle(fontSize: 14),
//                     ),
//                     Text(
//                       "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
//                       style: TextStyle(fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 20),
//           IconButton(
//             icon: Icon(
//               isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
//               size: 50,
//               color: Colors.purple,
//             ),
//             onPressed: _togglePlayback,
//           ),
//           SizedBox(height: 20),
//           GestureDetector(
//             onTap: _downloadAudioFile,
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
//               decoration: BoxDecoration(
//                 color: Color(0xFF4285F4),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     "Download to your\nDevice",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(width: 10),
//                   Image.asset('assets/images/device.png', height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(home: AudioConversionSuccessScreen()));
// }

// ignore_for_file: use_build_context_synchronously

//new, 12.5.2025
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final List<AudioPlayer> _audioPlayers = [];
  final List<bool> _isPlaying = [];
  final List<bool> _isSlideLoading = [];
  final List<bool> _hasSlideError = [];

  bool _isLoading = true;
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    for (var player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }

void _startProcessing() async {
  final uri = Uri.parse("http://10.0.2.2:5000/narrate_stream");

  final client = http.Client();
  final request = http.Request("POST", uri)
    ..headers['Content-Type'] = 'application/json'
    ..body = jsonEncode({
      "slide_texts": widget.slideTexts,
      "style": widget.style,
      "language": widget.language,
      "file_name": widget.fileName,
    });

  try {
    final response = await client.send(request);

    // Check if the response is a successful one
    if (response.statusCode != 200) {
      throw Exception("Failed to load stream, status code: ${response.statusCode}");
    }

    _subscription = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        print("Received line: $line");  // Debugging line
        if (line.startsWith('data: ')) {
          final dataString = line.substring(6).trim();
          if (dataString == '[DONE]') {
            setState(() {
              _isLoading = false;
            });
            return;
          }

          try {
            final decoded = jsonDecode(dataString);
            if (decoded.containsKey("audio_url")) {
              setState(() {
                _audioUrl = decoded["audio_url"];
              });
            } else {
              setState(() {
                _slideResults.add({
                  "original_text": decoded["original_text"] ?? "",
                  "narrated_text": decoded["narrated_text"] ?? "",
                  "translated_text": decoded["translated_text"] ?? "",
                });
                _audioPlayers.add(AudioPlayer());
                _isPlaying.add(false);
                _isSlideLoading.add(false);
                _hasSlideError.add(false);
              });
            }
          } catch (e) {
            print("Error decoding data: $e");
          }
        }
      },
      onError: (error) {
        print("Stream error: $error");
        setState(() {
          _isLoading = false;
        });
      },
      onDone: () {
        print("Stream finished");
      },
    );
  } catch (e) {
    print("Error starting stream: $e");
    setState(() {
      _isLoading = false;
    });
  }
}



  void _togglePlayback(int index) async {
    if (_isPlaying[index]) {
      await _audioPlayers[index].pause();
    } else {
      await _audioPlayers[index].play(UrlSource(_audioUrl!));
    }

    setState(() {
      _isPlaying[index] = !_isPlaying[index];
    });

    _audioPlayers[index].onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying[index] = false;
      });
    });
  }

  Future<void> _downloadAudioFile() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission is required to download")),
      );
      return;
    }

    final dir = await getExternalStorageDirectory();
    final taskId = await FlutterDownloader.enqueue(
      url: _audioUrl!,
      savedDir: dir!.path,
      fileName: '${widget.fileName}_audio.mp3',
      showNotification: true,
      openFileFromNotification: true,
    );

    if (taskId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download started...")),
      );
    }
  }

  Widget _buildSlideCardContent(int index) {
    final slide = _slideResults[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Slide ${index + 1}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 10),
        const Text('Original:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(slide["original_text"] ?? ''),
        const SizedBox(height: 10),
        const Text('Narrated:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(slide["narrated_text"] ?? ''),
        const SizedBox(height: 10),
        const Text('Translated:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(slide["translated_text"] ?? ''),
        const SizedBox(height: 15),
        if (_audioUrl != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () => _togglePlayback(index),
                icon: Icon(_isPlaying[index]
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill),
                label: Text(_isPlaying[index] ? 'Pause' : 'Play Audio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset('assets/images/audify_logo.png', height: 40),
        centerTitle: true,
        actions: [
          if (_audioUrl != null)
            IconButton(
              icon: const Icon(Icons.download, color: Colors.green),
              onPressed: _downloadAudioFile,
            ),
        ],
      ),
      body: _isLoading && _slideResults.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _slideResults.length,
              itemBuilder: (context, index) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Card(
                    key: ValueKey("slide_$index"),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _isSlideLoading.length <= index || !_isSlideLoading[index]
                          ? _buildSlideCardContent(index)
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
