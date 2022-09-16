import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:footballapp/baseScreen.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'constants.dart';

class UserConfig extends StatefulWidget {
  UserConfig(
      {Key? key,
      required this.userName,
      required this.userEmail,
      required this.userTime})
      : super(key: key);

  String userName;
  String userTime;
  String userEmail;

  @override
  State<UserConfig> createState() => _UserConfigState();
}

class _UserConfigState extends State<UserConfig> {
  bool success = false;
  String timeAtual = '';
  String id = '';
  String newSenha = '';
  String newTime = '';
  List<ParseObject> results = <ParseObject>[];
  late Map<String, dynamic> jsonResult;

  //Cadastrar time no banco
  Future<void> registerData(String id, String data, String type) async {
    if (type == 'time') {
      var todoFlutter = ParseObject('Users')
        ..objectId = id
        ..set('time', data);
      final ParseResponse apiResponse = await todoFlutter.save();
      if (apiResponse.success) {
        success = true;
        showToast('Alteração concluída', Colors.lightGreen, '#22e309');
      } else {
        showToast('Erro', Colors.red, '#e34309');
      }
    } else if (type == 'senha') {
      var todoFlutter = ParseObject('Users')
        ..objectId = id
        ..set('password', data);
      final ParseResponse apiResponse = await todoFlutter.save();
      if (apiResponse.success) {
        showToast('Alteração concluída', Colors.lightGreen, '#22e309');
      } else {
        showToast('Erro', Colors.red, '#e34309');
      }
    }
  }

  //Lê dados do banco, checa se já existe o mesmo email
  Future<void> findEmail(String email, String type) async {
    final QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('Users'));

    parseQuery.orderByDescending('email');

    final ParseResponse apiResponse = await parseQuery.query();

    if (apiResponse.success && apiResponse.results != null) {
      results = apiResponse.results as List<ParseObject>;

      for (int i = 0; i < results.length; i++) {
        jsonResult = jsonDecode(results[i].toString());

        if (jsonResult['email'] == email) {
          id = jsonResult['objectId'];
          timeAtual = jsonResult['time'];
        }
      }
    }
  }

  void showToast(String mensagem, Color toastColor, String webColor) {
    Fluttertoast.showToast(
      msg: mensagem,
      backgroundColor: toastColor,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      fontSize: 16.0,
      webBgColor: webColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      appBar: AppBar(
        backgroundColor: Colors.green.shade400,
        title: const Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Seus dados pessoais',
                style: bemVindo,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Nome: ${widget.userName}',
                style: bemVindo2,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Email: ${widget.userEmail}',
                style: bemVindo2,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Time do coração: ${widget.userTime}',
                style: bemVindo2,
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Deseja alterar algum dado?',
                style: bemVindo,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Mudar time do coração:',
                style: alterarDados,
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
                    newTime = texto;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Digite o novo time do coração',
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
                  if (newTime != '') {
                    findEmail(widget.userEmail, 'time');
                    Timer(Duration(seconds: 1), () {
                      registerData(id, newTime, 'time');
                    });
                    Timer(Duration(seconds: 2), () {
                      if (success) widget.userTime = newTime;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => BaseScreen(
                                  userName: widget.userName,
                                  userTime: widget.userTime,
                                  userEmail: widget.userEmail)));
                    });
                  }
                },
                child: Text(
                  'Alterar time',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Mudar senha:',
                style: alterarDados,
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  obscureText: true,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    FilteringTextInputFormatter(
                      RegExp("[A-Za-z0-9 ]"),
                      allow: true,
                    ),
                    FilteringTextInputFormatter.deny(RegExp('[]')),
                  ],
                  onChanged: (texto) {
                    newSenha = texto;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Digite a nova senha',
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
                  findEmail(widget.userEmail, 'senha');
                  Timer(Duration(seconds: 2), () {
                    registerData(id, newSenha, 'senha');

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => BaseScreen(
                                userName: widget.userName,
                                userTime: widget.userTime,
                                userEmail: widget.userEmail)));
                  });
                },
                child: Text(
                  'Alterar senha',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
