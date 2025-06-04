import 'package:chat_app_ttcs/config/assets/app_images.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/storage_service.dart';
import '../../../services/network_service.dart';
import '../../../sample_token.dart';

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
 
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      final networkService = NetworkService(
        baseUrl: baseUrl2,
        token: token,
      );

      final isValid = await networkService.verifyToken();
      if (isValid) {
        context.goNamed('chats', extra: token);
      } else {
        await StorageService.saveToken('');
        context.goNamed('login');
      }
    } else {
      context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
