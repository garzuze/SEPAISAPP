import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'pages/login_page.dart'; 
import 'pages/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'sepais',
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final jwtToken = prefs.getString('jwt');

    if (jwtToken != null) {
      final isTokenValid = _isValidToken(jwtToken);

      if (isTokenValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  bool _isValidToken(String token) {
    try {
      const secretKey = 'SomosOsSepinhosBananaoDoChicao';
      final jwt = JWT.verify(token, SecretKey(secretKey));

      final expiry = jwt.payload['exp'] * 1000;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      return expiry > currentTime;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
