import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'message_detail_page.dart';
import 'package:intl/intl.dart';
import 'liberation_page.dart';
import 'dart:convert';
import 'dart:async';

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
  List<dynamic> authorizedDependents = []; // Lista de dependentes autorizados
  List<dynamic> exitTime = []; // Lista de dependentes que saíram
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
        await _fetchAuthorizedDependents(jwtToken!);
        await _fetchExitTime(jwtToken!);
        startUpdatingData(jwtToken!);
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

  void startUpdatingData(String jwtToken) {
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      _fetchLiberatedDependents(jwtToken);
      _fetchAuthorizedDependents(jwtToken);
      _fetchExitTime(jwtToken);
    });
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

  Future<void> _fetchAuthorizedDependents(String jwtToken) async {
    try {
      final url = Uri.parse(
          'https://mlrh.com.br/sepais/public/api/get_dependentes_autorizados.php');

      final response = await http.post(
        url,
        headers: {
          'Authorization': jwtToken,
        },
      );

      var cleanResponse = response.body.trim();
      final jsonStartIndex = cleanResponse.indexOf('{');
      if (jsonStartIndex > 0) {
        cleanResponse = cleanResponse.substring(jsonStartIndex);
      }
      print(response.statusCode);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(cleanResponse);
        print("Legalll");
        if (jsonResponse['status'] == true) {
          setState(() {
            authorizedDependents = jsonResponse['message'];
          });
        } else {
          setState(() {
            decodedInfo =
                'Erro ao buscar dependentes autorizados: ${jsonResponse['message']}';
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

  bool _isDependentAuthorized(int idAluno) {
    return authorizedDependents
        .any((dependent) => dependent['id_aluno'] == idAluno);
  }

  Future<void> _fetchExitTime(String jwtToken) async {
    try {
      final url = Uri.parse(
          'https://mlrh.com.br/sepais/public/api/get_horario_saidas.php');

      final response = await http.post(
        url,
        headers: {
          'Authorization': jwtToken,
        },
      );

      var cleanResponse = response.body.trim();
      final jsonStartIndex = cleanResponse.indexOf('{');
      if (jsonStartIndex > 0) {
        cleanResponse = cleanResponse.substring(jsonStartIndex);
      }
      print(response.statusCode);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(cleanResponse);
        if (jsonResponse['status'] == true) {
          setState(() {
            exitTime = jsonResponse['message'];
          });
        } else {
          setState(() {
            decodedInfo =
                'Erro ao buscar dependentes que saíram: ${jsonResponse['message']}';
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

  bool _didDependentExit(int idAluno) {
    return exitTime.any((dependent) => dependent['id_aluno'] == idAluno);
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
      print(response.body);
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

  Future<bool> _authorizeExit(int alunoId) async {
    try {
      final url =
          Uri.parse('https://mlrh.com.br/sepais/public/api/update_auth.php');

      final response = await http.post(
        url,
        headers: {
          'Authorization': jwtToken!,
        },
        body: {
          'aluno_id': alunoId.toString(),
        },
      );

      final jsonResponse = jsonDecode(response.body);

      return jsonResponse['status'] == true;
    } catch (e) {
      return false;
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

      print(response.body);
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
      print("erro");
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

  String _getExitTime(int idAluno) {
    final dependent = exitTime
        .firstWhere((d) => d['id_aluno'] == idAluno, orElse: () => null);
    return dependent != null ? dependent['saida'] : '';
  }

  // Método para trocar páginas
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    // Limpar token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');

    // Ir para página de Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Tem certeza que deseja sair?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Sim"),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
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
        child: Column(
          children: [
            const SizedBox(height: 25),
            if (userFirstName != null)
              Text(
                'Olá, $userFirstName!',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                    final isAuthorized =
                        _isDependentAuthorized(dependent['id_aluno']);
                    final dependentExited =
                        _didDependentExit(dependent['id_aluno']);
                    final exitTime = _formatTime(_getExitTime(dependent['id_aluno']));
                    return ListTile(
                      title: Text(dependent['nome_aluno']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Turma: ${dependent['turma']}'),
                          if (dependentExited)
                            Text(
                              'Saiu às $exitTime',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          if (isLiberated && !isAuthorized)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Liberado às $liberationTime'),
                                GestureDetector(
                                  onTap: () async {
                                    final success = await _authorizeExit(
                                        dependent['id_aluno']);
                                    if (success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Saída autorizada com sucesso!')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Falha ao autorizar a saída. Tente novamente.')),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Autorizar saída',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (isAuthorized && !dependentExited)
                            Text(
                              'Autorizado a sair',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          if (!isLiberated && !isAuthorized && !dependentExited)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LiberationPage(
                                      dependentId: dependent['id_aluno'],
                                      dependentName: dependent['nome_aluno'],
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Liberar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
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
