class ValidationService {

  bool isValidEmail(String email) {
    // Definir la expresión regular para validar correos electrónicos
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);

    return regex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    // No debe contener espacios
    if (password.contains(RegExp(r'\s'))) {
      return false;
    }
    // Definir los criterios
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );
    bool hasMinLength = password.length >= 8;

    return hasUppercase &&
        hasLowercase &&
        hasDigits &&
        hasSpecialCharacters &&
        hasMinLength;
  }

  bool isValidName(String name) {
    name.trim();
    bool hasMinLength = name.length >= 10;
    bool hasMaxLength = name.length <= 50;

    return hasMaxLength && hasMinLength;
  }

  bool idValidCode(String code) {
    code.trim();
    bool hasMinLength = code.length >= 10;
    bool hasMaxLength = code.length <= 30;

    return hasMinLength &&
        hasMaxLength;
  }

}