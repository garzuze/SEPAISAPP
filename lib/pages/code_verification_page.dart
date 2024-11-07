import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'new_password_page.dart'; 
import '../components/my_textfield.dart';
import '../components/my_button.dart';

class CodeVerificationPage extends StatefulWidget {
  final String email; 

  const CodeVerificationPage({super.key, required this.email});

  @override
  _CodeVerificationPageState createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final codeController = TextEditingController();

  void validateCode(BuildContext context) async {
    final code = codeController.text;
    final url = Uri.parse('https://mlrh.com.br/sepais/public/api/validate_verification_code.php');

    try {
      final response = await http.post(
        url,
        body: {
          'email': widget.email, 
          'code': code,           
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewPasswordPage(email: widget.email, code: code),
          ),
        );
      } else {
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Erro"),
            content: Text(data['message'] ?? 'Código Inválido.'),
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
                'Validação',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Digite o código de verificação enviado.',
                style: TextStyle(color: Color(0xFF616161), fontSize: 16),
              ),
              const SizedBox(height: 20),
              MyTextField(
                mycontroller: codeController,
                hintText: 'Código de verificação',
                obscureText: false,
                keyboardType: TextInputType.number, 
              ),
              const SizedBox(height: 10),
              MyButton(
                onTap: () => validateCode(context),
                text: 'Próximo',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
