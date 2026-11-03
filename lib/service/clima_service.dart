
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

     final respota = 
  }
}
