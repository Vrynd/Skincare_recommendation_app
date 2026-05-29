import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalService {
  static const String _keyRememberedEmail = 'remembered_email';
  static const String _keyRememberMeStatus = 'remember_me_status';

  /// Menyimpan kredensial email berdasarkan pilihan status 'Ingat Saya' (Remember Me)
  Future<void> saveRemembered(String email, bool rememberMe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString(_keyRememberedEmail, email);
        await prefs.setBool(_keyRememberMeStatus, true);
      } else {
        await prefs.remove(_keyRememberedEmail);
        await prefs.setBool(_keyRememberMeStatus, false);
      }
    } catch (_) {}
  }

  /// Mengambil email yang terakhir tersimpan jika status centang aktif
  Future<String?> getRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyRememberedEmail);
    } catch (_) {
      return null;
    }
  }

  /// Mengambil status centang persisten 'Ingat Saya' terakhir
  Future<bool> getRememberMeStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyRememberMeStatus) ?? false;
    } catch (_) {
      return false;
    }
  }
}
