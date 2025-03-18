import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mrz_scanner_plus/src/mrz_extension.dart';
import 'package:mrz_scanner_plus/src/mrz_helper.dart';
import 'package:mrz_scanner_plus/src/mask_painter.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  final _textRecognizer = TextRecognizer();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final camera = cameras.first;
    _controller = CameraController(
      camera,
      ResolutionPreset.max, // 降低分辨率以减少内存使用
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller?.initialize();
    await _startImageStream();
    if (mounted) setState(() {});
  }

  bool _isProcessing = false;
  DateTime _lastProcessTime = DateTime.now();

  Future<void> _startImageStream() async {
    await _controller?.startImageStream((CameraImage image) async {
      // 添加节流控制，限制处理频率
      final now = DateTime.now();
      if (_isProcessing || now.difference(_lastProcessTime).inMilliseconds < 500) {
        return;
      }
      _isProcessing = true;
      _lastProcessTime = now;

      try {
        // 正确处理YUV420格式的图像
        final InputImage inputImage = _processImageForMlKit(image);
        final recognizedText = await _textRecognizer.processImage(inputImage);
        debugPrint('ocr:${recognizedText.text}');
        final mrzResult = MRZHelper.parse(recognizedText.text);
        if (mrzResult != null) {
          debugPrint('${mrzResult.toJson()}');
          // 使用takePicture方法获取高质量图片而不是直接使用当前帧
          if (_controller != null && _controller!.value.isInitialized) {
            // 拍照并保存
            final XFile picture = await _controller!.takePicture();
            await _saveImage(picture.path);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('MRZ码识别成功，图片已保存到相册：${mrzResult.toJson()}')),
              );
            }

            // 短暂延迟后恢复处理
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      } catch (e) {
        debugPrint(e.toString());
      } finally {
        _isProcessing = false;
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
    const InputImageRotation imageRotation = InputImageRotation.rotation0deg;

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
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 使用image包处理图像
    final image = await decodeImageFromList(bytes);

    // 确定图片的实际宽高，并计算正方形裁剪区域
    final bool isPortrait = image.height > image.width;
    final double squareSize = min(image.width.toDouble(), image.height.toDouble());
    final double left = (image.width - squareSize) / 2;
    final double top = (image.height - squareSize) / 2;

    // 创建正方形裁剪区域
    final ui.Rect cropRect = ui.Rect.fromLTWH(
      left.round().toDouble(),
      top.round().toDouble(),
      squareSize.round().toDouble(),
      squareSize.round().toDouble(),
    );

    // 创建PictureRecorder和Canvas
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    if (isPortrait) {
      // 竖屏模式，不需要旋转
      canvas.drawImageRect(
        image,
        cropRect,
        Rect.fromLTWH(0, 0, squareSize, squareSize),
        Paint(),
      );
    } else {
      // 横屏模式，需要旋转90度
      canvas.translate(squareSize, 0);
      canvas.rotate(pi / 2);
      canvas.drawImageRect(
        image,
        cropRect,
        Rect.fromLTWH(0, 0, squareSize, squareSize),
        Paint(),
      );
    }

    // 获取处理后的图像
    final ui.Picture picture = recorder.endRecording();
    final ui.Image processedImage = await picture.toImage(
      squareSize.round(),
      squareSize.round(),
    );

    // 转换为字节数据
    final ByteData? byteData = await processedImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List processedBytes = byteData!.buffer.asUint8List();

    // 保存处理后的图像
    await ImageGallerySaver.saveImage(
      processedBytes,
      name: 'MRZ_$timestamp.jpg',
      quality: 100,
    );

    // 释放资源
    image.dispose();
    processedImage.dispose();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize!.height,
                height: _controller!.value.previewSize!.width,
                child: CameraPreview(_controller!),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: MaskPainter(animationValue: _animationController.value),
                size: Size.infinite,
                child: Container(),
              );
            },
          ),
        ],
      ),
    );
  }
}
