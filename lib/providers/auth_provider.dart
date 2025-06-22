// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart'; // Untuk debugPrint
import '/services/appwrite_service.dart'; // Sesuaikan path ini jika berbeda
import 'package:appwrite/models.dart' as appwrite_models;
// Tidak perlu import AppwriteException di sini karena sudah dihandle di service

enum AuthStatus {
  unknown, // Status awal, belum dicek
  authenticated, // Pengguna sudah login dan sesi valid
  unauthenticated, // Tidak ada pengguna login atau sesi tidak valid
}

class AuthProvider with ChangeNotifier {
  final AppwriteService _appwriteService = AppwriteService();

  appwrite_models.User? _currentUser;
  AuthStatus _authStatus = AuthStatus.unknown;
  bool _isLoading = false; // Status loading untuk operasi auth
  String? _errorMessage;

  // Getters untuk mengakses state dari luar
  appwrite_models.User? get currentUser => _currentUser;
  AuthStatus get authStatus => _authStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    debugPrint("AuthProvider: Initialized. Calling checkCurrentUserSession...");
    // Secara otomatis cek sesi saat AuthProvider pertama kali dibuat
    checkCurrentUserSession();
  }

  // Helper untuk mengatur status loading dan notifikasi listener
  void _setLoading(bool loadingStatus) {
    if (_isLoading == loadingStatus) return; // Hindari rebuild yang tidak perlu
    _isLoading = loadingStatus;
    notifyListeners();
  }

  // Helper untuk membersihkan pesan error
  void _clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      // Tidak selalu perlu notifyListeners() hanya untuk clear error,
      // kecuali UI secara eksplisit menampilkan dan menyembunyikan pesan error
    }
  }

  // Fungsi untuk memeriksa sesi pengguna saat ini (biasanya saat aplikasi start)
  Future<void> checkCurrentUserSession() async {
    debugPrint("AuthProvider: checkCurrentUserSession - Dimulai");
    _setLoading(true);
    _clearErrorMessage(); // Bersihkan error sebelumnya

    try {
      _currentUser = await _appwriteService.getCurrentUser();
      if (_currentUser != null) {
        _authStatus = AuthStatus.authenticated;
        debugPrint("AuthProvider: checkCurrentUserSession - Sesi DITEMUKAN. Pengguna: ${_currentUser!.name}");
      } else {
        _authStatus = AuthStatus.unauthenticated;
        debugPrint("AuthProvider: checkCurrentUserSession - TIDAK ada sesi aktif.");
      }
    } catch (e) {
      // Jika terjadi error saat get current user, anggap unauthenticated
      debugPrint("AuthProvider: checkCurrentUserSession - ERROR: $e");
      _authStatus = AuthStatus.unauthenticated;
      _errorMessage = "Gagal memeriksa sesi: ${e.toString().replaceFirst("Exception: ", "")}";
    }
    _setLoading(false); // Selesai loading, notifyListeners akan dipanggil
  }

  // Fungsi untuk login pengguna
  Future<bool> login(String email, String password) async {
    debugPrint("AuthProvider: login - Mencoba login untuk $email");
    _setLoading(true);
    _clearErrorMessage();

    try {
      await _appwriteService.loginUser(email: email, password: password);
      // Setelah login berhasil, dapatkan detail pengguna
      _currentUser = await _appwriteService.getCurrentUser();

      if (_currentUser != null) {
        _authStatus = AuthStatus.authenticated;
        debugPrint("AuthProvider: login - BERHASIL. Pengguna: ${_currentUser!.name}");
        _setLoading(false);
        return true;
      } else {
        // Kondisi aneh jika login berhasil tapi tidak bisa dapat user
        _errorMessage = "Login berhasil, namun gagal memuat data pengguna.";
        _authStatus = AuthStatus.unauthenticated;
        debugPrint("AuthProvider: login - BERHASIL tapi gagal get user.");
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      _authStatus = AuthStatus.unauthenticated;
      debugPrint("AuthProvider: login - GAGAL. Error: $_errorMessage");
      _setLoading(false);
      return false;
    }
  }

  // Fungsi untuk registrasi pengguna
  Future<bool> register(String name, String email, String password) async {
    debugPrint("AuthProvider: register - Mencoba registrasi untuk $email");
    _setLoading(true);
    _clearErrorMessage();

    try {
      await _appwriteService.registerUser(name: name, email: email, password: password);
      // Setelah registrasi, pengguna perlu login secara terpisah untuk MVP ini.
      // Jadi, status otentikasi tidak berubah di sini.
      debugPrint("AuthProvider: register - BERHASIL untuk $email. Pengguna perlu login.");
      _setLoading(false);
      return true; // Hanya menandakan proses registrasi ke Appwrite berhasil
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      debugPrint("AuthProvider: register - GAGAL untuk $email. Error: $_errorMessage");
      _setLoading(false);
      return false;
    }
  }

  // Fungsi untuk logout pengguna
  Future<void> logout() async {
    debugPrint("AuthProvider: logout - Mencoba logout");
    _setLoading(true);
    _clearErrorMessage();

    try {
      await _appwriteService.logoutUser();
      _currentUser = null;
      _authStatus = AuthStatus.unauthenticated;
      debugPrint("AuthProvider: logout - BERHASIL.");
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      debugPrint("AuthProvider: logout - GAGAL. Error: $_errorMessage");
      // Pertimbangkan untuk tidak mengubah _authStatus jika logout gagal,
      // atau set ke unknown agar UI bisa menampilkan pesan error.
      // Untuk kesederhanaan, kita set ke unauthenticated.
      _authStatus = AuthStatus.unauthenticated;
    }
    _setLoading(false);
  }
}