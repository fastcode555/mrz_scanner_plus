enum Sex { none, male, female }

class MRZResult {
  const MRZResult({
    required this.documentType,
    required this.countryCode,
    required this.surnames,
    required this.givenNames,
    required this.documentNumber,
    required this.nationalityCountryCode,
    required this.birthDate,
    required this.sex,
    required this.expiryDate,
    required this.personalNumber,
    this.personalNumber2,
  });

  final String documentType;
  final String countryCode;
  final String surnames;
  final String givenNames;
  final String documentNumber;
  final String nationalityCountryCode;
  final DateTime birthDate;
  final Sex sex;
  final DateTime expiryDate;
  final String personalNumber;
  final String? personalNumber2;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MRZResult &&
          runtimeType == other.runtimeType &&
          documentType == other.documentType &&
          countryCode == other.countryCode &&
          surnames == other.surnames &&
          givenNames == other.givenNames &&
          documentNumber == other.documentNumber &&
          nationalityCountryCode == other.nationalityCountryCode &&
          birthDate == other.birthDate &&
          sex == other.sex &&
          expiryDate == other.expiryDate &&
          personalNumber == other.personalNumber &&
          personalNumber2 == other.personalNumber2;

  Map<String, dynamic> toJson() => {
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

  factory MRZResult.fromJson(Map<String, dynamic> json) {
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

  @override
  int get hashCode =>
      documentType.hashCode ^
      countryCode.hashCode ^
      surnames.hashCode ^
      givenNames.hashCode ^
      documentNumber.hashCode ^
      nationalityCountryCode.hashCode ^
      birthDate.hashCode ^
      sex.hashCode ^
      expiryDate.hashCode ^
      personalNumber.hashCode ^
      personalNumber2.hashCode;

  bool isUnAvailable() {
    return surnames.isEmpty || givenNames.isEmpty || documentNumber.isEmpty;
  }
}
