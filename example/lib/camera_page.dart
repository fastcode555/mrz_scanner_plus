import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mrz_scanner_plus/mrz_scanner_plus.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveImage(String imagePath, MRZResult mrzResult) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 显示MRZ扫描结果
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('MRZ扫描结果: ${mrzResult.toJson()}')),
      );
    }

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        indicatorColor: const Color(0xffd94e8c),
        mode: CameraMode.photo,
        onMRZDetected: _saveImage,
      ),
    );
  }
}
