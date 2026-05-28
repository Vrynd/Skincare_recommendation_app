import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recommendation_app/features/auth/models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengambil data profil dari pengguna yang saat ini sedang aktif (masuk)
  Future<UserModel?> fetchCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final data = await _supabase
          .from('users')
          .select()
          .eq('id_user', user.id)
          .single();

      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Melakukan proses masuk (sign in) menggunakan kredensial Email dan Password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw const AuthException('Gagal masuk: Pengguna tidak ditemukan');
    }
    return await fetchCurrentUserProfile();
  }

  /// Melakukan pendaftaran akun baru (sign up) dengan Email, Password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String namaLengkap,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': namaLengkap,
      },
    );

    if (response.user == null) {
      throw const AuthException('Gagal mendaftar: Terjadi kesalahan pembuatan akun');
    }

    // Mengambil profil pengguna yang dibuat
    return await _fetchUserProfileById(response.user!.id);
  }

  /// Mengirimkan surel (email) tautan pemulihan kata sandi kepada pengguna
  Future<void> sendResetPasswordEmail({required String email}) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Mengakhiri sesi aktif pengguna saat ini (sign out)
  Future<void> signOutCurrentUser() async {
    await _supabase.auth.signOut();
  }

  /// Mengambil data profil pengguna secara spesifik berdasarkan ID
  Future<UserModel?> _fetchUserProfileById(String idUser) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id_user', idUser)
          .single();
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}
