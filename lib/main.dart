import 'package:flutter/material.dart';
import 'upload_slide.dart'; 
import 'user_customization.dart'; 
import 'audio.dart';


// void main() {
//   runApp(const MyApp()); // Still keeping as const
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key}); // Constructor

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Audify',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       // ✅ Setup initial route and named routes
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const UploadSlideScreen(), // Default home screen
//         '/userCustomization': (context) => const UserCustomizationScreen(extractedText: '',), // Customization screen
//       },
//     );
//   }
// }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audify',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Show the Audio screen directly for testing in the emulator
      home: const AudioConversionSuccessScreen(),

      // ✅ Keeping named routes for future navigation
      /* initialRoute: '/',
      routes: {
        '/': (context) => const UploadSlideScreen(),
        '/userCustomization': (context) => const UserCustomizationScreen(extractedText: ''),
        '/audio': (context) => const AudioConversionSuccessScreen(),
      }, */
    );
  }
}