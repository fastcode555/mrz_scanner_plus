import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'package:mrz_scanner_plus/src/camera_view.dart';
import 'package:mrz_scanner_plus/src/mrz_extension.dart';

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({super.key});

  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  final List<String> _scanResult = [];
  final ValueNotifier<String> _notifier = ValueNotifier('');

  void _onDetected(String text) {
    debugPrint('ocr recognize: $text');
    _notifier.value = text;
  }

  void _onMRZDetected(String imagePath, MRZResult mrzResult) {
    debugPrint('MRZ扫描结果: ${mrzResult.toJson()}');
    debugPrint('图片路径: $imagePath');
    ImageGallerySaver.saveFile(imagePath);
    // 显示MRZ扫描结果
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('MRZ扫描结果: ${mrzResult.toJson()}')),
      );
      _scanResult.add('${mrzResult.toJson()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraView(
            mode: CameraMode.scan,
            onMRZDetected: _onMRZDetected,
            onDetected: _onDetected,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ValueListenableBuilder<String>(
              valueListenable: _notifier,
              builder: (_, value, __) {
                _scanResult.add(value);
                return SizedBox(
                  height: 200,
                  child: ListView.separated(
                    itemBuilder: (_, index) => Text(
                      _scanResult[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                    reverse: true,
                    separatorBuilder: (_, __) => const Divider(),
                    itemCount: _scanResult.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
