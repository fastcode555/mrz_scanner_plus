import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'package:mrz_scanner_plus/src/camera_view.dart';
import 'package:mrz_scanner_plus/src/mrz_extension.dart';

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({super.key});

  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  void _onMRZDetected(String imagePath, MRZResult mrzResult) {
    debugPrint('MRZ扫描结果: ${mrzResult.toJson()}');
    debugPrint('图片路径: $imagePath');
    // 显示MRZ扫描结果
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('MRZ扫描结果: ${mrzResult.toJson()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        mode: CameraMode.scan,
        onMRZDetected: _onMRZDetected,
      ),
    );
  }
}
