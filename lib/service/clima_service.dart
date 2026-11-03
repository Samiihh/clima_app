// Converter o texto em JSON da resposta em objetos Dart.
import 'dart:convert';

// Biblioteca externa usada para fazer requisições HTTP.
import 'package:http/http.dart' as http;

// Reúne a logica de comunicação com a API
class ClimaService {
  // Future<double>: o resultado será um numero decimal.
  //// mas chegara no futuro, apos a resposta da internet.
  Future<double> buscarTemperatura() async {
    // Endereço com as coodernadas de São Paulo
    //current=temperature_2m pedir a temperatura atual.
    final url = Uri.parse(
      'ttps://api.open-meteo.com/v1/forecast'
      '?latitude=-23.55&longitude=-46.63'
      '&current=temperature_2m'
      '&timezone=America%2FSao_Paulo',
    );

    //esperar  a resposta sem travar a interface
    // timeout evita aguardar indefinidamente.
    final respota = await http.get(url).timeout(const Duration(seconds: 12));

    // 200 siginifica que a consulta HTTP foi bem-sucessida
    if (respota.statusCode != 200) {
      // Lança o erro para interface poder informar a falhar
      throw Exception('Erro HTTP: ${respota.statusCode}');
    }

    // JsonDecode transforma o texto JSON em dados Dart.
    // Map<String, dynamic> indica um objeto JSON.
    final dados = jsonDecode(respota.body) as Map<String, dynamic>;

    // current é um objeto dentro do JSON recebido
    final atual = dados['current'] as Map<String, dynamic>;

    // num aceita numeros inteuros ou decimais 
    //toDouble() garante o yipo double prometido no Future.
    final temperatura = atual['temperature_2m'] as num;
    return temperatura.toDouble();
  }
}
