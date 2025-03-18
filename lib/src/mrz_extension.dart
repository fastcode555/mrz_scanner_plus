import 'package:mrz_parser/mrz_parser.dart';

/// @date 2025/3/18
/// describe:
extension MrzExtension on MRZResult {
  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'countryCode': countryCode,
      'surnames': surnames,
      'givenNames': givenNames,
      'documentNumber': documentNumber,
      'nationalityCountryCode': nationalityCountryCode,
      'birthDate': birthDate.toIso8601String(),
      'sex': sex.name,
      'expiryDate': expiryDate.toIso8601String(),
      'personalNumber': personalNumber,
      'personalNumber2': personalNumber2,
    };
  }

  static MRZResult fromJson(Map<String, dynamic> json) {
    return MRZResult(
      documentType: json['documentType'] as String,
      countryCode: json['countryCode'] as String,
      surnames: json['surnames'] as String,
      givenNames: json['givenNames'] as String,
      documentNumber: json['documentNumber'] as String,
      nationalityCountryCode: json['nationalityCountryCode'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      sex: Sex.values.firstWhere((e) => e.name == json['sex']),
      // 假设 Sex 是一个 enum
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      personalNumber: json['personalNumber'] as String,
      personalNumber2: json['personalNumber2'] as String?,
    );
  }
}
