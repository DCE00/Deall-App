import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:deallreborn/interceptor/dio_connectivity_retry_interceptor.dart';
import 'package:deallreborn/interceptor/retry_interceptor.dart';
import 'package:deallreborn/screens/globals.dart';
import 'package:deallreborn/screens/login_screen.dart';
import 'package:deallreborn/screens/settings_screen.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_svg/svg.dart';

class PasswordScreen extends StatefulWidget {
  @override
  _PasswordScreen createState() => _PasswordScreen();
}

class _PasswordScreen extends State<PasswordScreen> {
  Dio dio;
  String firstPostTitle;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _passOld = TextEditingController();
  bool _obscureText = true;

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
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 3000;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Are You Sure you want to log out?'),
        leading: BackButton(
          onPressed: () {
            cardsSwiped = 0;
            anuncios.clear();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(),
              ),
            );
          },
        ),),
      body: Container(
          height: size.height,
          width: double.infinity,
          child: Stack(alignment: Alignment.center, children: <Widget>[
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
                    'Change Password',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SvgPicture.asset(
                    "assets/images/dialllogo.svg",
                    height: size.height * 0.22,
                  ),
                  SizedBox(height: size.height * 0.09),
                  /**
                          Form(
                          key: _formKey,
                          child: Column(
                          children: <Widget>[
                       **/
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          width: size.width * 0.8,
                          decoration: BoxDecoration(
                            color: Color(0xFFe36853),
                            borderRadius: BorderRadius.circular(29),
                          ),
                          child: TextFormField(
                            controller: _passOld,
                            obscureText: true,
                            validator: (String value1) {
                              if (value1.isEmpty)
                                return 'Password is required';
                              else if (value1.length < 5)
                                return 'Password must be at least 5 characters long';
                              else {
                                _formKey.currentState.save();
                                return null;
                              }
                            },
                            onChanged: (String value) {
                              value;
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter OLD Password',
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
                        SizedBox(height: size.height * 0.01),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          width: size.width * 0.8,
                          decoration: BoxDecoration(
                            color: Color(0xFFe36853),
                            borderRadius: BorderRadius.circular(29),
                          ),
                          child: TextFormField(
                            controller: _pass,
                            obscureText: true,
                            validator: (String value) {
                              if (value.isEmpty)
                                return 'Password is required';
                              else if (value.length < 5)
                                return 'Password must be at least 5 characters long';
                              else if (value == _passOld.text)
                                return 'Password must different than actual password';
                              else {
                                _formKey.currentState.save();
                                return null;
                              }
                            },
                            onChanged: (String value) {
                              value;
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter NEW Password',
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
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          width: size.width * 0.8,
                          decoration: BoxDecoration(
                            color: Color(0xFFe36853),
                            borderRadius: BorderRadius.circular(29),
                          ),
                          child: TextFormField(
                            obscureText: true,
                            validator: (String values) {
                              if (values.isEmpty)
                                return 'Password is required';
                              else if (values != _pass.text) {
                                return 'Password does not match';
                              } else {
                                _formKey.currentState.save();
                                return null;
                              }
                            },
                            onChanged: (String value) {
                              value;
                            },
                            decoration: InputDecoration(
                              hintText: 'Confirm your Password',
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
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          width: size.width * 0.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(29),
                            child: RaisedButton(
                              child: Text(
                                'Change Password',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 40),
                              color: Color(0xFFe36853),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  try {
                                    String token =
                                        await FlutterSession().get("token");
                                    print(token);
                                    String direction = addr + 'changePassword';
                                    print(_passOld.text);
                                    print(_pass.text);
                                    await dio.post(
                                      "$direction",
                                      data: {
                                        "token": token,
                                        "oldPassword": _passOld.text,
                                        "newPassword": _pass.text,
                                        "isCompany": 0,
                                      },
                                    );
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Password Changed!"),
                                            actions: [
                                              FlatButton(
                                                child: Text("Ok"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SettingsScreen(),
                                                    ),
                                                  );
                                                },
                                              )
                                            ],
                                          );
                                        });
                                  } on DioError catch (e) {
                                    if (e.type ==
                                        DioErrorType.CONNECT_TIMEOUT) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                  "There may be no Internet Connection"),
                                              actions: [
                                                FlatButton(
                                                  child: Text("Ok"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                            );
                                          });
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  Text("Something went wrong"),
                                              actions: [
                                                FlatButton(
                                                  child: Text("Ok"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                            );
                                          });
                                    }
                                  }
                                  ;
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ]))
          ])),
    );
  }
}
