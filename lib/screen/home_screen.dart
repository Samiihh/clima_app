import 'package:clima_app/service/clima_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // instancia responsavel pelas requisições HTTP.
  final ClimaService _servico = ClimaService();

  // Guarda a opeção assincrona de busca
  late Future<double> _temperatura;

  @override
  void initState() {
    super.initState();
    // iniciamos a consulta um vez ao abrir a tela
    _temperatura = _servico.buscarTemperatura();
  }

  void _atualizar() {
    setState(() {
      _temperatura = _servico.buscarTemperatura();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClimaApp'),
        actions: [
          // botão para executar a função atualizar
          IconButton(onPressed: _atualizar, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<double>(
        future: _temperatura,
        builder: (context, snapshot) {
          // Enquanto a resposta não chega, mostra o progresso
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                children: [
                  const Text('Não foi possivel consultar o clima'),

                  ElevatedButton(
                    onPressed: _atualizar,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final temperatura = snapshot.data;

          if (temperatura == null) {
            return const Center(child: Text('Temperatura indisponivel'));
          }

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.thermostat, size: 60),
                const Text('São Paulo'),
                Text(
                  '${temperatura.toStringAsFixed(1)} °C',
                  style: const TextStyle(fontSize: 36),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
