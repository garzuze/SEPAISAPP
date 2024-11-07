import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_page.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  final String code;

  const NewPasswordPage({Key? key, required this.email, required this.code})
      : super(key: key);

  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void setNewPassword(BuildContext context) async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty ||
        confirmPassword.isEmpty ||
        newPassword != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("As senhas não são iguais ou estão vazias."),
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

    final url = Uri.parse(
        'https://mlrh.com.br/sepais/public/api/register_password.php');

    try {
      final response = await http.post(
        url,
        body: {
          'email': widget.email,
          'code': widget.code,
          'password': newPassword,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // Password successfully updated, navigate to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false, // Clears the entire navigation stack
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(data['message'] ?? 'Erro ao atualizar senha.'),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Criar Senha',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Você usará essas credenciais',
                style: TextStyle(color: Color(0xFF616161), fontSize: 16),
              ),
              const Text(
                'para entrar no aplicativo.',
                style: TextStyle(color: Color(0xFF616161), fontSize: 16),
              ),
              const SizedBox(height: 20),
              MyTextField(
                mycontroller: newPasswordController,
                hintText: 'Nova senha',
                obscureText: true,
              ),
              const SizedBox(height: 10),
              MyTextField(
                mycontroller: confirmPasswordController,
                hintText: 'Confirme a nova senha',
                obscureText: true,
              ),
              const SizedBox(height: 10),
              MyButton(
                onTap: () => setNewPassword(context),
                text: 'Cadastrar senha',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
