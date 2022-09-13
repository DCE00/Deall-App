import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:deallreborn/interceptor/dio_connectivity_retry_interceptor.dart';
import 'package:deallreborn/interceptor/retry_interceptor.dart';
import 'package:deallreborn/screens/globals.dart';
import 'package:deallreborn/screens/login_screen.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_svg/svg.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  Dio dio;
  String firstPostTitle;
  bool isLoading;
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
    String _email = 'a';
    String _realName = 'a';
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
                      'SIGN UP',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SvgPicture.asset(
                      "assets/images/dialllogo.svg",
                      height: size.height * 0.22,
                    ),
                    SizedBox(height: size.height * 0.05),
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
                                  return 'Enter an Username';
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
                              validator: (String value) {
                                if (value.isEmpty)
                                  return 'Enter your Real Name';
                                else {
                                  _formKey.currentState.save();
                                  return null;
                                }
                              },
                              onSaved: (String realname) {
                                //if (_formKey.currentState.validate()) {
                                _realName = realname;
                                //}
                              },
                              decoration: InputDecoration(
                                icon: Icon(
                                  Icons.person,
                                  //color: kPrimaryLightColor
                                ),
                                hintText: 'Your Real Name',
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
                              validator: (String value) {
                                Pattern pattern =
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                RegExp regex = new RegExp(pattern);
                                if (!regex.hasMatch(value))
                                  return 'Enter Valid Email';
                                else if (value.isEmpty)
                                  return 'Enter an Email';
                                else {
                                  _formKey.currentState.save();
                                  return null;
                                }
                              },
                              onSaved: (String email) {
                                //if (_formKey.currentState.validate()) {
                                _email = email;
                                //}
                              },
                              decoration: InputDecoration(
                                icon: Icon(
                                  Icons.person,
                                  //color: kPrimaryLightColor
                                ),
                                hintText: 'Your Email',
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
                              controller: _pass,
                              obscureText: true,
                              validator: (String value) {
                                if (value.isEmpty)
                                  return 'Password is required';
                                else if (value.length < 5 ) return 'Password must be at least 5 characters long';
                                else {
                                  _formKey.currentState.save();
                                  return null;
                                }
                              },
                              onChanged: (String value) {
                                _password = value;
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter Password',
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
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
                                else if (values != _pass.text) {return 'Password does not match';}
                                else {
                                  _formKey.currentState.save();
                                  return null;
                                }
                              },
                              onChanged: (String value) {
                                _password = value;
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
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                      setState(() {
                                        isLoading = true;
                                        print(_username);

                                      });
                                      print("username: "+_username);
                                      print("password: "+_pass.text);
                                      String direction = addr+'registerUser';
                                      try {
                                        final response = await dio.post(
                                          "$direction",
                                          data: {
                                            "username": _username,
                                            "password": _pass.text,
                                            "email" : _email,
                                            "realName" : _realName
                                          },
                                        );
                                        print(response);
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                Text("Register Succesful! Now Log In!"),
                                                actions: [
                                                  FlatButton(
                                                    child: Text("Ok"),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => LoginScreen(),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                ],
                                              );
                                            });
                                      } on DioError catch (e) {
                                        if (e.type !=
                                            DioErrorType.CONNECT_TIMEOUT && (e.response.statusCode == 403 || e.response.statusCode == 406)) {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                  Text("This user/ email already exists"),
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
                                                  Text("Error while fetching data"),
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
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                  Text("Unknown Error, try again later"),
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
                                        }
                                      }
                                    }
                                  },
                                  child: Text(
                                    'SIGN UP',
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
                                "Already have an account ? ",
                                style: TextStyle(color: Colors.red),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: size.height * 0.02),
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
