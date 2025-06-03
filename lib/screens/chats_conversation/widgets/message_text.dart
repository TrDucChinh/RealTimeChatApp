import 'package:flutter/material.dart';

import '../../../common/helper/emoji_helper.dart';
import '../../../config/theme/utils/app_colors.dart';
import '../../../config/theme/utils/text_styles.dart';

class MessageText extends StatelessWidget {
  final String text;
  final bool isSender;

  const MessageText({
    super.key,
    required this.text,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: _buildTextSpans(
          text,
          isSender ? Colors.white : AppColors.neutral_900,
        ),
      ),
      textAlign: TextAlign.start,
      overflow: TextOverflow.visible,
    );
  }

  List<TextSpan> _buildTextSpans(String text, Color textColor) {
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
              fontFamily: EmojiHelper.getEmojiFontFamily(),
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
          ),
        ),
      );
    }

    return spans;
  }
}