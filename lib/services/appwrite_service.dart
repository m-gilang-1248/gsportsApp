// lib/services/appwrite_service.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter/foundation.dart'; // Untuk debugPrint

// GANTI DENGAN PROJECT ID ANDA
const String appwriteProjectId = '683ed1c70006a0371c78';
// GANTI DENGAN API ENDPOINT ANDA (misal: 'http://10.0.2.2/v1' jika emulator & Appwrite lokal di port 80)
const String appwriteEndpoint = 'http://192.168.224.42/v1';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;

  late final Client _client;
  late final Account account;
  // late final Databases databases;

  AppwriteService._internal() {
    _client = Client()
      .setEndpoint(appwriteEndpoint)
      .setProject(appwriteProjectId)
      .setSelfSigned(status: true);

    account = Account(_client);
    // databases = Databases(_client);
    debugPrint("AppwriteService Initialized: Endpoint: $appwriteEndpoint, Project: $appwriteProjectId");
  }

  Future<appwrite_models.User> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      debugPrint("AppwriteService: Attempting to register user $email...");
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      debugPrint("AppwriteService: User registration successful for ${user.email}");
      return user;
    } on AppwriteException catch (e) {
      debugPrint("AppwriteService: AppwriteException during registration for $email: ${e.message} (Code: ${e.code})");
      throw Exception('Registrasi Gagal: ${e.message ?? "Error tidak diketahui"}');
    } catch (e) {
      debugPrint("AppwriteService: Generic error during registration for $email: $e");
      throw Exception('Terjadi kesalahan tidak terduga saat registrasi.');
    }
  }

  Future<appwrite_models.Session> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("AppwriteService: Attempting to login user $email...");
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      debugPrint("AppwriteService: User login successful for $email, Session ID: ${session.$id}");
      return session;
    } on AppwriteException catch (e) {
      debugPrint("AppwriteService: AppwriteException during login for $email: ${e.message} (Code: ${e.code})");
      throw Exception('Login Gagal: ${e.message ?? "Email atau password salah"}');
    } catch (e) {
      debugPrint("AppwriteService: Generic error during login for $email: $e");
      throw Exception('Terjadi kesalahan tidak terduga saat login.');
    }
  }

  Future<appwrite_models.User?> getCurrentUser() async {
    try {
      debugPrint("AppwriteService: Attempting to get current user...");
      final user = await account.get();
      debugPrint("AppwriteService: Current user found: ${user.name} (ID: ${user.$id})");
      return user;
    } on AppwriteException catch (e) {
      // Error 401 (user_jwt_invalid, user_auth_missing, general_unauthorized_scope, dll) berarti tidak ada sesi valid
      debugPrint("AppwriteService: AppwriteException getting current user: ${e.message} (Code: ${e.code})");
      return null;
    } catch (e) {
      debugPrint("AppwriteService: Generic error getting current user: $e");
      return null;
    }
  }

  Future<void> logoutUser() async {
    try {
      debugPrint("AppwriteService: Attempting to logout current user...");
      await account.deleteSession(sessionId: 'current');
      debugPrint("AppwriteService: User logout successful.");
    } on AppwriteException catch (e) {
      debugPrint("AppwriteService: AppwriteException during logout: ${e.message} (Code: ${e.code})");
      throw Exception('Logout Gagal: ${e.message ?? "Error tidak diketahui"}');
    } catch (e) {
      debugPrint("AppwriteService: Generic error during logout: $e");
      throw Exception('Terjadi kesalahan tidak terduga saat logout.');
    }
  }
}