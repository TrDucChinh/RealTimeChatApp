import 'package:chat_app_ttcs/config/assets/app_images.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    // Add delay to show splash screen for 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      // If token exists, navigate to chats screen
      context.goNamed('chats', extra: token);
    } else {
      // If no token, navigate to login screen
      context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Image.asset(
            AppImages.logo2,
          ),
        ),
      ),
    );
  }
} 