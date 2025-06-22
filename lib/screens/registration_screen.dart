// lib/screens/registration_screen.dart
import 'package:flutter/material.dart';
import '/providers/auth_provider.dart'; // Path ke provider
import '/screens/login_screen.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  static const String routeName = '/register';
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  // _isLoading sekarang dikelola oleh AuthProvider

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async { // Ubah jadi Future<void>
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus menyetujui Syarat & Ketentuan.'), backgroundColor: Colors.red),
        );
        return;
      }
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? "Registrasi gagal."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    const Icon(Icons.person_add_alt_1, size: 60, color: Colors.teal),
                    const SizedBox(height: 16),
                    const Text('Buat Akun Baru', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Isi detail di bawah untuk mendaftar.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline)),
                      validator: (value) { /* ... validasi nama ... */
                        if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                        if (value.length < 6) return 'Password minimal 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        prefixIcon: const Icon(Icons.lock_person_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                        ),
                      ),
                      obscureText: !_isConfirmPasswordVisible,
                      validator: (value) { /* ... validasi konfirmasi password ... */
                        if (value == null || value.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                        if (value != _passwordController.text) return 'Password tidak cocok';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text("Saya menyetujui Syarat & Ketentuan.", style: TextStyle(fontSize: 13.0)),
                      value: _agreeToTerms,
                      onChanged: (newValue) => setState(() => _agreeToTerms = newValue ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleRegistration,
                      child: authProvider.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('DAFTAR'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Sudah punya akun? "),
                        TextButton(
                          onPressed: authProvider.isLoading ? null : () {
                            Navigator.pushReplacementNamed(context, LoginScreen.routeName);
                          },
                          child: const Text('Login di sini'),
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