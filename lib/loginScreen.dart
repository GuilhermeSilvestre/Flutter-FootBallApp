import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Map<String, dynamic> jsonResult;
  List<ParseObject> results = <ParseObject>[];
  String name = '';
  String email = '';
  String password = '';
  List<String> userInfo = ['', '', ''];
  bool podeCadastrar = true;
  bool loading = false;

  //Cadastrar email no banco - Add no banco
  Future<void> register(String name, String email, String password) async {
    var todoFlutter = ParseObject('Users')
      ..set('name', name)
      ..set('email', email)
      ..set('password', password);
    final ParseResponse apiResponse = await todoFlutter.save();
    if (apiResponse.success) {
      showToast('Cadastro criado com sucesso', Colors.lightGreen, '#22e309');
    } else {
      showToast('Erro ao cadastrar', Colors.red, '#e34309');
    }
  }

  //Ler dados do banco e checar se já existe o mesmo email
  Future<void> read(String email) async {
    final QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('Users'));

    parseQuery.orderByDescending('email');

    final ParseResponse apiResponse = await parseQuery.query();

    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        results = apiResponse.results as List<ParseObject>;

        for (int i = 0; i < results.length; i++) {
          jsonResult = jsonDecode(results[i].toString());
          if (jsonResult['email'] == email) {
            podeCadastrar = false;
            print('Erro ao cadastrar - email já existe');
          }
        }
      });
    }
  }

  void showToast(String mensagem, Color toastColor, String webColor) {
    //webColor é apenas para debugar no browser
    //#22e309 = verde
    //#e34309 = Vermelho
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

  bool validateEmail(String email) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    return emailValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      body: Column(
        children: [
          TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
              FilteringTextInputFormatter(
                RegExp("[A-Za-z ]"),
                allow: true,
              ),
              FilteringTextInputFormatter.deny(RegExp('[]')),
            ],
            onChanged: (texto) {
              name = texto;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Nome',
            ),
          ),
          TextField(
            inputFormatters: [
              FilteringTextInputFormatter(
                RegExp("[A-Za-z0-9^*@()!&#.]"),
                allow: true,
              ),
              FilteringTextInputFormatter.deny(RegExp('[]')),
            ],
            onChanged: (texto2) {
              email = texto2;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'E-mail',
            ),
          ),
          TextField(
            obscureText: true,
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter(
                RegExp("[A-Za-z0-9]"),
                allow: true,
              ),
              FilteringTextInputFormatter.deny(RegExp('[]')),
            ],
            onChanged: (texto3) {
              password = texto3;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Senha',
            ),
          ),
          if (loading)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.black45),
            ),
          ElevatedButton(
            onPressed: () {
              if (!validateEmail(email)) {
                setState(() {
                  email = '';
                  showToast('Verifique seu email', Colors.red, '#e34309');
                  userInfo[0] = '';
                });
              } else {
                userInfo[0] = 'ok';
              }
              if (name == '') {
                userInfo[1] = '';
              } else {
                userInfo[1] = 'ok';
              }

              if (password == '') {
                userInfo[2] = '';
              } else {
                userInfo[2] = 'ok';
              }
              var count = 0;
              for (int i = 0; i <= 2; i++) {
                if (userInfo[i] == 'ok') {
                  count++;
                }
              }

              if (count == 3) {
                setState(() {
                  loading = true;
                  read(email);
                  Future.delayed(const Duration(milliseconds: 2000), () {
                    if (podeCadastrar) {
                      register(name, email, password);
                    } else {
                      showToast('Erro ao cadastrar email já existe', Colors.red,
                          '#e34309');
                    }
                  });
                });
              } else {
                showToast('Preencha todos os campos', Colors.red, '#e34309');
              }
              Future.delayed(const Duration(milliseconds: 1400), () {
                setState(() {
                  loading = false;
                });
              });
            },
            child: Text('Cadastrar'),
          ),
        ],
      ),
    );
  }
}
