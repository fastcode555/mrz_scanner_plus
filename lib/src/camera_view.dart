import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'package:mrz_scanner_plus/src/mrz_helper.dart';
import 'package:mrz_scanner_plus/src/mask_painter.dart';

typedef OnMRZDetected = void Function(String imagePath, MRZResult mrzResult);

class CameraView extends StatefulWidget {
  final Color? indicatorColor;
  final OnMRZDetected? onMRZDetected;
  final Widget? customOverlay;

  const CameraView({
    super.key,
    this.indicatorColor,
    this.onMRZDetected,
    this.customOverlay,
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
    await _startImageStream();
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
        else
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
          ),
      ],
    );
  }
}
