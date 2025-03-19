# MRZ Scanner Plus

A Flutter plugin for scanning and parsing Machine Readable Zone (MRZ) from travel documents. When scanning or photographing a document, it will automatically detect the MRZ area and return only the document image within the mask.

[![pub package](https://img.shields.io/pub/v/mrz_scanner_plus.svg)](https://pub.dev/packages/mrz_scanner_plus)

[English](README.md) | [中文](README_CN.md) | [日本語](README_JP.md) | [한국어](README_KR.md) | [Deutsch](README_DE.md)

## Features

- Real-time MRZ scanning and parsing
- Automatic document area detection
- Support for both scanning and photo modes
- Customizable UI overlay
- Built-in document cropping
- Support for multiple MRZ document types

## Screenshots

### Scanning Mode

| MRZ scanning interface | Scan result | Document image |
|:---:|:---:|:---:|
| <img src="images/img_mrz_scan.jpg" alt="MRZ Scanning" width="250"> | <img src="images/img_mrz_scan_result.jpg" alt="MRZ Scan Result" width="250"> | <img src="images/img_mrz_card_callback.jpg" alt="MRZ Card Callback" width="250"> |

### Photo Mode

| Photo capture interface | Processing result |
|:---:|:---:|
| <img src="images/img_card_take_photo.jpg" alt="Card Take Photo" width="350"> | <img src="images/img_mrz_callback.jpg" alt="MRZ Callback" width="350"> |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  mrz_scanner_plus: ^0.0.1
```

Or install via command line:

```bash
flutter pub add mrz_scanner_plus
```

## Usage

### Basic Implementation

```dart
import 'package:mrz_scanner_plus/mrz_scanner_plus.dart';

class CameraScanPage extends StatefulWidget {
  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  void _onMRZDetected(String imagePath, MRZResult mrzResult) {
    print('MRZ Result: ${mrzResult.toJson()}');
    print('Image Path: $imagePath');
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
```

### Photo Mode

```dart
CameraView(
  mode: CameraMode.photo,
  onPhotoTaken: (String imagePath) {
    print('Photo saved at: $imagePath');
  },
)
```

### Customization

```dart
CameraView(
  mode: CameraMode.scan,
  indicatorColor: Colors.blue, // Custom overlay color
  customOverlay: YourCustomWidget(), // Custom overlay widget
  onMRZDetected: _onMRZDetected,
  onDetected: (String text) {
    print('OCR Text: $text');
  },
)
```

## API Reference

### CameraView

| Property | Type | Description |
|----------|------|-------------|
| `mode` | `CameraMode` | Camera mode (scan/photo) |
| `indicatorColor` | `Color?` | Color of the scanning overlay |
| `onMRZDetected` | `Function(String, MRZResult)?` | Callback when MRZ is detected |
| `onPhotoTaken` | `Function(String)?` | Callback when photo is taken |
| `onDetected` | `Function(String)?` | Callback for raw OCR text |
| `customOverlay` | `Widget?` | Custom overlay widget |
| `controller` | `CameraController?` | Custom camera controller |
| `photoButton` | `Widget?` | Custom photo button widget |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
