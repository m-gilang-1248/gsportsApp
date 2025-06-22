// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '/providers/auth_provider.dart'; // Path ke provider
// LoginScreen tidak perlu diimport di sini lagi
// import 'package:pesan_lapangan_mvp/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/models.dart' as appwrite_models; // Untuk tipe User

class HomeScreen extends StatelessWidget { // Bisa jadi StatelessWidget jika data dari Provider
  static const String routeName = '/home';
  const HomeScreen({super.key});

  void _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    // Navigasi akan dihandle oleh AuthWrapper
  }

  @override
  Widget build(BuildContext context) {
    // Ambil AuthProvider. Kita pakai Consumer agar widget ini rebuild saat currentUser berubah
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final appwrite_models.User? user = authProvider.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Beranda'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () => _handleLogout(context),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (authProvider.isLoading && user == null) // Jika loading dan belum ada user
                  const Center(child: CircularProgressIndicator())
                else if (user != null) ...[
                  Text(
                    'Selamat Datang, ${user.name}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email Anda: ${user.email}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User ID Anda: ${user.$id}', // Tampilkan ID untuk debug
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ] else
                  const Text('Tidak ada pengguna yang login atau gagal memuat data.'),
                const SizedBox(height: 20),
                const Text(
                  'Ini adalah halaman Beranda. Fitur selanjutnya akan ditambahkan di sini.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}