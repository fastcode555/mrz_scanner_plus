import 'package:intl/intl.dart';

void main() {
  String text = '''
    SAN, Chi Nan  
    3947 2535 5174  
    Date of Birth  
    01-01-1988 F  
    ***AZ  
    Date of Issue  
    (01-99)  
    15-09-18  
    C668668(E)  
  ''';

  int start = DateTime.now().millisecondsSinceEpoch;
  RegExp nameRegex = RegExp(r'([A-Z]+, [A-Za-z ]+)');
  RegExp idRegex = RegExp(r'(\d{4} \d{4} \d{4})');
  RegExp dobRegex = RegExp(r'(\d{2}-\d{2}-\d{4})');
  RegExp genderRegex = RegExp(r'(\d{2}-\d{2}-\d{4}.*?[M|F])');
  RegExp issueDateRegex = RegExp(r'(\d{2}-\d{2}-\d{2}(?=[ \n]))');
  RegExp cardNumberRegex = RegExp(r'([A-Z]{1}[0-9Oo ]{6,9}\([0-9a-zA-Z]{1,3}\))');

  // 匹配结果
  String? name = nameRegex.firstMatch(text.replaceAll('，', ','))?.group(1)?.trim();
  String? id = idRegex.firstMatch(text)?.group(1)?.trim();
  DateTime? dob = DateFormat("dd-MM-yy").parse(dobRegex.firstMatch(text)?.group(1)?.trim() ?? '');
  String? gender = genderRegex.firstMatch(text)?.group(1)?.trim();
  gender = (gender?.endsWith('M') ?? false) ? 'M' : 'F';
  DateTime? issueDate = DateFormat("dd-MM-yy").parse(issueDateRegex.firstMatch(text)?.group(1)?.trim() ?? '');

  String? cardNumber = cardNumberRegex.firstMatch(text)?.group(1)?.trim().replaceAll(' ', '');

  int spentTime = DateTime.now().millisecondsSinceEpoch - start;

  print('$spentTime $name $id $dob $gender $issueDate $cardNumber');
}
