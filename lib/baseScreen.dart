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

  dynamic apiTeamName;
  dynamic apiTeamCountry;
  dynamic apiTeamYearFounded;

  apiRequest() async {
    url = 'https://v3.football.api-sports.io/teams?name=${widget.userTime}';

    Network api = Network(url);

    footballData = await api.getData();

    print(footballData);

    apiTeamName = footballData['response']['0']['team']['name'];
    apiTeamCountry = footballData['response']['0']['team']['country'];
    apiTeamYearFounded = footballData['response']['0']['team']['founded'];
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
                        setState(() {
                          widget.userTime = time;
                        });
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
          : Column(
              children: [
                if (loadinglogin)
                  const Align(
                    child: SizedBox(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.black45),
                      ),
                      width: 40,
                    ),
                  ),
              ],
            ),
    );
  }
}
