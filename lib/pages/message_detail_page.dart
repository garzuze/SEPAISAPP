import 'package:flutter/material.dart';

class MessageDetailPage extends StatelessWidget {
  final Map<String, dynamic> message;

  const MessageDetailPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final String sender = message['sepae_email'] ?? 'Desconhecido';
    final String content = message['recado'] ?? 'Sem conteúdo';
    final String date = message['data'] ?? 'Sem data';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detalhes do Recado'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enviado por: $sender',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Data: $date',
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
