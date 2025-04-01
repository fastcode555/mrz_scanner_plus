import 'package:mrz_scanner_plus/mrz_scanner_plus.dart';

/// @date 2025/4/1
/// describe:

void main() {
  const recognizedText = '''
  PNKHMATH<<VANNAK<<<<<<<<«<<<<<<<<«<««<<««««<
  NO15320156KHM9010200M2 901282NO001730802<<<62
  ''';
  final mrzResult = MRZHelper.parse(recognizedText);
  print('$mrzResult');
}
