# MRZ Scanner Plus

旅行文書の機械読取可能ゾーン（MRZ）をスキャンして解析するためのFlutterプラグインです。文書をスキャンまたは撮影する際、自動的にMRZ領域を検出し、マスク内の文書画像のみを返します。

[![pub package](https://img.shields.io/pub/v/mrz_scanner_plus.svg)](https://pub.dev/packages/mrz_scanner_plus)

[English](README.md) | [中文](README_CN.md) | [日本語](README_JP.md) | [한국어](README_KR.md) | [Deutsch](README_DE.md)

## 特徴

- リアルタイムMRZスキャンと解析
- 自動文書領域検出
- スキャンモードと写真モードの両方をサポート
- カスタマイズ可能なUIオーバーレイ
- 内蔵文書クロップ機能
- 複数のMRZ文書タイプをサポート

## スクリーンショット

### スキャンモード

<div style="display: flex; justify-content: space-between;">
  <div style="flex: 1; text-align: center;">
    <img src="images/img_mrz_scan.jpg" alt="MRZスキャン" style="max-width: 30%;">
    <p><em>MRZスキャンインターフェース</em></p>
  </div>
  <div style="flex: 1; text-align: center;">
    <img src="images/img_mrz_scan_result.jpg" alt="MRZスキャン結果" style="max-width: 30%;">
    <p><em>スキャン結果</em></p>
  </div>
  <div style="flex: 1; text-align: center;">
    <img src="images/img_mrz_card_callback.jpg" alt="MRZカードコールバック" style="max-width: 30%;">
    <p><em>文書画像</em></p>
  </div>
</div>

### 写真モード

<div style="display: flex; justify-content: space-around;">
  <div style="flex: 1; text-align: center;">
    <img src="images/img_card_take_photo.jpg" alt="カード撮影" style="max-width: 45%;">
    <p><em>撮影インターフェース</em></p>
  </div>
  <div style="flex: 1; text-align: center;">
    <img src="images/img_mrz_callback.jpg" alt="MRZコールバック" style="max-width: 45%;">
    <p><em>処理結果</em></p>
  </div>
</div>

## インストール

パッケージの`pubspec.yaml`ファイルに以下を追加してください：

```yaml
dependencies:
  mrz_scanner_plus: ^0.0.1
```

またはコマンドラインからインストール：

```bash
flutter pub add mrz_scanner_plus
```

## 使用方法

### 基本実装

```dart
import 'package:mrz_scanner_plus/mrz_scanner_plus.dart';

class CameraScanPage extends StatefulWidget {
  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  void _onMRZDetected(String imagePath, MRZResult mrzResult) {
    print('MRZ結果: ${mrzResult.toJson()}');
    print('画像パス: $imagePath');
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

### 写真モード

```dart
CameraView(
  mode: CameraMode.photo,
  onPhotoTaken: (String imagePath) {
    print('写真の保存先: $imagePath');
  },
)
```

### カスタマイズ

```dart
CameraView(
  mode: CameraMode.scan,
  indicatorColor: Colors.blue, // オーバーレイの色をカスタマイズ
  customOverlay: YourCustomWidget(), // カスタムオーバーレイウィジェット
  onMRZDetected: _onMRZDetected,
  onDetected: (String text) {
    print('OCRテキスト: $text');
  },
)
```

## APIリファレンス

### CameraView

| プロパティ | 型 | 説明 |
|----------|------|-------------|
| `mode` | `CameraMode` | カメラモード（スキャン/写真）|
| `indicatorColor` | `Color?` | スキャンオーバーレイの色 |
| `onMRZDetected` | `Function(String, MRZResult)?` | MRZ検出時のコールバック |
| `onPhotoTaken` | `Function(String)?` | 写真撮影完了時のコールバック |
| `onDetected` | `Function(String)?` | 生のOCRテキストのコールバック |
| `customOverlay` | `Widget?` | カスタムオーバーレイウィジェット |
| `controller` | `CameraController?` | カスタムカメラコントローラー |
| `photoButton` | `Widget?` | カスタム撮影ボタンウィジェット |

## ライセンス

このプロジェクトはMITライセンスの下で公開されています - 詳細は[LICENSE](LICENSE)ファイルをご覧ください。

## 貢献

貢献大歓迎です！お気軽にPull Requestを提出してください。