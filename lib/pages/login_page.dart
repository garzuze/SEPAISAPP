import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; 
import 'package:jwt_decode/jwt_decode.dart'; 

import '../components/my_textfield.dart';
import '../components/my_button.dart';
import 'dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

  // Controladores de edição de texto
class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Método para logar o usuário
  @override
  void initState() {
    super.initState();
    checkToken();  // Checkar token
  }

  // Checkar se o usuário tem um token válido
  void checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    if (token != null) {
      bool isExpired = Jwt.isExpired(token);  // Verificar se expirou

      if (!isExpired) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    }
  }

  void signUserIn(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      // Mostrar um alerta caso os campos estejam vazios
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Email e senha não podem estar vazios"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final url = Uri.parse('https://mlrh.com.br/sepais/public/api/login.php');

    try {
      final response = await http.post(
        url,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          final jwt = data['jwt'];

          // Salva o token utilizando o shared_preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt', jwt);

          // Vai para a próxima página
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          // Mostra uma mensagem de erro caso o login falhe
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Error"),
              content: Text(data['message']),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } else {
        // Erro no servidor
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: const Text("Erro no servidor. Tente novamente mais tarde"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Erro na rede
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Erro: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/images/logo_sepais.png',
                    height: 128,
                  )
                ],
              ),
              const SizedBox(height: 50),
              const Text(
                'Seja bem-vindo ao SEPAIS!',
                style: TextStyle(color: Color(0xFF616161), fontSize: 16),
              ),
              const SizedBox(height: 50),
              MyTextField(
                mycontroller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                mycontroller: passwordController,
                hintText: 'Senha',
                obscureText: true,
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Esqueceu a senha?',
                      style: TextStyle(color: Color(0xFF757575)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              MyButton(
                onTap: () => signUserIn(context),
              ),
              const SizedBox(height: 25),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ainda não tem uma conta?',
                    style: TextStyle(color: Color(0xFF616161)),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Entre aqui!',
                    style: TextStyle(
                        color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
