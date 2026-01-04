/// Validation utilities for form inputs
/// Provides static methods for validating user input fields
class Validators {
  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// Validates password strength
  /// Requires: minimum 8 characters, at least one lowercase, one uppercase,
  /// one number, and one special character
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ cái thường';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ cái hoa';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ số';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt';
    }

    return null;
  }

  /// Validates password confirmation matches the original password
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  /// Validates full name
  /// Requires: 2-50 characters (suitable for Vietnamese names)
  static String? fullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    if (value.trim().length < 2) {
      return 'Họ và tên phải có ít nhất 2 ký tự';
    }
    if (value.length > 50) {
      return 'Họ và tên không được vượt quá 50 ký tự';
    }
    return null;
  }

  /// Validates username
  /// Requires: 3-15 characters, alphanumeric only, must start with a letter
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }
    if (value.length < 3) {
      return 'Tên đăng nhập phải có ít nhất 3 ký tự';
    }
    if (value.length > 15) {
      return 'Tên đăng nhập không được vượt quá 15 ký tự';
    }

    // Must start with a letter
    if (!value[0].contains(RegExp(r'[a-zA-Z]'))) {
      return 'Tên đăng nhập phải bắt đầu bằng chữ cái';
    }

    // Only alphanumeric characters allowed
    final usernameRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Tên đăng nhập không được chứa ký tự đặc biệt';
    }

    return null;
  }
}
