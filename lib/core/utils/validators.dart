class Validators {
  static String? username(String? value) {
    if (value == null || value.isEmpty) return 'Username wajib diisi';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email wajib diisi';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  static String? verifyCode(String? value) {
    if (value == null || value.isEmpty) return 'Kode verif wajib diisi';
    if (value.length != 6) return 'Kode harus 6 digit!';
    return null;
  }
}
