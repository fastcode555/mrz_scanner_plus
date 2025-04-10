import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_scanner_plus/src/mrz_helper.dart';
import 'package:mrz_scanner_plus/src/mask_painter.dart';
import 'package:mrz_scanner_plus/src/mrz_parser/mrz_result.dart';
import 'package:mrz_scanner_plus/src/parser.dart';

typedef OnMRZDetected = void Function(String imagePath, MRZResult mrzResult);
typedef OnDetected = void Function(String recognizeText);
typedef OnPhotoTaken = void Function(String imagePath);

class MrzCameraController {
  CameraController? controller;
  BuildContext? context;

  void _bind(CameraController? controller, BuildContext context) {
    this.controller = controller;
    this.context = context;
  }

  void takePicture() {
    final state = context?.findAncestorStateOfType<_CameraViewState>();
    state?._takePicture();
  }
}

enum CameraMode { scan, photo }

class CameraView extends StatefulWidget {
  final Color? indicatorColor;
  final OnMRZDetected? onMRZDetected;
  final OnPhotoTaken? onPhotoTaken;
  final OnDetected? onDetected;
  final Widget? customOverlay;
  final CameraMode mode;
  final MrzCameraController? controller;
  final Widget? photoButton;
  final TextRecognitionScript script;

  const CameraView({
    super.key,
    this.controller,
    this.indicatorColor,
    this.onMRZDetected,
    this.onDetected,
    this.onPhotoTaken,
    this.customOverlay,
    this.mode = CameraMode.scan,
    this.photoButton,
    this.script = TextRecognitionScript.latin,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  late TextRecognizer _textRecognizer;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: widget.script);
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
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _controller?.initialize();
    if (widget.mode == CameraMode.scan) {
      await _startImageStream();
    }
    if (mounted) setState(() {});
    widget.controller?._bind(_controller, context);
  }

  bool _isProcessing = false;
  DateTime _lastProcessTime = DateTime.now();

  Future<void> _startImageStream() async {
    _controller?.startImageStream((CameraImage image) async {
      final now = DateTime.now();
      if (_isProcessing || now.difference(_lastProcessTime).inMilliseconds < 500) {
        return;
      }
      _isProcessing = true;
      _lastProcessTime = now;

      try {
        final InputImage inputImage = _processImageForMlKit(image);
        final recognizedText = await _textRecognizer.processImage(inputImage);
        widget.onDetected?.call(recognizedText.text);
        final mrzResult = Parser.parse(recognizedText.text);
        if (mrzResult == null || widget.onMRZDetected == null) return;
        if (mrzResult.isUnAvailable()) return;

        if (_controller != null && _controller!.value.isInitialized) {
          await _controller?.stopImageStream();
          final cropFile = await _takeAndCropImage();
          Future.delayed(const Duration(milliseconds: 500), () {
            widget.onMRZDetected?.call(cropFile.path, mrzResult);
          });
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
        format: Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.yuv420,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    if (_controller?.value.isStreamingImages ?? false) {
      _controller?.stopImageStream();
    }
    _controller?.dispose();
    _textRecognizer.close();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final file = await _takeAndCropImage();
    widget.onPhotoTaken?.call(file.path);
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
          RepaintBoundary(
            child: AnimatedBuilder(
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
            ),
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
        if (widget.mode == CameraMode.photo) widget.photoButton ?? _photoWidget(),
      ],
    );
  }

  Widget _photoWidget() {
    return Positioned(
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
    );
  }

  Future<File> _takeAndCropImage() async {
    final XFile picture = await _controller!.takePicture();
    // 处理图片旋转
    final imageFile = File(picture.path);

    final bytes = await imageFile.readAsBytes();
    final image = await decodeImageFromList(bytes);

    // 获取预览尺寸和实际图片尺寸
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final screenRatio = screenWidth / screenHeight;
    final realWidth = image.height * screenRatio;

    final bool isPortrait = image.height > image.width;

    // 计算护照尺寸（与遮罩框相同的比例1.42:1）
    final double cardWidth = realWidth /** 0.85*/;
    final double cardHeight = cardWidth / 1.42;
    final double left = (image.width - cardWidth) / 2;
    final double top = (image.height - cardHeight) / 2;

    // 创建护照尺寸的裁剪区域
    final ui.Rect cropRect = ui.Rect.fromLTWH(
      left,
      top,
      cardWidth,
      cardHeight,
    );

    // 创建PictureRecorder和Canvas
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    if (isPortrait) {
      // 竖屏模式，不需要旋转
      canvas.drawImageRect(
        image,
        cropRect, // 源矩形使用裁剪区域
        Rect.fromLTWH(0, 0, cardWidth, cardHeight), // 目标矩形使用裁剪尺寸
        Paint(),
      );
    } else {
      // 横屏模式，需要旋转90度
      canvas.translate(cardHeight, 0);
      canvas.rotate(pi / 2);
      canvas.drawImageRect(
        image,
        cropRect, // 源矩形使用裁剪区域
        Rect.fromLTWH(0, 0, cardWidth, cardHeight), // 目标矩形使用裁剪尺寸
        Paint(),
      );
    }

    // 获取处理后的图像
    final ui.Picture imagePicture = recorder.endRecording();
    final ui.Image processedImage = await imagePicture.toImage(
      cardWidth.round(),
      cardHeight.round(),
    );
    // 转换为字节数据
    final ByteData? byteData = await processedImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List processedBytes = byteData!.buffer.asUint8List();
    await imageFile.writeAsBytes(processedBytes);

    // 释放资源
    image.dispose();
    processedImage.dispose();
    return imageFile;
  }
}
