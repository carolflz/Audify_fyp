// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';

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
//             onTap: () {
//               // Handle download action
//             },
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

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioConversionSuccessScreen extends StatefulWidget {
  const AudioConversionSuccessScreen({super.key});

  @override
  AudioConversionSuccessScreenState createState() =>
      AudioConversionSuccessScreenState();
}

class AudioConversionSuccessScreenState
    extends State<AudioConversionSuccessScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  // Play or pause the audio
  void _togglePlayback() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(AssetSource('audio/sample.mp3'));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Download audio file to local storage (Files app)
  Future<void> _downloadAudioFile() async {
    // Request storage permission
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      // Handle permission denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Storage permission is required to download")),
        );
      }
      return;
    }

    // Get the local directory to save the file
    final dir = await getExternalStorageDirectory();

    // Start the download
    final taskId = await FlutterDownloader.enqueue(
      url: 'https://www.example.com/audio/sample.mp3', // Replace with your audio file URL
      savedDir: dir!.path,
      fileName: 'audio_sample.mp3',
      showNotification: true,
      openFileFromNotification: true,
    );

    // Check if download was successful
    if (taskId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download started...")),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFDDF1FF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset('assets/images/audify_logo.png', height: 40),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.purple),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Image.asset('assets/images/audio_convert.png', height: 120),
          SizedBox(height: 20),
          Text(
            "Conversion to audio\ncompleted successfully!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                Slider(
                  value: position.inSeconds.toDouble(),
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final newPosition = Duration(seconds: value.toInt());
                    await _audioPlayer.seek(newPosition);
                    await _audioPlayer.resume();
                    setState(() {
                      position = newPosition;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              size: 50,
              color: Colors.purple,
            ),
            onPressed: _togglePlayback,
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: _downloadAudioFile,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xFF4285F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Download to your\nDevice",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width: 10),
                  Image.asset('assets/images/device.png', height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: AudioConversionSuccessScreen()));
}
