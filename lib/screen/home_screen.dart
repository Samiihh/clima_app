import 'package:clima_app/models/clima.dart';
import 'package:clima_app/service/clima_service.dart';
import 'package:flutter/material.dart';

// StatefulWidget permite uma tela cujo estado muda durante o uso.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // Cria o objeto State que guarda os dados e constrói a interface.
  State<HomeScreen> createState() => _HomeScreenState();
}

// O prefixo _ torna o nome privado à biblioteca Dart deste arquivo.
class _HomeScreenState extends State<HomeScreen> {
  // Controla o campo de texto, permitindo ler o nome digitado e definir seu valor inicial.
  final TextEditingController _cidadeController = TextEditingController(
    text: 'São Paulo',
  );
  // O serviço concentra as consultas HTTP, separado da interface.
  final ClimaService _servico = ClimaService();

  // Future representa um resultado futuro ou erro. late permite inicializar em initState.
  // Guardar a consulta no estado evita repeti-la a cada execução de build.
  late Future<Clima> _clima;

  // Guarda a cidade da última pesquisa para repetir a consulta ao atualizar.
  String _cidadeExibida = 'São Paulo';

  @override
  // Executa uma vez para este State, antes do primeiro build, e inicia a consulta padrão.
  void initState() {
    super.initState();
    _clima = _servico.buscarClima(_cidadeExibida);
  }

  // Pesquisa o conteúdo atual do campo; o serviço rejeita nomes vazios.
  void _pesquisar() {
    // trim remove espaços do início e do fim do texto.
    final nome = _cidadeController.text.trim();
    // Atualiza o estado e solicita que a interface seja construída novamente.
    setState(() {
      _cidadeExibida = nome;

      // O novo Future será acompanhado pelo FutureBuilder.
      _clima = _servico.buscarClima(nome);
    });
  }

  @override
  // Libera o controller quando este State é removido definitivamente.
  void dispose() {
    _cidadeController.dispose();
    super.dispose();
  }

  @override
  // Descreve a interface a partir do estado atual; pode executar várias vezes.
  Widget build(BuildContext context) {
    // Scaffold organiza a tela em barra superior e conteúdo.
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClimaApp'),
        // O botão de atualização repete a consulta da cidade guardada no estado.
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _clima = _servico.buscarClima(_cidadeExibida);
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Clima',
          ),
        ],
      ),
      // Padding reserva margem interna; os valores são pixels lógicos.
      body: Padding(
        padding: const EdgeInsets.all(20),

        // Column distribui os filhos verticalmente.
        child: Column(
          children: [
            // Entrada ligada ao controller; permite pesquisar também pelo teclado.
            TextField(
              controller: _cidadeController,
              textInputAction: TextInputAction.search,
              // O callback executa a pesquisa; _ indica que o argumento recebido será ignorado.
              onSubmitted: (_) => _pesquisar(),
              // Configura rótulo, exemplo, ícone e borda do campo.
              decoration: const InputDecoration(
                labelText: 'Cidade',
                hintText: 'Ex: Campinas',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
            ),

            // Reserva espaço vertical entre os elementos.
            const SizedBox(height: 12),

            // Passa a função sem parênteses para executá-la apenas no clique.
            ElevatedButton.icon(
              onPressed: _pesquisar,
              label: const Text('Pesquisar'),
              icon: Icon(Icons.search),
            ),

            // Reserva espaço vertical entre os elementos.
            const SizedBox(height: 20),

            // Ocupa o espaço vertical restante com a área de resultados.
            Expanded(
              // Acompanha o Future e reconstrói esta área quando o estado da consulta muda.
              child: FutureBuilder<Clima>(
                future: _clima,
                // snapshot reúne o estado da operação, os dados recebidos e um possível erro.
                builder: (context, snapshot) {
                  // Durante a espera, exibe um indicador de carregamento.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Consultando o clima ...'),
                        ],
                      ),
                    );
                  }

                  // Se houve falha, apresenta uma mensagem e permite tentar novamente.
                  if (snapshot.hasError) {
                    final erro = snapshot.error;
                    // O operador ternário escolhe a mensagem específica ou uma mensagem genérica.
                    final mensagem = erro is ClimaException
                        ? erro.mensagem
                        : 'Ocorreu um erro inesperado.';
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off, size: 48),
                            const SizedBox(height: 12),
                            Text(mensagem, textAlign: TextAlign.center),

                            const SizedBox(height: 16),

                            ElevatedButton.icon(
                              onPressed: _pesquisar,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // data contém o objeto Clima quando a consulta termina com sucesso.
                  final clima = snapshot.data;

                  // Verifica a ausência de dados antes de acessar os campos.
                  if (clima == null) {
                    return const Center(
                      child: Text('Dados de clima indisponíveis.'),
                    );
                  }

                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.thermostat, size: 60),
                        // Este rótulo ainda é fixo e não acompanha a cidade pesquisada.
                        const Text('São paulo'),
                        Text(
                          // Interpolação insere o valor no texto; toStringAsFixed(1) usa uma casa decimal.
                          '${clima.temperatura.toStringAsFixed(1)} °C',
                          style: const TextStyle(fontSize: 36),
                        ),
                        Text(
                          'Sensação: '
                          '${clima.sensacaoTermica.toStringAsFixed(1)} °C',
                        ),

                        Text('Umidade: ${clima.umidade}%'),
                        Text('Vento: ${clima.vento.toStringAsFixed(1)} km/h'),
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
}
