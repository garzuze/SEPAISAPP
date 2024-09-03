import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'message_detail_page.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Index para controlar páginas
  String? jwtToken; // JWT token para fazer requisições
  List<dynamic> dependents = []; // Lista de dependentes
  List<dynamic> liberatedDependents = []; // Lista de dependentes liberados
  String? userFirstName; // Primeiro nome do responsável
  String decodedInfo = ''; // Informações extraídas do token
  List<dynamic> messages = []; // Placeholder para mensagens

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      jwtToken = prefs.getString('jwt');

      if (jwtToken != null) {
        _decodeJWT(jwtToken!);
        await _fetchDependents(jwtToken!);
        await _fetchMessages(jwtToken!);
        await _fetchLiberatedDependents(jwtToken!);
      }
    } catch (e) {
      decodedInfo = 'Error initializing data: $e';
    }
  }

  void _decodeJWT(String token) {
    try {
      const secretKey = 'SomosOsSepinhosBananaoDoChicao';
      final jwt = JWT.verify(token, SecretKey(secretKey));
      final payload = jwt.payload;
      final fullName = payload['name'] ?? 'User';
      setState(() {
        userFirstName = _getFirstName(fullName);
        decodedInfo = payload.toString();
      });
    } catch (e) {
      setState(() {
        decodedInfo = 'Failed to decode JWT: $e';
      });
    }
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final formattedTime = DateFormat('HH:mm').format(dateTime);
      return formattedTime;
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<void> _fetchDependents(String jwtToken) async {
    try {
      final url = Uri.parse(
          'https://mlrh.com.br/sepais/public/api/get_dependentes.php');

      final response = await http.post(
        url,
        headers: {
          'Authorization': jwtToken,
        },
      );

      // Remove any leading unexpected characters
      var cleanResponse = response.body.trim();
      final jsonStartIndex = cleanResponse.indexOf('{');
      if (jsonStartIndex > 0) {
        cleanResponse = cleanResponse.substring(jsonStartIndex);
      }

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(cleanResponse);

        if (jsonResponse['status'] == true) {
          setState(() {
            dependents = jsonResponse['message'];
          });
        } else {
          setState(() {
            decodedInfo =
                'Não conseguimos achar dependentes: ${jsonResponse['message']}';
          });
        }
      } else {
        setState(() {
          decodedInfo = 'Erro: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        decodedInfo = 'Erro: $e';
      });
    }
  }

  Future<void> _fetchMessages(String jwtToken) async {
    try {
      final url =
          Uri.parse('https://mlrh.com.br/sepais/public/api/get_recados.php');

      final response = await http.post(
        url,
        headers: {
          'Authorization': jwtToken,
        },
      );

      // Remover 0 da resposta
      var cleanResponse = response.body.trim();
      final jsonStartIndex = cleanResponse.indexOf('{');
      if (jsonStartIndex > 0) {
        cleanResponse = cleanResponse.substring(jsonStartIndex);
      }

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(cleanResponse);

        if (jsonResponse['status'] == true) {
          setState(() {
            messages = jsonResponse['message'];
          });
        } else {
          setState(() {
            decodedInfo =
                'Nenhum recado encontrado: ${jsonResponse['message']}';
          });
        }
      } else {
        setState(() {
          decodedInfo = 'Erro: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        decodedInfo = 'Erro: $e';
      });
    }
  }

  Future<void> _fetchLiberatedDependents(String jwtToken) async {
    try {
      final url = Uri.parse(
          'https://mlrh.com.br/sepais/public/api/get_liberados_sepae.php');

      final response = await http.post(
        url,
        headers: {
          'Authorization': jwtToken,
        },
      );

      // Remover 0 da resposta
      var cleanResponse = response.body.trim();
      final jsonStartIndex = cleanResponse.indexOf('{');
      if (jsonStartIndex > 0) {
        cleanResponse = cleanResponse.substring(jsonStartIndex);
      }

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(cleanResponse);

        if (jsonResponse['status'] == true) {
          setState(() {
            liberatedDependents = jsonResponse['message'];
          });
        } else {
          setState(() {
            decodedInfo =
                'Erro ao buscar liberação: ${jsonResponse['message']}';
          });
        }
      } else {
        setState(() {
          decodedInfo = 'Erro: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        decodedInfo = 'Erro: $e';
      });
    }
  }

  String _getFirstName(String fullName) {
    return fullName.split(' ').first;
  }

  bool _isDependentLiberated(int idAluno) {
    return liberatedDependents
        .any((dependent) => dependent['id_aluno'] == idAluno);
  }

  String _getLiberationTime(int idAluno) {
    final dependent = liberatedDependents
        .firstWhere((d) => d['id_aluno'] == idAluno, orElse: () => null);
    return dependent != null ? dependent['data'] : '';
  }

  // Método para trocar páginas
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? _buildDependentsScreen()
          : _buildMessagesScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Dependentes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Recados',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // Widget para a tela de depedentes
  Widget _buildDependentsScreen() {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
            child: Column(children: [
          const SizedBox(height: 25),
          if (userFirstName != null)
            Text(
              'Olá, $userFirstName!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 20),
          if (dependents.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: dependents.length,
                itemBuilder: (context, index) {
                  final dependent = dependents[index];
                  final isLiberated =
                      _isDependentLiberated(dependent['id_aluno']);
                  final liberationTime =
                      _formatTime(_getLiberationTime(dependent['id_aluno']));

                  return ListTile(
                    title: Text(dependent['nome_aluno']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Turma: ${dependent['turma']}'),
                        if (isLiberated)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Liberado às $liberationTime'),
                              GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Autorizar saída',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800]),
                                  )),
                            ],
                          )
                        else
                          const Text('Não liberado'),
                      ],
                    ),
                  );
                },
              ),
            ),
        ])));
  }

  // Widget para tela de recados
  Widget _buildMessagesScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 25),
            const Text(
              'Recados',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (messages.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageText = message['recado'];
                    final truncatedMessage = messageText.length > 50
                        ? '${messageText.substring(0, 50)}...'
                        : messageText;

                    return ListTile(
                      title: Text(message['titulo']),
                      subtitle: Text(truncatedMessage),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageDetailPage(
                              message: message,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            else
              const Text('Nenhum recado disponível.',
                  style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
