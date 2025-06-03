import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';

class EmojiHelper {
  static bool containsEmoji(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F000}-\u{1F02F}\u{1F0A0}-\u{1F0FF}\u{1F100}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{1F1E0}-\u{1F1FF}]',
      unicode: true,
    );
    return emojiRegex.hasMatch(text);
  }

  static String getEmojiFontFamily() {
    if (Platform.isWindows) {
      return 'Segoe UI Emoji';
    } else if (Platform.isIOS) {
      return 'Apple Color Emoji';
    } else {
      return 'Noto Color Emoji';
    }
  }

  static List<TextSpan> buildTextSpans(String text, Color textColor,
      {double? fontSize,}) {
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F000}-\u{1F02F}\u{1F0A0}-\u{1F0FF}\u{1F100}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{1F1E0}-\u{1F1FF}]',
      unicode: true,
    );

    final spans = <TextSpan>[];
    String currentText = '';

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (emojiRegex.hasMatch(char)) {
        if (currentText.isNotEmpty) {
          spans.add(
            TextSpan(
              text: currentText,
              style: AppTextStyles.regular_16px.copyWith(
                color: textColor,
                fontFamily: 'Noto Sans',
                fontSize: fontSize,
              ),
            ),
          );
          currentText = '';
        }
        spans.add(
          TextSpan(
            text: char,
            style: AppTextStyles.regular_16px.copyWith(
              color: textColor,
              fontFamily: getEmojiFontFamily(),
              fontSize: fontSize,
            ),
          ),
        );
      } else {
        currentText += char;
      }
    }

    if (currentText.isNotEmpty) {
      spans.add(
        TextSpan(
          text: currentText,
          style: AppTextStyles.regular_16px.copyWith(
            color: textColor,
            fontFamily: 'Noto Sans',
            fontSize: fontSize,
          ),
        ),
      );
    }

    return spans;
  }
}
