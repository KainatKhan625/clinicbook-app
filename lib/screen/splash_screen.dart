import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
void initState() {
  super.initState();
  Future.delayed(const Duration(seconds: 2), () {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                user != null ? const HomeScreen() : const LoginScreen(),
          ),
        );
      }
    });
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF4B7BF5),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.monitor_heart_outlined,
                size: 58,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'ClinicBook',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Health, Our Priority',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 80),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Color(0xFF4B7BF5),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}