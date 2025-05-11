class Validate {
  static bool isEmail(String email) {
    if (email.isEmpty) return false;
    final String pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(pattern).hasMatch(email);
  }
}
