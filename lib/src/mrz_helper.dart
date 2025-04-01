import 'package:flutter/material.dart';
import 'package:mrz_scanner_plus/src/mrz_parser/mrz_parser.dart';
import 'package:mrz_scanner_plus/src/mrz_parser/mrz_result.dart';

class MRZHelper {
  static List<String>? getFinalListToParse(List<String> ableToScanTextList) {
    if (ableToScanTextList.length < 2) {
      // minimum length of any MRZ format is 2 lines
      return null;
    }
    var lineLength = ableToScanTextList.first.length;
    for (final e in ableToScanTextList) {
      if (e.length != lineLength) {
        return null;
      }
      // to make sure that all lines are the same in length
    }
    var firstLineChars = ableToScanTextList.first.split('');
    var supportedDocTypes = <String>['A', 'C', 'P', 'V', 'I'];
    var fChar = firstLineChars[0];
    if (supportedDocTypes.contains(fChar)) {
      return [...ableToScanTextList];
    }
    return null;
  }

  static String testTextLine(String text) {
    //sometimes the symbol is very same,cause cannot recognize the correct mrz code
    if (text.contains('<')) {
      text = text
          .replaceAll(' ', '')
          .replaceAll('‹', '<')
          .replaceAll('≪', '<')
          .replaceAll('⪡', '<')
          .replaceAll('«', '<')
          .replaceAll('⟨', '<')
          .replaceAll('《', '<')
          .replaceAll('‹', '<')
          .replaceAll('<K<', '<<<')
          .replaceAll('<k<', '<<<');
      final index = text.indexOf('<<<');
      if (index > 0) {
        final header = text.substring(0, index);
        var tail = text.substring(index, text.length);
        text = '$header${tail.replaceAll('k', '<').replaceAll('K', '<')}';
      }
    }
    var list = text.split('');
    // to check if the text belongs to any MRZ format or not
    if (list.length != 44 && list.length != 30 && list.length != 36) {
      return text.contains('<') ? text : '';
    }

    for (var i = 0; i < list.length; i++) {
      if (RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i])) {
        list[i] = list[i].toUpperCase();
        // to ensure that every letter is uppercase
      }
      if (double.tryParse(list[i]) == null && !RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i])) {
        list[i] = '<';
        // sometimes < sign not recognized well
      }
    }
    var result = list.join();
    return result;
  }

  static MRZResult? parse(String recognizedText) {
    var fullText = recognizedText.trim().replaceAll(' ', '');
    List allText = fullText.split('\n');

    var ableToScanText = <String>[];
    for (final line in allText) {
      if (MRZHelper.testTextLine(line).isNotEmpty) {
        ableToScanText.add(MRZHelper.testTextLine(line));
      }
    }

    final mrzLines = _filterAvaliableLines(ableToScanText);
    for (final mrz2Line in mrzLines) {
      debugPrint('OCR:\N${mrz2Line.join('\n')}');
      var lines = MRZHelper.getFinalListToParse(mrz2Line);
      if (lines != null && lines.isNotEmpty) {
        try {
          final mrzResult = MRZParser.parse(lines);
          debugPrint('$mrzResult');
          return mrzResult;
        } catch (e) {
          print(e);
        }
      }
    }
    return null;
  }

  static List<List<String>> _filterAvaliableLines(List<String> lines) {
    final avaliableLines = <List<String>>[];
    final mrz30Lines = <String>[];
    final mrz36Lines = <String>[];
    final mrz44Lines = <String>[];

    var containSpecialSymbolLine = '<';

    for (final line in lines) {
      if (line.contains('<')) {
        final isEmpty = line.replaceAll('<', '').trim().isEmpty;
        if (!isEmpty) {
          containSpecialSymbolLine = line;
        }
      }

      final length = line.length;
      if (length == 30) mrz30Lines.add(line);
      if (length == 36) mrz36Lines.add(line);
      if (length == 44) mrz44Lines.add(line);
    }

    if (mrz30Lines.isNotEmpty && mrz30Lines.length == 1) {
      mrz30Lines.insert(0, '$containSpecialSymbolLine${'<' * (30 - containSpecialSymbolLine.length)}');
    }

    if (mrz36Lines.isNotEmpty && mrz36Lines.length == 1) {
      mrz36Lines.insert(0, '$containSpecialSymbolLine${'<' * (36 - containSpecialSymbolLine.length)}');
    }

    if (mrz44Lines.isNotEmpty && mrz44Lines.length == 1) {
      mrz44Lines.insert(0, '$containSpecialSymbolLine${'<' * (44 - containSpecialSymbolLine.length)}');
    }

    if (mrz30Lines.length >= 2) avaliableLines.add(mrz30Lines);
    if (mrz36Lines.length >= 2) avaliableLines.add(mrz36Lines);
    if (mrz44Lines.length >= 2) avaliableLines.add(mrz44Lines);

    return avaliableLines;
  }
}
