import 'package:flutter/material.dart';
import 'package:mrz_scanner_plus_example/camera_photo_page.dart';
import 'package:mrz_scanner_plus_example/camera_scan_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('护照MRZ扫描'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraScanPage(),
                  ),
                );
              },
              child: const Text('扫描护照'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraPhotoPage(),
                  ),
                );
              },
              child: const Text('拍照'),
            ),
          ],
        ),
      ),
    );
  }
}
