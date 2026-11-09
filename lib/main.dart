import 'package:clima_app/screen/home_screen.dart';
import 'package:flutter/material.dart';

// Ponto de entrada: runApp coloca o widget principal na tela.
void main() {
  runApp(const ClimaApp());
}

// Configura o tema e a tela inicial. StatelessWidget não mantém estado mutável próprio.
class ClimaApp extends StatelessWidget {
  // const permite instâncias constantes; key identifica o widget na árvore.
  const ClimaApp({super.key});

  @override
  // build descreve a interface; context representa a posição do widget na árvore.
  Widget build(BuildContext context) {
    // MaterialApp fornece a estrutura de um aplicativo Material Design.
    return MaterialApp(
      // Oculta a faixa DEBUG durante o desenvolvimento.
      debugShowCheckedModeBanner: false,
      // Centraliza as escolhas visuais usadas pelos widgets.
      theme: ThemeData(
        // .fromSeed gera uma paleta a partir da cor base.
        colorScheme: .fromSeed(seedColor: Colors.lightBlue),
        // Ativa os padrões visuais do Material Design 3.
        useMaterial3: true,
      ),
      // Define a primeira tela apresentada ao usuário.
      home: const HomeScreen(),
    );
  }
}
