class Validators {
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

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    
    // Kiểm tra chữ cái thường
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ cái thường';
    }
    
    // Kiểm tra chữ cái hoa
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ cái hoa';
    }
    
    // Kiểm tra số
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ số';
    }
    
    // Kiểm tra ký tự đặc biệt
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt';
    }
    
    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

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

  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }
    if (value.length < 3) {
      return 'Tên đăng nhập phải có ít nhất 3 ký tự';
    }
    if (value.length > 20) {
      return 'Tên đăng nhập không được vượt quá 20 ký tự';
    }
    
    // Chỉ cho phép chữ cái và số (không có ký tự đặc biệt)
    final usernameRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Tên đăng nhập không được chứa ký tự đặc biệt';
    }
    
    // Phải có ít nhất 1 chữ cái
    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Tên đăng nhập phải có ít nhất 1 chữ cái';
    }
    
    // Phải có ít nhất 1 số
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Tên đăng nhập phải có ít nhất 1 chữ số';
    }
    
    return null;
  }
}
