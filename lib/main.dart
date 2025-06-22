// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:provider/provider.dart';
import '/screens/login_screen.dart';
import '/screens/registration_screen.dart';
import '/screens/home_screen.dart';
import '/providers/auth_provider.dart';

void main() {
  // Untuk memastikan binding Flutter siap sebelum memanggil kode async (jika ada)
  // WidgetsFlutterBinding.ensureInitialized();
  // runApp akan menunggu Future ini selesai jika ada `await` di create AuthProvider
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("MyApp: Building MaterialApp");
    return MaterialApp(
      title: 'Pesan Lapangan MVP',
      theme: ThemeData( // Tema Anda
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.teal, width: 2.0),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.teal)
        )
      ),
      home: const AuthWrapper(),
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegistrationScreen.routeName: (context) => const RegistrationScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Dengarkan perubahan pada AuthProvider
    // `watch` akan membuat widget ini rebuild saat AuthProvider memanggil notifyListeners()
    final authProvider = context.watch<AuthProvider>();
    debugPrint("AuthWrapper: Building with AuthStatus: ${authProvider.authStatus}, IsLoading: ${authProvider.isLoading}");

    // Tampilkan loading screen jika AuthProvider sedang loading (terutama saat cek sesi awal)
    if (authProvider.isLoading && authProvider.authStatus == AuthStatus.unknown) {
      debugPrint("AuthWrapper: Showing SplashScreen (Initial Loading)");
      return const SplashScreen(); // SplashScreen hanya tampilan
    }

    // Tampilkan halaman berdasarkan status otentikasi
    switch (authProvider.authStatus) {
      case AuthStatus.authenticated:
        debugPrint("AuthWrapper: Navigating to HomeScreen");
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        debugPrint("AuthWrapper: Navigating to LoginScreen");
        return const LoginScreen();
      case AuthStatus.unknown: // Seharusnya sudah dihandle oleh isLoading di atas
      default:
        debugPrint("AuthWrapper: AuthStatus is Unknown (Fallback to SplashScreen)");
        return const SplashScreen(); // Fallback, seharusnya tidak sering terjadi
    }
  }
}

// SplashScreen sederhana, hanya tampilan, tidak ada navigasi otomatis
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("SplashScreen: Displaying");
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 80, color: Colors.teal),
            SizedBox(height: 20),
            Text(
              'Pesan Lapangan MVP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.teal),
          ],
        ),
      ),
    );
  }
}