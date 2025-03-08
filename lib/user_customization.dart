import 'package:flutter/material.dart';

class UserCustomizationScreen extends StatelessWidget {
  const UserCustomizationScreen({super.key}); // Added `key` as a named parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.black87),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black87),
            onPressed: () {},
          ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 10),
            Image.asset(
              'assets/images/audify_logo.png', // ✅ Make sure this exists
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'This is sample extracted text.', // ✅ Ensure this dynamically updates later
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Icon(Icons.mic, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Audio Customization:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ Narration Style Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue[700],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownColor: Colors.blue[700],
              value: null,
              hint: const Text(
                'Select Narration Style',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              items: const [
                DropdownMenuItem(value: 'formal', child: Text('Formal Lecture', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'ted', child: Text('TED Talk Style', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'casual', child: Text('Casual', style: TextStyle(color: Colors.white))),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),

            // ✅ Voice Preference Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.cyan[500],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownColor: Colors.cyan[500],
              value: null,
              hint: const Text(
                'Choose Voice Preference',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male Voice', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'female', child: Text('Female Voice', style: TextStyle(color: Colors.white))),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),

            // ✅ Language Selection Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownColor: Colors.blue[300],
              value: null,
              hint: const Text(
                'Select Language for Audio',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'zh', child: Text('Chinese', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'ms', child: Text('Malay', style: TextStyle(color: Colors.white))),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),

            // ✅ Convert to Audio Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Implement your action here
              },
              child: const Text(
                'Convert to Audio',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
