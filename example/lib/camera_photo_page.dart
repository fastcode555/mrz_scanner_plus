import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mrz_scanner_plus/src/camera_view.dart';

class CameraPhotoPage extends StatelessWidget {
  const CameraPhotoPage({super.key});

  Future<void> _onPhotoTaken(String imagePath) async {
    final result = await ImageGallerySaver.saveFile(imagePath);
    debugPrint('照片保存结果: $result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        mode: CameraMode.photo,
        onPhotoTaken: _onPhotoTaken,
      ),
    );
  }
}
