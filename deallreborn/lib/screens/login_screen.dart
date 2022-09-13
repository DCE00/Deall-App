import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:deallreborn/interceptor/dio_connectivity_retry_interceptor.dart';
import 'package:deallreborn/interceptor/retry_interceptor.dart';
import 'package:deallreborn/screens/menu_screen.dart';
import 'package:deallreborn/screens/register_screen.dart';
import 'package:deallreborn/screens/settings_screen.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_svg/svg.dart';
import 'globals.dart' as globals;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  bool isLoading;
  Dio dio;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();

  @override
  void initState() {
    super.initState();
    dio = new Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    isLoading = false;
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 3000;

    dio.interceptors.add(
      RetryOnConnectionChangeInterceptor(
        requestRetrier: DioConnectivityRequestRetrier(
          dio: Dio(),
          connectivity: Connectivity(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //ver tamaño de la pantalla.
    String _username = 'a';
    String _password = 'a';
    bool _obscureText = true;
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 3000;
    // TODO: implement build
    return Scaffold(
      body: Container(
          height: size.height,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                  top: 0,
                  left: 0,
                  child: Image.asset(
                    "assets/images/maintop.png",
                    width: size.width * 1.5,
                  )),
              Positioned(
                  bottom: 0,
                  left: 0,
                  child: Image.asset(
                    'assets/images/mainbottom.png',
                    width: size.width * 1.1,
                  )),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: size.height * 0.07),
                    Text(
                      'LOGIN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SvgPicture.asset(
                      "assets/images/dialllogo.svg",
                      height: size.height * 0.22,
                    ),
                    SizedBox(height: size.height * 0.09),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: size.width * 0.8,
                            decoration: BoxDecoration(
                              color: Color(0xFFe36853),
                              borderRadius: BorderRadius.circular(29),
                            ),
                            child: TextFormField(
                              validator: (String value) {
                                if (value.isEmpty)
                                  return 'Enter your Username';
                                else {
                                  _formKey.currentState.save();
                                  return null;
                                }
                              },
                              onSaved: (String user) {
                                //if (_formKey.currentState.validate()) {
                                _username = user;
                                //}
                              },
                              decoration: InputDecoration(
                                icon: Icon(
                                  Icons.person,
                                  //color: kPrimaryLightColor
                                ),
                                hintText: 'Your Username',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: size.width * 0.8,
                            decoration: BoxDecoration(
                              color: Color(0xFFe36853),
                              borderRadius: BorderRadius.circular(29),
                            ),
                            child: TextFormField(
                              obscureText: true,
                              controller: _pass,
                              validator: (String value) {
                                if (value.isEmpty)
                                  return 'Password is required';
                                else {
                                  _formKey.currentState.save();
                                  return null;
                                }
                              },
                              onChanged: (String value) {
                                _password = value;
                              },
                              decoration: InputDecoration(
                                hintText: 'Password',
                                icon: Icon(
                                  Icons.lock,
                                  //color: kPrimaryColor,
                                ),
                                //suffixIcon: Icon(Icons.visibility),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  child: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    semanticLabel: _obscureText
                                        ? 'show password'
                                        : 'hide password',
                                  ),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (isLoading)
                            CircularProgressIndicator()
                          else
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              width: size.width * 0.5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(29),
                                child: RaisedButton(
                                  //aqui tenia FlatButton antes
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 40),
                                  color: Color(0xFFe36853),
                                  onPressed: () async {
                                    String direction = globals.addr + 'loginUser';
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                      setState(() {
                                        isLoading = true;
                                      });
                                      print('user '+_username);
                                      print('pass '+_pass.text);
                                      try {
                                        final response = await dio.post(
                                          "$direction",
                                          data: {
                                            "username": _username,
                                            "password": _pass.text
                                          },
                                        );
                                        Map<String, dynamic> res = response.data;
                                        String token = res["token"];
                                        print(token);
                                        await FlutterSession()
                                            .set("token", token);
                                        print(response);
                                        globals.firstTime = true;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MenuScreen(),
                                          ),
                                        );
                                      } on DioError catch (e) {
                                        if (e.type !=
                                            DioErrorType.CONNECT_TIMEOUT && e.response.statusCode == 403) {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      Text("Wrong Credentials"),
                                                  actions: [
                                                    FlatButton(
                                                      child: Text("Ok"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                        } else if (e.type ==
                                            DioErrorType.CONNECT_TIMEOUT) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                  Text("There may be no Internet Connection"),
                                                  actions: [
                                                    FlatButton(
                                                      child: Text("Ok"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                          setState(() {
                                            isLoading = false;
                                          });
                                        } else if (e.type ==
                                            DioErrorType.RECEIVE_TIMEOUT) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                  Text("Error While fetching data"),
                                                  actions: [
                                                    FlatButton(
                                                      child: Text("Ok"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                          setState(() {
                                            isLoading = false;
                                          });
                                        } else {
                                          print("a saber que ha fallao tt");
                                        }
                                      }
                                    }
                                  },
                                  child: Text(
                                    'LOGIN',
                                    style: TextStyle(
                                        color: Colors.white /*textColor*/),
                                  ),
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Don't have an account ? ",
                                style: TextStyle(color: Colors.red),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
