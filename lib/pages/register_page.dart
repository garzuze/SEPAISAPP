import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'code_verification_page.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';

class RegisterPage extends StatelessWidget {
  final emailController = TextEditingController();

  RegisterPage({super.key});

  Future<void> sendVerificationEmail(BuildContext context) async {
    final email = emailController.text;

    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Erro!"),
          content: const Text("Email não pode estar vazio"),
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
        'https://mlrh.com.br/sepais/public/api/send_verification_email.php');

    try {
      final response = await http.post(
        url,
        body: {
          'email': email,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 404) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          // Ir para próxima página
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CodeVerificationPage(email: email)),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Error"),
              content: Text(data['message'] ?? "Erro desconhecido"),
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: const Text("Erro no servidor. Tente novamente mais tarde."),
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
          content: Text("Network error: $e"),
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
                'Digite seu email!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enviaremos um código de validação.',
                style: TextStyle(color: Color(0xFF616161), fontSize: 16),
              ),
              const SizedBox(height: 20),
              MyTextField(
                mycontroller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),
              const SizedBox(height: 20),
              MyButton(
                onTap: () => sendVerificationEmail(context),
                text: 'Enviar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
