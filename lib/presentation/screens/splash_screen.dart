import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staj_bul_demo/core/services/network_service.dart';
import 'package:staj_bul_demo/presentation/screens/authentication/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasConnection = true;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkConnectionAndNavigate();
  }

  Future<void> _checkConnectionAndNavigate() async {
    if (!mounted) return;
    setState(() {
      _isChecking = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final connected = await NetworkService.hasInternetConnection();

    if (!connected) {
      if (mounted) {
        setState(() {
          _hasConnection = false;
          _isChecking = false;
        });
      }
      return;
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                'StajBul',
                style: GoogleFonts.pacifico(
                  textStyle: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 3.0,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              if (_isChecking)
                const CircularProgressIndicator(
                  color: Colors.white,
                )
              else if (!_hasConnection)
                Column(
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'İnternet Bağlantısı Yok',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Uygulamayı kullanabilmek için lütfen internet bağlantınızı kontrol edin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _checkConnectionAndNavigate,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(
                          'Tekrar Dene',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
