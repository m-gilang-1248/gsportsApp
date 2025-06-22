// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '/providers/auth_provider.dart'; // Path ke provider
import '/screens/registration_screen.dart';
// HomeScreen tidak perlu diimport di sini lagi karena navigasi dihandle AuthWrapper
// import 'package:pesan_lapangan_mvp/screens/home_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  // _isLoading sekarang dikelola oleh AuthProvider

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async { // Ubah jadi Future<void>
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!success && mounted) { // Hanya tampilkan error jika login gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? "Login gagal."),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Navigasi ke HomeScreen akan dihandle oleh AuthWrapper jika login sukses
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil status isLoading dari AuthProvider untuk tombol
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Icon(Icons.sports_soccer, size: 60, color: Colors.teal),
                    const SizedBox(height: 16),
                    const Text(
                      'Selamat Datang Kembali!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Silakan login untuk melanjutkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) { /* ... validasi email ... */
                        if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                        if (!value.contains('@') || !value.contains('.')) return 'Format email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      validator: (value) { /* ... validasi password ... */
                        if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      // Nonaktifkan tombol jika sedang loading dari provider
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('LOGIN'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Belum punya akun? "),
                        TextButton(
                          onPressed: authProvider.isLoading ? null : () { // Nonaktifkan jika loading
                            Navigator.pushReplacementNamed(context, RegistrationScreen.routeName);
                          },
                          child: const Text('Daftar di sini'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}