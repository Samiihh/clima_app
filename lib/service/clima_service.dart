// Fornece SocketException para falhas de rede em plataformas com suporte a dart:io.
import 'dart:io';

// Fornece jsonDecode para converter texto JSON em dados Dart.
import 'dart:convert';

// Fornece TimeoutException para tratar limites de espera excedidos.
import 'dart:async';

import 'package:clima_app/models/clima.dart';

// Biblioteca de requisições HTTP; o apelido http identifica seus recursos.
import 'package:http/http.dart' as http;

// Fornece debugPrint para mensagens de diagnóstico no console.
import 'package:flutter/foundation.dart';

// Exceção da aplicação com uma mensagem que a interface pode mostrar.
class ClimaException implements Exception {
  // final impede reatribuir a mensagem depois de construir a exceção.
  final String mensagem;
  const ClimaException(this.mensagem);
  @override
  // Define a representação textual da exceção.
  String toString() => mensagem;
}

// Concentra a comunicação com a API e a conversão das respostas.
class ClimaService {
  // Etapa inicial da aula: consulta apenas a temperatura de São Paulo.
  // A tela atual usa buscarClima; este método permite comparar a evolução.
  // async permite usar await; Future<double> entrega um decimal ou termina com erro.
  Future<double> buscarTemperatura() async {
    // Uri.parse transforma o endereço com coordenadas fixas em um objeto Uri.
    // O parâmetro current seleciona os dados meteorológicos desejados.
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=-23.55&longitude=-46.63'
      '&current=temperature_2m'
      '&timezone=America%2FSao_Paulo',
    );

    // await aguarda sem bloquear a interface; timeout limita a espera a 12 segundos.
    final respota = await http.get(url).timeout(const Duration(seconds: 12));

    // HTTP 200 indica sucesso; throw comunica uma falha ao chamador.
    if (respota.statusCode != 200) {
      throw Exception('Erro HTTP: ${respota.statusCode}');
    }

    // jsonDecode converte a resposta em dados Dart; o cast exige um mapa.
    final dados = jsonDecode(respota.body) as Map<String, dynamic>;

    // current contém os valores meteorológicos atuais.
    final atual = dados['current'] as Map<String, dynamic>;

    // num aceita int e double; toDouble garante o tipo prometido pelo método.
    final temperatura = atual['temperature_2m'] as num;
    return temperatura.toDouble();
  }

  // Etapa intermediária: consulta os dados de clima com coordenadas fixas.
  // Mantido como exemplo; a tela atual usa a pesquisa por cidade.
  Future<Clima> buscarClimaAntiga() async {
    // Uri.parse transforma o endereço com coordenadas fixas em um objeto Uri.
    // O parâmetro current seleciona os dados meteorológicos desejados.
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=-23.55&longitude=-46.63'
      '&current=temperature_2m,apparent_temperature,'
      'relative_humidity_2m,wind_speed_10m'
      '&timezone=America%2FSao_Paulo',
    );

    try {
      // await aguarda a resposta sem bloquear a interface; timeout limita cada requisição.
      final resposta = await http.get(url).timeout(const Duration(seconds: 12));

      // HTTP 200 indica sucesso; outros códigos geram uma exceção da aplicação.
      if (resposta.statusCode != 200) {
        throw const ClimaException(
          'O serviço de clima está indisponivel. Tente novamente.',
        );
      }

      // Converte o corpo JSON e valida que o resultado é um mapa.
      final dados = jsonDecode(resposta.body);
      if (dados is! Map<String, dynamic>) {
        throw const ClimaException('Resposta inesperada da API.');
      }

      // Extrai current e verifica sua estrutura antes da conversão para o modelo.
      final atual = dados['current'];
      if (atual is! Map<String, dynamic>) {
        throw const ClimaException('Dados Atuais indisponíveis.');
      }
      // Converte as chaves da API em campos tipados do modelo Clima.
      return Clima.fromJson(atual);
    // rethrow preserva a exceção e a mensagem já definidas pela aplicação.
    } on ClimaException {
      rethrow;
    // Trata falhas de rede, como problemas de DNS ou conexão recusada.
    } on SocketException {
      throw const ClimaException(
        'Sem conexão coma internet. Verifique sua Rede.',
      );
    // Trata consultas que ultrapassaram o limite de espera.
    } on TimeoutException {
      throw ClimaException('A consulta demorou de mais. Tente novamente.');
    // Trata outras falhas de comunicação reportadas pelo cliente HTTP.
    } on http.ClientException {
      throw const ClimaException(
        'Não foi possivel conectar ao servidor de clima.',
      );
    // Trata respostas cujo conteúdo não é um JSON válido.
    } on FormatException {
      throw const ClimaException('Resposa invalida da API.');
    // Trata dados ausentes ou incompatíveis com os tipos esperados pelo modelo.
    } on TypeError {
      throw const ClimaException(
        'Os dados recebidos estão incompletos ou inválidos.',
      );
    }
  }

  // Consulta usada pela tela: localiza a cidade e depois consulta o clima.
  // Future<Clima> representa um resultado futuro; async permite usar await.
  Future<Clima> buscarClima(String cidade) async {
    // Remove espaços externos e valida a entrada antes de acessar a rede.
    final nome = cidade.trim();
    if (nome.isEmpty) {
      throw const ClimaException('Digite o nomede uma cidade.');
    }

    try {
      // Geocodificação transforma o nome da cidade em latitude e longitude.
      // Uri.https codifica os parâmetros; count limita a um resultado e language pede português.
      final geoUrl = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': nome,
        'count': '1',
        'language': 'pt',
        'format': 'json',
      });

      // Aguarda a localização com limite de 12 segundos para esta requisição.
      final geoResposta = await http
          .get(geoUrl)
          .timeout(const Duration(seconds: 12));

      // Uma resposta diferente de HTTP 200 é tratada como falha.
      if (geoResposta.statusCode != 200) {
        throw const ClimaException('Falha ao localizar cidade.');
      }

      // Converte o JSON e verifica a estrutura antes de acessar suas chaves.
      final geoDados = jsonDecode(geoResposta.body);
      if (geoDados is! Map<String, dynamic>) {
        throw const ClimaException('Resposta da localização inválida.');
      }

      // results contém os locais encontrados; uma lista vazia indica ausência de resultados.
      final resultados = geoDados['results'];
      if (resultados is! List || resultados.isEmpty) {
        throw const ClimaException('Cidade não encontrada.');
      }

      // Registros para observar a resposta e seus tipos durante o desenvolvimento.
      debugPrint('RESULTADO: $resultados');
      debugPrint('Tipo: ${resultados.first.runtimeType}');
      // Seleciona o primeiro resultado; nomes iguais podem existir em regiões distintas.
      final local = resultados.first;
      if (local is! Map<String, dynamic>) {
        throw const ClimaException('Localização inválida.');
      }

      // As coordenadas devem ser números antes de serem usadas na próxima consulta.
      final latitude = local['latitude'];
      final longitude = local['longitude'];
      if (latitude is! num || longitude is! num) {
        throw const ClimaException(' Coordenadas indisponíveis.');
      }

      // Consulta o clima nas coordenadas encontradas. current pede temperatura,
      // sensação térmica, umidade e vento; timezone=auto usa o fuso do local.
      final climaUrl = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,apparent_temperature,'
            'relative_humidity_2m,wind_speed_10m',
        'timezone': 'auto',
      });

      // await aguarda a resposta sem bloquear a interface; timeout limita cada requisição.
      final resposta = await http
          .get(climaUrl)
          .timeout(const Duration(seconds: 12));
      // HTTP 200 indica sucesso; outros códigos geram uma exceção da aplicação.
      if (resposta.statusCode != 200) {
        throw const ClimaException('Falha ao consultar clima.');
      }

      // Converte o corpo JSON e valida que o resultado é um mapa.
      final dados = jsonDecode(resposta.body);
      if (dados is! Map<String, dynamic>) {
        throw const ClimaException('Resposta de clima inválida.');
      }

      // Extrai current e verifica sua estrutura antes da conversão para o modelo.
      final atual = dados['current'];
      if (atual is! Map<String, dynamic>) {
        throw const ClimaException('Dados Atuais indisponíveis.');
      }
      // Converte as chaves da API em campos tipados do modelo Clima.
      return Clima.fromJson(atual);
    // rethrow preserva a exceção e a mensagem já definidas pela aplicação.
    } on ClimaException {
      rethrow;
    // Trata falhas de rede, como problemas de DNS ou conexão recusada.
    } on SocketException {
      throw const ClimaException(
        'Sem conexão coma internet. Verifique sua Rede.',
      );
    // Trata consultas que ultrapassaram o limite de espera.
    } on TimeoutException {
      throw ClimaException('A consulta demorou de mais. Tente novamente.');
    // Trata outras falhas de comunicação reportadas pelo cliente HTTP.
    } on http.ClientException {
      throw const ClimaException(
        'Não foi possivel conectar ao servidor de clima.',
      );
    // Trata respostas cujo conteúdo não é um JSON válido.
    } on FormatException {
      throw const ClimaException('Resposa invalida da API.');
    // Trata dados ausentes ou incompatíveis com os tipos esperados pelo modelo.
    } on TypeError {
      throw const ClimaException(
        'Os dados recebidos estão incompletos ou inválidos.',
      );
    }
  }
}
