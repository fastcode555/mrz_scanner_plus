import 'package:mrz_scanner_plus/mrz_scanner_plus.dart';

/// @date 2025/4/5
/// describe:
void main() {
  final document = '''

GATINEAU
<<<<<<<«<
PPCANMARTINK<SARAHK<<<<<<
P123456AA0CAN9008010F3301144<<<<<<««KK<«<06
Item 2 ol2
The personal information page is shown, which features maple leaves and olher security eatures.
main.dart v b0
  ''';

  final text='''
1990
Gate of bith/Date de naissa
CANAOIAN/CANADIENNE
OTTAWA CAN
4
JAN/ JAN 2U25
te of issue/Date de dervra
o163100
4 JAN/JAN 2033
DEOIAUG
GATINEAU
<<<<«<
PPCANMARTIN<<SARAHK<<<<<<<<<<<<<<<<<<<<<<<<<
P123456AA0CAN9008010F3301144<<<<<<<<K<<<<<06
ltem 2 of 2
The personal information page is shown, which features maple leaves and other security features.
Wndow HeboN
LA


  ''';
  final mrzResult = MRZHelper.parse(text);
  print('${mrzResult?.givenNames} ${mrzResult?.surnames}');
}
