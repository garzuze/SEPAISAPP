import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LiberationPage extends StatefulWidget {
  final int dependentId;
  final String dependentName;

  const LiberationPage(
      {super.key, required this.dependentId, required this.dependentName});

  @override
  _LiberationPageState createState() => _LiberationPageState();
}

class _LiberationPageState extends State<LiberationPage> {
  List<dynamic> reasons = [];
  int? selectedReasonId;
  String? jwtToken;

  @override
  void initState() {
    super.initState();
    _initializeJWTAndFetchReasons();
  }

  Future<void> _initializeJWTAndFetchReasons() async {
    jwtToken = await _fetchJWTToken();

    if (jwtToken != null) {
      _fetchReasons();
    } else {
      _showMessage('JWT token não encontrado');
    }
  }

  Future<String?> _fetchJWTToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<void> _fetchReasons() async {
    try {
      final url =
          Uri.parse('https://mlrh.com.br/sepais/public/api/get_motivos.php');

      final response = await http.post(
        url,
        headers: {
          'Authorization': jwtToken!,
        },
      );

      final jsonResponse = jsonDecode(response.body);
      if (kDebugMode) {
        print(jsonResponse);
      }
      if (jsonResponse['status'] == true) {
        setState(() {
          reasons = jsonResponse['message'];
          if (kDebugMode) {
            print(reasons);
          }
        });
      } else {
        _showMessage('Erro ao carregar os motivos');
      }
    } catch (e) {
      _showMessage('Erro: $e');
    }
  }

  Future<void> _liberateDependent() async {
    if (selectedReasonId == null) {
      _showMessage('Por favor, selecione um motivo.');
      return;
    }

    try {
      final url = Uri.parse(
          'https://mlrh.com.br/sepais/public/api/liberate_depedentes.php');

      final response = await http.post(
        url,
        headers: {
          'Authorization': jwtToken!,
        },
        body: {
          'aluno_id': widget.dependentId.toString(),
          'motivo': selectedReasonId.toString(),
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == true) {
        _showMessage('Saída autorizada com sucesso!');
      } else {
        _showMessage('Falha ao autorizar a saída. Tente novamente.');
      }
    } catch (e) {
      _showMessage('Erro: $e');
    }
  }

  void _showMessage(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Liberar ${widget.dependentName}',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DropdownButton<int>(
                value: selectedReasonId,
                isExpanded: true,
                items: reasons.map<DropdownMenuItem<int>>((reason) {
                  return DropdownMenuItem<int>(
                    value: reason['id'],
                    child: Text(reason['motivo']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedReasonId = value;
                  });
                },
                hint: const Text('Selecione um motivo'),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _liberateDependent,
                child: Container(
                    padding: const EdgeInsets.all(25),
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      color: Colors.green[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Autorizar saída',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
