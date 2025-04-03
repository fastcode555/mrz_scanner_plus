import 'package:mrz_scanner_plus/mrz_scanner_plus.dart';
import 'package:mrz_scanner_plus/src/mrz_nid.dart';

/// @date 2025/4/3
/// describe:
class Parser {
  Parser._();

  static MRZResult? parse(String text) {
    return MrzNid.parse(text) ?? MRZHelper.parse(text);
  }
}
