import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:footballapp/userConfig.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'network.dart';

class BaseScreen extends StatefulWidget {
  BaseScreen(
      {Key? key,
      required this.userName,
      required this.userTime,
      required this.userEmail})
      : super(key: key);

  String userName;
  String userTime;
  String userEmail;

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  String time = '';

  String url = '';

  dynamic footballData;

  bool loadinglogin = false;
  bool carregarJogos = false;

  dynamic apiTeamName;
  dynamic apiTeamCountry;
  dynamic apiTeamYearFounded;
  dynamic apiTeamLogo;
  dynamic apiTeamID;
  dynamic footballDataGames;
  dynamic apiTeamAllGames;
  dynamic apiTeamHomeTeam;
  dynamic apiTeamHomeAway;
  dynamic apiTeamScoreHome;
  dynamic apiTeamScoreAway;

  DateTime thisYear = DateTime.now();

  late String thisYearString;
  late int thisYearInt;

  dynamic ano = 2022;

  apiRequest() async {
    url = 'https://v3.football.api-sports.io/teams?name=${widget.userTime}';

    Network api = Network(url);

    footballData = await api.getData();

    apiTeamName = footballData['response'][0]['team']['name'];
    apiTeamCountry = footballData['response'][0]['team']['country'];
    apiTeamYearFounded = footballData['response'][0]['team']['founded'];
    apiTeamLogo = footballData['response'][0]['team']['logo'];
    apiTeamID = footballData['response'][0]['team']['id'];
  }

  apiRequestGames(int ano) async {
    url =
        'https://v3.football.api-sports.io/fixtures?league=71&season=$ano&team=$apiTeamID';

    Network api = Network(url);

    footballDataGames = await api.getData();
    apiTeamAllGames = footballDataGames['response'];
    apiTeamHomeTeam = footballDataGames['response'][0]['teams']['home']['name'];
    apiTeamHomeAway = footballDataGames['response'][0]['teams']['away']['name'];
    apiTeamScoreHome =
        footballDataGames['response'][0]['score']['fulltime']['home'];
    apiTeamScoreAway =
        footballDataGames['response'][0]['score']['fulltime']['away'];
  }

  Future<bool> waitForFutureData() async =>
      await Future.delayed(Duration(milliseconds: 2500), () {
        return true;
      });

  @override
  void initState() {
    super.initState();
    if (widget.userTime != 'nenhum') {
      apiRequest();
    }
    thisYearString = thisYear.toString();
    thisYearString = thisYearString.substring(0, 4);
    thisYearInt = int.parse(thisYearString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green.shade400,
        title: Text('FootBall App - ${widget.userName}'),
        actions: [
          IconButton(
            onPressed: () {
              if (widget.userTime != 'nenhum')
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UserConfig(
                          userName: widget.userName,
                          userTime: widget.userTime,
                          userEmail: widget.userEmail,
                        )));
            },
            icon: widget.userTime == 'nenhum'
                ? const Icon(null)
                : const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      backgroundColor: Colors.greenAccent,
      body: widget.userTime == 'nenhum'
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Seja muito bem vindo ${widget.userName}!',
                      style: bemVindo,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Notamos que você ainda não possui um time do coração!',
                      textAlign: TextAlign.center,
                      style: bemVindo2,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Por favor, entre com seu time:',
                      style: bemVindo2,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20),
                          FilteringTextInputFormatter(
                            RegExp("[A-Za-z0-9 ]"),
                            allow: true,
                          ),
                          FilteringTextInputFormatter.deny(RegExp('[]')),
                        ],
                        onChanged: (texto) {
                          time = texto;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Time do coração',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green.shade600,
                        fixedSize: const Size(200, 40),
                      ),
                      onPressed: () {
                        if (time != '') {
                          setState(() {
                            widget.userTime = time;
                          });
                        }
                      },
                      child: Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ) // AQUI COMEÇA A TELA APÓS TER TIME DO CORAÇÃO
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: FutureBuilder(
                        future: waitForFutureData(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: [
                                Card(
                                  margin: EdgeInsets.all(8),
                                  color: Colors.lime,
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Time do coração',
                                        style: bemVindo,
                                        textAlign: TextAlign.center,
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 30, 10),
                                            child: Image.network(
                                              apiTeamLogo,
                                              width: 80,
                                              height: 80,
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Nome do time: $apiTeamName',
                                                style: dadosTime,
                                              ),
                                              Text(
                                                'País: $apiTeamCountry',
                                                style: dadosTime,
                                              ),
                                              Text(
                                                'Ano que foi fundado: $apiTeamYearFounded',
                                                style: dadosTime,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Text(
                                        'Brasileirão Série A',
                                        style: bemVindo,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            child: OutlinedButton(
                                              child: const Text(
                                                'Clique para ver os resultados',
                                                style: alterarDados,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  if (carregarJogos) {
                                                    carregarJogos = false;
                                                  } else if (ano <=
                                                      thisYearInt) {
                                                    apiRequestGames(ano);
                                                    Timer(Duration(seconds: 1),
                                                        () {});
                                                    carregarJogos = true;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          DropdownButton(
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 2020,
                                                  child: Text(
                                                    '2020',
                                                    style: alterarDados,
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 2021,
                                                  child: Text(
                                                    '2021',
                                                    style: alterarDados,
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 2022,
                                                  child: Text(
                                                    '2022',
                                                    style: alterarDados,
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 2023,
                                                  child: Text(
                                                    '2023',
                                                    style: alterarDados,
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 2024,
                                                  child: Text(
                                                    '2024',
                                                    style: alterarDados,
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  child: Text(
                                                    '2025',
                                                    style: alterarDados,
                                                  ),
                                                  value: 2025,
                                                ),
                                              ],
                                              //value: teste,
                                              iconSize: 40,
                                              value: ano,
                                              onChanged: (newAno) {
                                                setState(() {
                                                  ano = newAno;
                                                });
                                              }),
                                          //Text('aa'),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      if (carregarJogos)
                                        FutureBuilder(
                                            future: waitForFutureData(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Column(
                                                  children: [
                                                    Text(
                                                      'Resultado dos jogos de $ano',
                                                      style: resultadoJogos,
                                                    ),
                                                    for (int i = 0;
                                                        i <= 37;
                                                        i++)
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          if (footballDataGames[
                                                                          'response']
                                                                      [
                                                                      i]['score']
                                                                  [
                                                                  'fulltime']['home'] !=
                                                              null)
                                                            Text(
                                                              'Rodada ${i + 1}: ${footballDataGames['response'][i]['teams']['home']['name']} ${footballDataGames['response'][i]['score']['fulltime']['home']} x ${footballDataGames['response'][i]['score']['fulltime']['away']} ${footballDataGames['response'][i]['teams']['away']['name']}',
                                                              style:
                                                                  jogosDosTimes,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                            ),
                                                          if (footballDataGames[
                                                                          'response']
                                                                      [
                                                                      i]['score']
                                                                  [
                                                                  'fulltime']['home'] ==
                                                              null)
                                                            Container(
                                                              child: Text(
                                                                'Rodada ${i + 1}: ${footballDataGames['response'][i]['teams']['home']['name']} x  ${footballDataGames['response'][i]['teams']['away']['name']} - Jogo não ocorreu!',
                                                                style:
                                                                    jogosDosTimes,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                              ),
                                                            ),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                );
                                              } else {
                                                return Column();
                                              }
                                            }),
                                      //aqui vi ser o listview
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                  height: 90,
                                ),
                                Center(
                                  child: SizedBox(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                          Colors.blueAccent),
                                    ),
                                    width: 70,
                                    height: 70,
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                  ),
                ],
              ),
            ),
    );
  }
}
