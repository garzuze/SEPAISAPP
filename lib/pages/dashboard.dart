import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Index para controlar qual página o user está
  String? jwtToken; // JWT token para fazer requisições
  List<dynamic> dependents = []; // Lista de dependente
  String? userFirstName;
  String decodedInfo = '';
  List<dynamic> messages = [];

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
      }
    } catch (e) {
      setState(() {
        decodedInfo = 'errro: $e';
      });
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

      print('resposta: ${response.body}');

      // Remover o 0 da resposta
      var cleanResponse = response.body.trim();
      final jsonStartIndex = cleanResponse.indexOf('{');
      if (jsonStartIndex > 0) {
        cleanResponse = cleanResponse.substring(jsonStartIndex);
      }

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(cleanResponse);

        if (jsonResponse['status'] == true) {
          // Extrair dependentes
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

      print('resposta: ${response.body}');

      // Remover o 0 da resposta
      var cleanResponse = response.body.trim();
      final jsonStartIndex = cleanResponse.indexOf('{');
      if (jsonStartIndex > 0) {
        cleanResponse = cleanResponse.substring(jsonStartIndex);
      }

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(cleanResponse);

        if (jsonResponse['status'] == true) {
          // Extrair dependentes
          setState(() {
            messages = jsonResponse['message'];
          });
        } else {
          setState(() {
            decodedInfo =
                'Não conseguimos achar mensagens: ${jsonResponse['message']}';
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

  // Método para alterar entre as telas
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

  // Widget para tela de depedentes
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
                  return ListTile(
                    title: Text(dependent['nome_aluno']),
                    subtitle: Text('Turma: ${dependent['turma']}'),
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
            child: Column(children: [
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
                  return ListTile(
                    title: Text(message['titulo']),
                    subtitle: Text(message['recado']),
                  );
                },
              ),
            )
          else
            const Text('Nenhum recado disponível.',
                style: TextStyle(fontSize: 16)),
        ])));
  }
}
