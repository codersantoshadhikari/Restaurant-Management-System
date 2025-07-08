class Validator {
  static bool isNumeric(String input) {
    return double.tryParse(input) != null;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
