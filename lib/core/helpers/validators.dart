/// Reusable `TextFormField` validators. Return `null` when valid.
class Validators {
  const Validators._();

  static String? required(String? value, {String message = 'Bắt buộc nhập'}) {
    return (value == null || value.trim().isEmpty) ? message : null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bắt buộc nhập';
    final ok = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(value.trim());
    return ok ? null : 'Email không hợp lệ';
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.trim().length < min) {
      return 'Tối thiểu $min ký tự';
    }
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bắt buộc nhập';
    final parsed = num.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return 'Không phải là số';
    if (parsed <= 0) return 'Phải lớn hơn 0';
    return null;
  }

  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
