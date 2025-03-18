import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'package:mrz_scanner_plus/src/mrz_helper.dart';
import 'package:mrz_scanner_plus/src/mask_painter.dart';

typedef OnMRZDetected = void Function(String imagePath, MRZResult mrzResult);
typedef OnPhotoTaken = void Function(String imagePath);

enum CameraMode { scan, photo }

class CameraView extends StatefulWidget {
  final Color? indicatorColor;
  final OnMRZDetected? onMRZDetected;
  final OnPhotoTaken? onPhotoTaken;
  final Widget? customOverlay;
  final CameraMode mode;
  final CameraController? controller;

  const CameraView({
    super.key,
    this.indicatorColor,
    this.onMRZDetected,
    this.onPhotoTaken,
    this.customOverlay,
    this.mode = CameraMode.scan,
    this.controller,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with SingleTickerProviderStateMixin {
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
    if (widget.controller != null) {
      _controller = widget.controller;
      if (widget.mode == CameraMode.scan) {
        await _startImageStream();
      }
      if (mounted) setState(() {});
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final camera = cameras.first;
    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller?.initialize();
    if (widget.mode == CameraMode.scan) {
      await _startImageStream();
    }
    if (mounted) setState(() {});
  }

  bool _isProcessing = false;
  DateTime _lastProcessTime = DateTime.now();

  Future<void> _startImageStream() async {
    await _controller?.startImageStream((CameraImage image) async {
      final now = DateTime.now();
      if (_isProcessing || now.difference(_lastProcessTime).inMilliseconds < 500) {
        return;
      }
      _isProcessing = true;
      _lastProcessTime = now;

      try {
        final InputImage inputImage = _processImageForMlKit(image);
        final recognizedText = await _textRecognizer.processImage(inputImage);
        final mrzResult = MRZHelper.parse(recognizedText.text);
        if (mrzResult != null && widget.onMRZDetected != null) {
          if (_controller != null && _controller!.value.isInitialized) {
            final XFile picture = await _controller!.takePicture();
            await _controller?.stopImageStream();

            // 处理图片旋转
            final imageFile = File(picture.path);
            final bytes = await imageFile.readAsBytes();
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
            final ui.Picture imagePicture = recorder.endRecording();
            final ui.Image processedImage = await imagePicture.toImage(
              squareSize.round(),
              squareSize.round(),
            );
            // 转换为字节数据
            final ByteData? byteData = await processedImage.toByteData(format: ui.ImageByteFormat.png);
            final Uint8List processedBytes = byteData!.buffer.asUint8List();
            await imageFile.writeAsBytes(processedBytes);

            // 释放资源
            image.dispose();
            processedImage.dispose();

            widget.onMRZDetected!(picture.path, mrzResult);
          }
        }
      } catch (e) {
        debugPrint(e.toString());
      } finally {
        _isProcessing = false;
      }
    });
  }

  InputImage _processImageForMlKit(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    const InputImageRotation imageRotation = InputImageRotation.rotation0deg;

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

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final XFile picture = await _controller!.takePicture();
    if (widget.onPhotoTaken != null) {
      widget.onPhotoTaken!(picture.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
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
        if (widget.customOverlay != null)
          widget.customOverlay!
        else if (widget.mode == CameraMode.scan)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: MaskPainter(
                  animationValue: _animationController.value,
                  indicatorColor: widget.indicatorColor ?? const Color(0xFFE1DED7),
                ),
                size: Size.infinite,
                child: Container(),
              );
            },
          )
        else
          CustomPaint(
            painter: MaskPainter(
              animationValue: null,
              indicatorColor: widget.indicatorColor ?? const Color(0xFFE1DED7),
            ),
            size: Size.infinite,
            child: Container(),
          ),
        if (widget.mode == CameraMode.photo)
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 3, color: widget.indicatorColor ?? const Color(0xFFE1DED7)),
              ),
              child: Container(
                width: 85,
                height: 85,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _takePicture,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
