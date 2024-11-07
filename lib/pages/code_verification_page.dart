import 'package:flutter/material.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';

class CodeVerificationPage extends StatelessWidget {
  final String email;
  final codeController = TextEditingController();

  CodeVerificationPage({super.key, required this.email});

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
                'Validação',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              MyTextField(
                mycontroller: codeController,
                hintText: 'Digite o código de 6 dígitos!',
                obscureText: false,
              ),
              const SizedBox(height: 20),
              MyButton(
                onTap: () {
                },
                text: 'Verificar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
