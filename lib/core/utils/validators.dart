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

  /// Validates quiz title
  static String? quizTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tiêu đề quiz';
    }
    if (value.trim().length < 3) {
      return 'Tiêu đề phải có ít nhất 3 ký tự';
    }
    if (value.length > 100) {
      return 'Tiêu đề không được vượt quá 100 ký tự';
    }
    return null;
  }

  /// Validates quiz description (optional)
  static String? quizDescription(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (value.trim().length < 10) {
      return 'Mô tả phải có ít nhất 10 ký tự';
    }
    if (value.length > 500) {
      return 'Mô tả không được vượt quá 500 ký tự';
    }
    return null;
  }

  /// Validates question text
  static String? questionText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập nội dung câu hỏi';
    }
    if (value.trim().length < 5) {
      return 'Nội dung câu hỏi phải có ít nhất 5 ký tự';
    }
    if (value.length > 500) {
      return 'Nội dung câu hỏi không được vượt quá 500 ký tự';
    }
    return null;
  }

  /// Validates option text
  static String? optionText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập đáp án';
    }
    if (value.trim().length < 1) {
      return 'Đáp án không được để trống';
    }
    if (value.length > 200) {
      return 'Đáp án không được vượt quá 200 ký tự';
    }
    return null;
  }

  /// Validates time limit (seconds)
  static String? timeLimit(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập thời gian';
    }
    final time = int.tryParse(value);
    if (time == null) {
      return 'Thời gian phải là số';
    }
    if (time < 5) {
      return 'Thời gian tối thiểu là 5 giây';
    }
    if (time > 300) {
      return 'Thời gian tối đa là 300 giây (5 phút)';
    }
    return null;
  }

  /// Validates points
  static String? points(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập điểm số';
    }
    final points = int.tryParse(value);
    if (points == null) {
      return 'Điểm số phải là số';
    }
    if (points < 1) {
      return 'Điểm số tối thiểu là 1';
    }
    if (points > 10000) {
      return 'Điểm số tối đa là 10000';
    }
    return null;
  }
}
