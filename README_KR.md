# MRZ Scanner Plus

여행 문서의 기계 판독 영역(MRZ)을 스캔하고 파싱하기 위한 Flutter 플러그인입니다. 문서를 스캔하거나 촬영할 때 자동으로 MRZ 영역을 감지하고 마스크 내의 문서 이미지만 반환합니다.

[![pub package](https://img.shields.io/pub/v/mrz_scanner_plus.svg)](https://pub.dev/packages/mrz_scanner_plus)

[English](README.md) | [中文](README_CN.md) | [日本語](README_JP.md) | [한국어](README_KR.md) | [Deutsch](README_DE.md)

## 특징

- 실시간 MRZ 스캔 및 파싱
- 자동 문서 영역 감지
- 스캔 및 사진 모드 지원
- 사용자 정의 가능한 UI 오버레이
- 내장 문서 크롭핑
- 다양한 MRZ 문서 유형 지원

## 스크린샷

### 스캔 모드

<div style="display: flex; justify-content: space-between;">
  <div style="flex: 1; text-align: center;">
    <img src="images/img_mrz_scan.jpg" alt="MRZ 스캔" style="max-width: 30%;">
    <p><em>MRZ 스캔 인터페이스</em></p>
  </div>
  <div style="flex: 1; text-align: center;">
    <img src="images/img_mrz_scan_result.jpg" alt="MRZ 스캔 결과" style="max-width: 30%;">
    <p><em>스캔 결과</em></p>
  </div>
  <div style="flex: 1; text-align: center;">
    <img src="images/img_mrz_card_callback.jpg" alt="MRZ 카드 콜백" style="max-width: 30%;">
    <p><em>문서 이미지</em></p>
  </div>
</div>

### 사진 모드

<div style="display: flex; justify-content: space-around;">
  <div style="flex: 1; text-align: center;">
    <img src="images/img_card_take_photo.jpg" alt="카드 촬영" style="max-width: 45%;">
    <p><em>촬영 인터페이스</em></p>
  </div>
  <div style="flex: 1; text-align: center;">
    <img src="images/img_mrz_callback.jpg" alt="MRZ 콜백" style="max-width: 45%;">
    <p><em>처리 결과</em></p>
  </div>
</div>

## 설치

패키지의 `pubspec.yaml` 파일에 다음을 추가하세요:

```yaml
dependencies:
  mrz_scanner_plus: ^0.0.1
```

또는 명령줄을 통해 설치:

```bash
flutter pub add mrz_scanner_plus
```

## 사용법

### 기본 구현

```dart
import 'package:mrz_scanner_plus/mrz_scanner_plus.dart';

class CameraScanPage extends StatefulWidget {
  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  void _onMRZDetected(String imagePath, MRZResult mrzResult) {
    print('MRZ 결과: ${mrzResult.toJson()}');
    print('이미지 경로: $imagePath');
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

### 사진 모드

```dart
CameraView(
  mode: CameraMode.photo,
  onPhotoTaken: (String imagePath) {
    print('사진 저장 위치: $imagePath');
  },
)
```

### 커스터마이징

```dart
CameraView(
  mode: CameraMode.scan,
  indicatorColor: Colors.blue, // 오버레이 색상 커스터마이징
  customOverlay: YourCustomWidget(), // 커스텀 오버레이 위젯
  onMRZDetected: _onMRZDetected,
  onDetected: (String text) {
    print('OCR 텍스트: $text');
  },
)
```

## API 참조

### CameraView

| 속성 | 타입 | 설명 |
|----------|------|-------------|
| `mode` | `CameraMode` | 카메라 모드(스캔/사진) |
| `indicatorColor` | `Color?` | 스캔 오버레이 색상 |
| `onMRZDetected` | `Function(String, MRZResult)?` | MRZ 감지 시 콜백 |
| `onPhotoTaken` | `Function(String)?` | 사진 촬영 완료 시 콜백 |
| `onDetected` | `Function(String)?` | 원시 OCR 텍스트 콜백 |
| `customOverlay` | `Widget?` | 커스텀 오버레이 위젯 |
| `controller` | `CameraController?` | 커스텀 카메라 컨트롤러 |
| `photoButton` | `Widget?` | 커스텀 촬영 버튼 위젯 |

## 라이선스

이 프로젝트는 MIT 라이선스로 제공됩니다 - 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 기여

기여를 환영합니다! 언제든지 Pull Request를 제출해 주세요.