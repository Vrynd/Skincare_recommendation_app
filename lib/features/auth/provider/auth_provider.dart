import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recommendation_app/features/auth/models/user_model.dart';
import 'package:recommendation_app/features/auth/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Menginisialisasi status autentikasi saat aplikasi pertama kali dijalankan
  Future<void> initializeAuth() async {
    _setLoading(true);
    _currentUser = await _authService.fetchCurrentUserProfile();
    _setLoading(false);
  }

  /// Melakukan proses masuk (sign in) pengguna
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem saat mencoba masuk: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Melakukan proses masuk menggunakan akun Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Gagal masuk dengan Google: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Melakukan proses pendaftaran (sign up) akun baru
  Future<bool> signUp({
    required String email,
    required String password,
    required String namaLengkap,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        namaLengkap: namaLengkap,
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem saat mendaftar akun baru: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mengirimkan tautan reset kata sandi ke surel (email) pengguna
  Future<bool> sendPasswordReset({required String email}) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendResetPasswordEmail(email: email);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem saat mengirim email pemulihan.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mengakhiri sesi aktif pengguna saat ini (sign out)
  Future<void> signOut() async {
    _currentUser = null;
    _clearError();
    notifyListeners();

    try {
      await _authService.signOutCurrentUser();
    } catch (e) {
      _errorMessage = 'Gagal mengakhiri sesi aktif.';
    }
  }

  /// Membersihkan pesan kesalahan saat ini
  void clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Helper internal untuk mengubah status pemuatan
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Helper internal untuk menghapus pesan kesalahan
  void _clearError() {
    _errorMessage = null;
  }
}
