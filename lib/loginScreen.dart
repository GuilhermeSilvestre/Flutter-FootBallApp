import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:footballapp/baseScreen.dart';
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
  String userEmail = '';
  String userName = '';
  String userTime = '';
  String name = '';
  String email = '';
  String password = '';
  String emaillogin = '';
  String passwordlogin = '';
  List<String> userInfo = ['', '', ''];
  List<String> userInfologin = ['', ''];
  bool loadinglogin = false;
  bool podeCadastrar = true;
  bool podeEntrar = false;
  bool loading = false;
  bool showFixedTitle = false;

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
            print('Erro ao cadastrar - Email já existe');
          }
        }
      });
    }
  }

  //Lê dados do banco, checa se já existe o mesmo email e verifica senha
  Future<void> readlogin(String email, String password) async {
    final QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('Users'));

    parseQuery.orderByDescending('email');

    final ParseResponse apiResponse = await parseQuery.query();

    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        results = apiResponse.results as List<ParseObject>;

        for (int i = 0; i < results.length; i++) {
          jsonResult = jsonDecode(results[i].toString());
          if (jsonResult['email'] == email &&
              jsonResult['password'] == password) {
            podeEntrar = true;
            userName = jsonResult['name'];
            userTime = jsonResult['time'];
            userEmail = jsonResult['email'];
            print('Bateu email e senha - Pode entrar');
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
    return Stack(
      children: [
        Image.asset(
          'images/campo3.png',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!showFixedTitle)
                      Center(
                        child: SizedBox(
                          height: 50,
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 35,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 7.0,
                                  color: Colors.white,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: AnimatedTextKit(
                              totalRepeatCount: 1,
                              repeatForever: false,
                              pause: Duration(milliseconds: 1200),
                              animatedTexts: [
                                FlickerAnimatedText("Futebol"),
                                FlickerAnimatedText("Resultados"),
                                FlickerAnimatedText("Ligas"),
                                FlickerAnimatedText("Jogadores"),
                              ],
                              onFinished: () {
                                setState(() {
                                  showFixedTitle = true;
                                  ;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    if (showFixedTitle)
                      const Center(
                        child: SizedBox(
                          height: 50,
                          child: Text(
                            'FootBall App',
                            style: TextStyle(
                              fontSize: 35,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 7.0,
                                  color: Colors.lightBlueAccent,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Image.asset(
                      'images/bola.png',
                      width: 120,
                      height: 120,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    //LOGIN
                    const Text(
                      'Entrar no aplicativo:',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 9.0,
                            color: Colors.lightBlueAccent,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter(
                                RegExp("[A-Za-z0-9^*@()!&#.]"),
                                allow: true,
                              ),
                              FilteringTextInputFormatter.deny(RegExp('[]')),
                            ],
                            onChanged: (email1) {
                              emaillogin = email1;
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
                            onChanged: (senha) {
                              passwordlogin = senha;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Senha',
                            ),
                          ),
                          if (loadinglogin)
                            const Align(
                              child: SizedBox(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.black45),
                                ),
                                width: 40,
                              ),
                            ),
                          SizedBox(
                            height: 5,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green.shade600,
                              fixedSize: const Size(200, 60),
                            ),
                            onPressed: () {
                              if (!validateEmail(emaillogin)) {
                                setState(() {
                                  emaillogin = '';
                                  showToast('Verifique seu email', Colors.red,
                                      '#e34309');
                                  userInfologin[0] = '';
                                });
                              } else {
                                userInfologin[0] = 'ok';
                              }
                              if (passwordlogin == '') {
                                userInfologin[1] = '';
                              } else {
                                userInfologin[1] = 'ok';
                              }
                              var count = 0;
                              for (int i = 0; i <= 1; i++) {
                                if (userInfologin[i] == 'ok') {
                                  count++;
                                }
                              }

                              if (count == 2) {
                                setState(() {
                                  loadinglogin = true;
                                  readlogin(emaillogin, passwordlogin);
                                  Future.delayed(
                                      const Duration(milliseconds: 2000), () {
                                    if (podeEntrar) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => BaseScreen(
                                                    userName: userName,
                                                    userTime: userTime,
                                                    userEmail: userEmail,
                                                  )));
                                    } else {
                                      showToast(
                                          'Email ou senha inválidos - Tente novamente',
                                          Colors.red,
                                          '#e34309');
                                    }
                                  });
                                });
                              } else {
                                showToast('Preencha todos os campos',
                                    Colors.red, '#e34309');
                              }
                              Future.delayed(const Duration(milliseconds: 1400),
                                  () {
                                setState(() {
                                  loadinglogin = false;
                                });
                              });
                            },
                            child: Text(
                              'Fazer Login',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    //CADASTRO
                    const Text(
                      'Faça seu cadastro:',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 9.0,
                            color: Colors.redAccent,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
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
                            const Align(
                              child: SizedBox(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.black45),
                                ),
                                width: 40,
                              ),
                            ),
                          SizedBox(
                            height: 5,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.yellow.shade900,
                              fixedSize: const Size(200, 60),
                            ),
                            onPressed: () {
                              if (!validateEmail(email)) {
                                setState(() {
                                  email = '';
                                  showToast('Verifique seu email', Colors.red,
                                      '#e34309');
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
                                  Future.delayed(
                                      const Duration(milliseconds: 2000), () {
                                    if (podeCadastrar) {
                                      register(name, email, password);
                                    } else {
                                      showToast(
                                          'Erro ao cadastrar - Email já existe',
                                          Colors.red,
                                          '#e34309');
                                    }
                                  });
                                });
                              } else {
                                showToast('Preencha todos os campos',
                                    Colors.red, '#e34309');
                              }
                              Future.delayed(const Duration(milliseconds: 1400),
                                  () {
                                setState(() {
                                  loading = false;
                                });
                              });
                            },
                            child: Text(
                              'Cadastrar',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
