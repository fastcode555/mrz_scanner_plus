import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'package:mrz_scanner_plus/mrz_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  bool _isProcessing = false;
  final _textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final camera = cameras.first;
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller?.initialize();
    await _startImageStream();
    if (mounted) setState(() {});
  }

  Future<void> _startImageStream() async {
    await _controller?.startImageStream((CameraImage image) async {
      if (_isProcessing) return;

      setState(() => _isProcessing = true);

      try {
        // 正确处理YUV420格式的图像
        final InputImage inputImage = _processImageForMlKit(image);
        final recognizedText = await _textRecognizer.processImage(inputImage);

        String fullText = recognizedText.text;
        String trimmedText = fullText.replaceAll(' ', '');
        List allText = trimmedText.split('\n');

        List<String> ableToScanText = [];
        for (var e in allText) {
          if (MRZHelper.testTextLine(e).isNotEmpty) {
            ableToScanText.add(MRZHelper.testTextLine(e));
          }
        }
        List<String>? result = MRZHelper.getFinalListToParse([...ableToScanText]);

        if (result != null) {
          final mrzResult = MRZParser.parse(result);
          if (mrzResult != null) {
            // 使用takePicture方法获取高质量图片而不是直接使用当前帧
            if (_controller != null && _controller!.value.isInitialized) {
              // 暂停图像流处理，但不停止图像流
              setState(() => _isProcessing = true);

              // 拍照并保存
              final XFile picture = await _controller!.takePicture();
              await _saveImage(picture.path);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('MRZ码识别成功，图片已保存到相册')),
                );
              }

              // 短暂延迟后恢复处理
              await Future.delayed(const Duration(milliseconds: 500));
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('处理失败: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    });
  }

  // 处理相机图像为ML Kit可用的格式
  InputImage _processImageForMlKit(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    // 根据设备方向设置正确的旋转
    final InputImageRotation imageRotation = InputImageRotation.rotation0deg;

    // 创建InputImage - 使用新版API
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Future<void> _saveImage(String imagePath) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      await ImageGallerySaver.saveImage(bytes);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('护照MRZ扫描')),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          CustomPaint(
            painter: MaskPainter(),
            child: Container(),
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class MaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // 护照标准尺寸比例为1.42:1
    final double cardWidth = size.width * 0.85;
    final double cardHeight = cardWidth / 1.42;
    final double left = (size.width - cardWidth) / 2;
    final double top = (size.height - cardHeight) / 2;

    // Draw the semi-transparent overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRect(Rect.fromLTWH(left, top, cardWidth, cardHeight)),
      ),
      paint,
    );

    // Draw the border of the card area
    canvas.drawRect(
      Rect.fromLTWH(left, top, cardWidth, cardHeight),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
