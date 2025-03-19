# MRZ Scanner Plus

Ein Flutter-Plugin zum Scannen und Parsen der maschinenlesbaren Zone (MRZ) von Reisedokumenten. Beim Scannen oder Fotografieren eines Dokuments wird der MRZ-Bereich automatisch erkannt und nur das Dokumentenbild innerhalb der Maske zurückgegeben.

[![pub package](https://img.shields.io/pub/v/mrz_scanner_plus.svg)](https://pub.dev/packages/mrz_scanner_plus)

[English](README.md) | [中文](README_CN.md) | [日本語](README_JP.md) | [한국어](README_KR.md) | [Deutsch](README_DE.md)

## Funktionen

- Echtzeit-MRZ-Scannen und -Parsen
- Automatische Dokumentenbereichserkennung
- Unterstützung für Scan- und Fotomodus
- Anpassbare UI-Überlagerung
- Integriertes Dokument-Zuschneiden
- Unterstützung für mehrere MRZ-Dokumenttypen

## Screenshots

### Scanmodus

| MRZ-Scan-Oberfläche | Scan-Ergebnis | Dokumentenbild |
|:---:|:---:|:---:|
| <img src="images/img_mrz_scan.jpg" alt="MRZ Scannen" width="250"> | <img src="images/img_mrz_scan_result.jpg" alt="MRZ Scan-Ergebnis" width="250"> | <img src="images/img_mrz_card_callback.jpg" alt="MRZ Karten-Callback" width="250"> |

### Fotomodus

| Fotoaufnahme-Oberfläche | Verarbeitungsergebnis |
|:---:|:---:|
| <img src="images/img_card_take_photo.jpg" alt="Karte fotografieren" width="350"> | <img src="images/img_mrz_callback.jpg" alt="MRZ Callback" width="350"> |

## Installation

Fügen Sie dies zur `pubspec.yaml`-Datei Ihres Pakets hinzu:

```yaml
dependencies:
  mrz_scanner_plus: ^0.0.1
```

Oder installieren Sie über die Kommandozeile:

```bash
flutter pub add mrz_scanner_plus
```

## Verwendung

### Grundlegende Implementierung

```dart
import 'package:mrz_scanner_plus/mrz_scanner_plus.dart';

class CameraScanPage extends StatefulWidget {
  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  void _onMRZDetected(String imagePath, MRZResult mrzResult) {
    print('MRZ-Ergebnis: ${mrzResult.toJson()}');
    print('Bildpfad: $imagePath');
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

### Fotomodus

```dart
CameraView(
  mode: CameraMode.photo,
  onPhotoTaken: (String imagePath) {
    print('Foto gespeichert unter: $imagePath');
  },
)
```

### Anpassung

```dart
CameraView(
  mode: CameraMode.scan,
  indicatorColor: Colors.blue, // Benutzerdefinierte Überlagerungsfarbe
  customOverlay: YourCustomWidget(), // Benutzerdefiniertes Überlagerungs-Widget
  onMRZDetected: _onMRZDetected,
  onDetected: (String text) {
    print('OCR-Text: $text');
  },
)
```

## API-Referenz

### CameraView

| Eigenschaft | Typ | Beschreibung |
|----------|------|-------------|
| `mode` | `CameraMode` | Kameramodus (Scan/Foto) |
| `indicatorColor` | `Color?` | Farbe der Scan-Überlagerung |
| `onMRZDetected` | `Function(String, MRZResult)?` | Callback bei MRZ-Erkennung |
| `onPhotoTaken` | `Function(String)?` | Callback bei Fotoaufnahme |
| `onDetected` | `Function(String)?` | Callback für rohen OCR-Text |
| `customOverlay` | `Widget?` | Benutzerdefiniertes Überlagerungs-Widget |
| `controller` | `CameraController?` | Benutzerdefinierter Kamera-Controller |
| `photoButton` | `Widget?` | Benutzerdefiniertes Foto-Button-Widget |

## Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe die [LICENSE](LICENSE)-Datei für Details.

## Mitwirken

Beiträge sind willkommen! Reichen Sie gerne einen Pull Request ein.