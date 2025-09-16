import 'package:flutter/services.dart';

class ArabicToEnglishNumberFormatter extends TextInputFormatter {
  static const _arabicNumbers = [
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩'
  ];
  static const _englishNumbers = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9'
  ];

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String converted = newValue.text;
    for (int i = 0; i < _arabicNumbers.length; i++) {
      converted = converted.replaceAll(_arabicNumbers[i], _englishNumbers[i]);
    }
    return newValue.copyWith(
      text: converted,
      selection: TextSelection.collapsed(offset: converted.length),
    );
  }
}
