import 'package:flutter/material.dart';

class AppColors {
  //Primary Color (Blue)
  static const primaryColor_50 = Color(0xFFe8f0f9);
  static const primaryColor_100 = Color(0xFFb6cfeb);
  static const primaryColor_200 = Color(0xFF93b8e2);
  static const primaryColor_300 = Color(0xFF6298d5);
  static const primaryColor_400 = Color(0xFF4484cd);
  static const primaryColor_500 = Color(0xFF1565c0);
  static const primaryColor_600 = Color(0xFF135caf);
  static const primaryColor_700 = Color(0xFF0f4888);
  static const primaryColor_800 = Color(0xFF0c386a);
  static const primaryColor_900 = Color(0xFF092a51);

  //Light Blue
  static const lightBlue_50 = Color(0xFFecf9ff);
  static const lightBlue_100 = Color(0xFFc4edff);
  static const lightBlue_200 = Color(0xFFa7e4ff);
  static const lightBlue_300 = Color(0xFF7fd7ff);
  static const lightBlue_400 = Color(0xFF66d0ff);
  static const lightBlue_500 = Color(0xFF40c4ff);
  static const lightBlue_600 = Color(0xFF3ab2e8);
  static const lightBlue_700 = Color(0xFF2d8bb5);
  static const lightBlue_800 = Color(0xFF236c8c);
  static const lightBlue_900 = Color(0xFF1b526b);

  //Red
  static const red_50 = Color(0xFFfeeceb);
  static const red_100 = Color(0xFFfcc5c1);
  static const red_200 = Color(0xFFfaa9a3);
  static const red_300 = Color(0xFFf88178);
  static const red_400 = Color(0xFFf6695e);
  static const red_500 = Color(0xFFf44336);
  static const red_600 = Color(0xFFde3d31);
  static const red_700 = Color(0xFFad3026);
  static const red_800 = Color(0xFF86251e);
  static const red_900 = Color(0xFF661c17);

  //Yellow
  static const yellow_50 = Color(0xFFfff9e6);
  static const yellow_100 = Color(0xFFffeeb0);
  static const yellow_200 = Color(0xFFffe58a);
  static const yellow_300 = Color(0xFFffd954);
  static const yellow_400 = Color(0xFFffd233);
  static const yellow_500 = Color(0xFFffc700);
  static const yellow_600 = Color(0xFFe8b500);
  static const yellow_700 = Color(0xFFb58d00);
  static const yellow_800 = Color(0xFF8c6d00);
  static const yellow_900 = Color(0xFF6b5400);

  //Green
  static const green_50 = Color(0xFFe6faee);
  static const green_100 = Color(0xFFb0eeca);
  static const green_200 = Color(0xFF8ae6b0);
  static const green_300 = Color(0xFF54da8c);
  static const green_400 = Color(0xFF33d375);
  static const green_500 = Color(0xFF00c853);
  static const green_600 = Color(0xFF00b64c);
  static const green_700 = Color(0xFF008e3b);
  static const green_800 = Color(0xFF006e2e);
  static const green_900 = Color(0xFF005423);

  //Neutral
  static const neutral_50 = Color(0xFFF2F2F2);
  static const neutral_100 = Color(0xFFE6E6E6);
  static const neutral_200 = Color(0xFFCCCCCC);
  static const neutral_300 = Color(0xFFB3B3B3);
  static const neutral_400 = Color(0xFF999999);
  static const neutral_500 = Color(0xFF808080);
  static const neutral_600 = Color(0xFF666666);
  static const neutral_700 = Color(0xFF4D4D4D);
  static const neutral_800 = Color(0xFF333333);
  static const neutral_900 = Color(0xFF1A1A1A);

  //Other
  static const white = Color(0xFFffffff);
  static const black = Color(0xFF292929);
  static const gradientBlue = LinearGradient(
    colors: [
      Color(0xFF1565C0),
      Color(0xFF0F4888),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const gradientLightBlue = LinearGradient(
    colors: [
      Color(0xFF40C4FF),
      Color(0xFF03A9F4),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
}
