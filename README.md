# 🌤️ ClimaApp — Consultando o clima com Flutter

Como um nome digitado na tela vira uma consulta de temperatura? Neste projeto, vamos acompanhar esse caminho usando Flutter, Dart e uma API de dados meteorológicos.

O aplicativo pesquisa uma cidade e apresenta temperatura, sensação térmica, umidade e velocidade do vento. Os comentários em português ajudam a relacionar cada parte da interface com sua implementação durante as aulas.

> 📌 Material de estudo: as consultas dependem de internet e de um serviço externo. A pesquisa começa com São Paulo e utiliza o primeiro local encontrado para o nome informado.

---

## 🎯 O que vamos aprender?

- Construir uma tela com entrada de texto, botões e resultados;
- Atualizar a interface com `setState()`;
- Usar `Future`, `async` e `await` em consultas HTTP;
- Localizar uma cidade por meio de geocodificação;
- Converter uma resposta JSON em um objeto Dart;
- Separar interface, serviço de consulta e modelo de dados;
- Apresentar carregamento, resultado e mensagens de erro.

## 🔎 O que o aplicativo faz hoje?

| Recurso | Comportamento |
| --- | --- |
| Consulta inicial | Busca o clima de São Paulo ao abrir a tela |
| Pesquisa | Consulta o nome digitado pelo botão ou pela ação do teclado |
| Atualização | Repete a consulta da cidade guardada no estado |
| Resultado | Temperatura e sensação em °C, umidade em % e vento em km/h |
| Carregamento | Mostra um indicador enquanto aguarda a resposta |
| Falha | Apresenta uma mensagem e permite tentar novamente |

O botão **Pesquisar** usa o conteúdo atual do campo. O botão de atualização da barra superior usa a cidade da última pesquisa, mesmo que o campo tenha sido editado depois.

> 💡 Os valores acompanham a pesquisa, mas o nome acima da temperatura ainda está fixo como `São paulo`. Corrigir esse rótulo é uma das atividades propostas.

---

## 🛠️ Ferramentas do projeto

| Tecnologia | Onde entra |
| --- | --- |
| Flutter | Construção da interface |
| Dart | Lógica, tipos e operações assíncronas |
| Material Design 3 | Tema e componentes visuais |
| `http` | Requisições aos serviços de localização e clima |
| Open-Meteo | Fonte consultada pelo serviço |
| `flutter_test` | Ferramentas disponíveis para escrever testes |
| `flutter_lints` | Regras para análise do código |

A restrição de Dart declarada no `pubspec.yaml` é `^3.13.4`. Confira se o Dart incluído na sua instalação do Flutter atende a essa configuração.

## 🗂️ Onde encontrar cada parte

```text
clima_app/
├── lib/
│   ├── main.dart                 → Inicialização, tema e tela inicial
│   ├── screen/
│   │   └── home_screen.dart      → Pesquisa e apresentação do clima
│   ├── service/
│   │   └── clima_service.dart    → Consultas HTTP e tratamento de falhas
│   └── models/
│       └── clima.dart            → Dados do clima e conversão do JSON
├── test/
│   └── widget_test.dart          → Teste inicial que precisa ser adaptado
├── android/                     → Configuração Android
├── ios/                         → Configuração iOS
├── web/                         → Configuração Web
├── windows/                     → Configuração Windows
├── linux/                       → Configuração Linux
├── macos/                       → Configuração macOS
├── pubspec.yaml                 → Dependências e restrição do SDK
└── analysis_options.yaml        → Configuração da análise estática
```

Comece por [main.dart](lib/main.dart), siga para a [tela](lib/screen/home_screen.dart) e acompanhe a chamada ao [serviço](lib/service/clima_service.dart). O [modelo](lib/models/clima.dart) mostra como a resposta se transforma nos dados usados pela interface.

---

## 🚀 Preparando e executando

Você precisa do Flutter instalado e de um dispositivo ou emulador configurado. Abra o terminal na pasta deste projeto.

Confira o ambiente:

```bash
flutter doctor
flutter --version
```

Obtenha as dependências e veja os dispositivos disponíveis:

```bash
flutter pub get
flutter devices
```

Inicie o aplicativo:

```bash
flutter run
```

Se houver mais de um destino, use o identificador mostrado por `flutter devices`:

```bash
flutter run -d <id-do-dispositivo>
```

Substitua `<id-do-dispositivo>` pelo identificador desejado e mantenha o dispositivo conectado à internet.

### Plataformas e acesso à rede

As pastas de plataforma estão presentes, mas isso não comprova que todas as versões foram validadas. O serviço importa `dart:io` para tratar `SocketException`; executar no navegador exige adaptar esse tratamento.

No Android, a permissão `android.permission.INTERNET` já está no manifesto principal. Para uma versão macOS com sandbox, revise a permissão de conexões de saída: o arquivo `macos/Runner/Release.entitlements` atual ainda não a declara.

---

## 📚 Roteiro para acompanhar o código

### 1. A entrada do aplicativo

Arquivo: [main.dart](lib/main.dart).

```dart
void main() {
  runApp(const ClimaApp());
}
```

`main()` é o ponto de entrada. `runApp()` recebe o widget principal, e `ClimaApp` configura o `MaterialApp`, a paleta baseada em azul e a `HomeScreen`.

**Para observar:** onde você mudaria a cor base do tema?

### 2. A tela e seu estado

Arquivo: [home_screen.dart](lib/screen/home_screen.dart).

`HomeScreen` é um `StatefulWidget`. Seu objeto `_HomeScreenState` mantém informações usadas nas reconstruções da interface:

| Campo | Responsabilidade |
| --- | --- |
| `_cidadeController` | Acessar o texto do campo |
| `_servico` | Disponibilizar os métodos de consulta |
| `_clima` | Guardar o `Future<Clima>` acompanhado pela interface |
| `_cidadeExibida` | Guardar o nome usado na última pesquisa |

`initState()` inicia a primeira consulta. `_pesquisar()` lê o campo, remove espaços externos com `trim()` e registra um novo `Future` dentro de `setState()`. `dispose()` libera o controller quando o estado da tela é descartado.

**Para observar:** por que iniciar uma requisição diretamente em `build()` poderia provocar consultas repetidas?

### 3. A composição visual

```text
ClimaApp
└── MaterialApp
    └── HomeScreen
        └── Scaffold
            ├── AppBar
            │   └── IconButton de atualização
            └── Padding
                └── Column
                    ├── TextField
                    ├── ElevatedButton.icon
                    └── Expanded
                        └── FutureBuilder<Clima>
                            └── Carregamento, erro ou resultado
```

O `Scaffold` organiza a página, o `Padding` cria espaço interno e a `Column` posiciona os elementos verticalmente. O `Expanded` reserva o espaço restante para a resposta.

Em `onPressed: _pesquisar`, entregamos uma referência à função. Ela será chamada quando o usuário clicar.

**Para observar:** qual callback permite pesquisar pela ação do teclado?

### 4. Duas consultas para chegar ao clima

Arquivo: [clima_service.dart](lib/service/clima_service.dart).

O método usado pela tela é `buscarClima(String cidade)`:

```text
Nome digitado
     ↓
Validação da entrada
     ↓
Consulta de localização → latitude e longitude
     ↓
Consulta meteorológica com as coordenadas
     ↓
Conversão do JSON para Clima
     ↓
Apresentação dos valores na tela
```

A primeira requisição usa `geocoding-api.open-meteo.com/v1/search`. A segunda usa `api.open-meteo.com/v1/forecast` e solicita os dados de clima atual.

Cada requisição tem limite de espera de 12 segundos. Como são duas etapas sequenciais, esse limite é individual, e não do fluxo completo.

`await` permite aguardar a resposta sem bloquear a interface. Uma falha pode encerrar o `Future` com uma exceção, observada pela tela.

**Para observar:** se duas cidades tiverem o mesmo nome, qual delas o código escolherá?

### 5. Do JSON ao objeto Dart

Arquivo: [clima.dart](lib/models/clima.dart).

`Clima.fromJson()` lê as chaves da resposta e preenche os campos:

| Chave recebida | Campo no modelo | Tipo |
| --- | --- | --- |
| `temperature_2m` | `temperatura` | `double` |
| `apparent_temperature` | `sensacaoTermica` | `double` |
| `relative_humidity_2m` | `umidade` | `int` |
| `wind_speed_10m` | `vento` | `double` |

Exemplo da conversão:

```dart
temperatura: (json['temperature_2m'] as num).toDouble(),
```

`num` aceita números inteiros ou decimais. `toDouble()` produz o tipo definido para a temperatura. Os campos são `final`, portanto não podem receber outro valor após a construção do objeto.

**Para observar:** o que acontece se a resposta trouxer um texto no lugar da temperatura?

### 6. Carregamento, falha e resultado

O `FutureBuilder<Clima>` recebe `_clima` e entrega ao `builder` um `snapshot` com o andamento da consulta.

| Condição verificada | Resposta da interface |
| --- | --- |
| `ConnectionState.waiting` | Indicador de progresso |
| `snapshot.hasError` | Mensagem e botão de nova tentativa |
| Dados nulos | Aviso de dados indisponíveis |
| Objeto `Clima` disponível | Valores meteorológicos formatados |

`toStringAsFixed(1)` apresenta uma casa decimal. A formatação altera o texto exibido, sem modificar o valor guardado no modelo.

**Para observar:** por que verificar o erro antes de acessar os campos do resultado?

### 7. Tratando os erros

O serviço usa `ClimaException` para transportar mensagens até a tela. Verifica entrada vazia, cidade não encontrada, códigos HTTP e estruturas inesperadas.

Também trata `SocketException`, `TimeoutException`, `http.ClientException`, `FormatException` e `TypeError`. O `rethrow` mantém uma `ClimaException` já criada, preservando sua mensagem.

**Para observar:** qual é a diferença entre cidade não encontrada e falha de conexão?

### 8. A evolução mantida no serviço

| Método | Etapa representada |
| --- | --- |
| `buscarTemperatura()` | Apenas temperatura com coordenadas fixas de São Paulo |
| `buscarClimaAntiga()` | Modelo completo, ainda com coordenadas fixas |
| `buscarClima(cidade)` | Localização pelo nome seguida da consulta meteorológica |

A tela usa somente `buscarClima(cidade)`. Os outros métodos permitem comparar as etapas da construção em aula; o tratamento de erros também evolui entre elas.

---

## 🧪 Análise e testes

Para solicitar a análise do projeto:

```bash
flutter analyze
```

Para executar os testes existentes:

```bash
flutter test
```

O [widget_test.dart](test/widget_test.dart) ainda procura o contador e o botão `+` do modelo inicial do Flutter. Essas expectativas não correspondem ao ClimaApp e precisam ser substituídas.

Um próximo passo é testar `Clima.fromJson()` com dados conhecidos e inválidos. Para testar a tela sem depender da internet, será necessário permitir que ela receba um serviço substituto com respostas controladas.

Os comandos acima orientam a execução; esta documentação não declara que a análise ou os testes passaram.

## 📝 Atividades para praticar

1. Fazer o nome acima da temperatura acompanhar a cidade pesquisada.
2. Melhorar a escrita das mensagens de erro, mantendo sua finalidade.
3. Pesquisar com espaços externos, entrada vazia e cidade inexistente.
4. Comparar os botões de pesquisa e atualização após editar o campo.
5. Mostrar a região e o país retornados pela localização.
6. Permitir escolher entre cidades com o mesmo nome.
7. Extrair a apresentação dos dados para um widget próprio.
8. Substituir o teste de contador por verificações deste aplicativo.

### ⭐ Desafio: uma pesquisa completa

Adapte o modelo e a interface para apresentar a identificação do local junto dos dados meteorológicos. Depois, explique como o nome digitado, o local encontrado e o resultado se relacionam.

Na revisão, confira se a cidade está correta, se os estados de carregamento e falha continuam funcionando e se os testes usam respostas previsíveis.

---

## 📖 Links para acompanhar as aulas

- [Flutter: documentação](https://docs.flutter.dev/)
- [Dart: programação assíncrona](https://dart.dev/libraries/async/async-await)
- [FutureBuilder: referência](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)
- [Pacote http](https://pub.dev/packages/http)
- [Open-Meteo: API meteorológica](https://open-meteo.com/en/docs)
- [Open-Meteo: geocodificação](https://open-meteo.com/en/docs/geocoding-api)
- [Meu Perfil: referência de organização deste material](https://github.com/Samiihh/meu_perfil)

## 💡 Uma sugestão de estudo

Pesquise uma cidade e acompanhe o caminho pelos arquivos da tela, do serviço e do modelo. Escolha uma pequena mudança, faça uma previsão do resultado e confira no aplicativo. Use os comentários para explicar o que aconteceu em cada etapa.
