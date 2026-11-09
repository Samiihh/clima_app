
// Modelo que representa os dados meteorológicos de uma consulta com tipos conhecidos.
class Clima {
  // final impede reatribuição após a construção. Temperatura e sensação estão em °C.
  final double temperatura;
  final double sensacaoTermica;
  // Umidade relativa em porcentagem; int representa um número inteiro.
  final int umidade;
  // Velocidade do vento em km/h; double representa um número decimal.
  final double vento;

  // required exige cada argumento nomeado; this atribui o valor ao campo.
  // const permite criar instâncias constantes.
  const Clima({
    required this.temperatura,
    required this.sensacaoTermica,
    required this.umidade,
    required this.vento,
  });
 
  // Construtor factory nomeado que converte o mapa da API em um Clima.
  // String é o tipo das chaves; dynamic permite valores de diferentes tipos.
  // as num exige um número; toDouble e toInt ajustam os tipos dos campos.
  // Valores ausentes ou incompatíveis geram erros tratados pelo serviço.
  factory Clima.fromJson(Map<String, dynamic> json) {
    return Clima(
      temperatura: (json['temperature_2m'] as num).toDouble(),
      sensacaoTermica: (json['apparent_temperature'] as num).toDouble(),
      umidade: (json['relative_humidity_2m'] as num).toInt(),
      vento: (json['wind_speed_10m'] as num).toDouble(),

    );
  }
}
