import 'package:intl/intl.dart';
import 'package:mrz_scanner_plus/src/mrz_parser/mrz_result.dart';

class MrzNid {
  static RegExp nameRegex = RegExp(r'([A-Z]+, [A-Za-z ]+)');
  static RegExp idRegex = RegExp(r'(\d{4} \d{4} \d{4})');
  static RegExp dobRegex = RegExp(r'(\d{2}-\d{2}-\d{4})');
  static RegExp genderRegex = RegExp(r'(\d{2}-\d{2}-\d{4}.*?[M|F])');
  static RegExp issueDateRegex = RegExp(r'(\d{2}-\d{2}-\d{2}(?=[ \n]))');
  static RegExp cardNumberRegex = RegExp(r'([A-Z]{1}[0-9Oo ]{6,9}\([0-9a-zA-Z]{1,3}\))');

  static MRZResult? parse(String text) {
    // 匹配结果
    try {
      String? name = nameRegex.firstMatch(text.replaceAll('，', ','))?.group(1)?.trim();
      if (isEmpty(name)) return null;
      final results = name!.split(',');
      String firstName = results.first;
      String lastName = results.last;

      String? id = idRegex.firstMatch(text)?.group(1)?.trim();
      if (isEmpty(id)) return null;

      DateTime? dob = DateFormat("dd-MM-yy").parse(dobRegex.firstMatch(text)?.group(1)?.trim() ?? '');
      String? gender = genderRegex.firstMatch(text)?.group(1)?.trim();
      Sex sex = (gender?.endsWith('M') ?? false) ? Sex.male : Sex.female;
      if (isEmpty(gender)) return null;

      DateTime? issueDate = DateFormat("dd-MM-yy").parse(issueDateRegex.firstMatch(text)?.group(1)?.trim() ?? '');
      String? cardNumber = cardNumberRegex.firstMatch(text)?.group(1)?.trim().replaceAll(' ', '');
      if (isEmpty(cardNumber)) return null;

      return MRZResult(
          documentType: '',
          countryCode: '',
          surnames: lastName,
          givenNames: firstName,
          documentNumber: cardNumber ?? '',
          nationalityCountryCode: '',
          birthDate: dob,
          sex: sex,
          expiryDate: issueDate,
          personalNumber: id!);
    } catch (e) {
      print(e);
    }
    return null;
  }

  static bool isEmpty(String? text) => text == null || text.isEmpty;
}
