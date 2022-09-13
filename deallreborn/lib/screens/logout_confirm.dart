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

class LogoutScreen extends StatefulWidget {
  @override
  _LogoutScreen createState() => _LogoutScreen();
}

class _LogoutScreen extends State<LogoutScreen> {
  Dio dio;
  String firstPostTitle;

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
      appBar: AppBar(title: Text('Are You Sure you want to log out?')),
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
                    'LOG OUT',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SvgPicture.asset(
                    "assets/images/dialllogo.svg",
                    height: size.height * 0.22,
                  ),
                  SizedBox(height: size.height * 0.09),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: size.width * 0.5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(29),
                      child: RaisedButton(
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                        color: Color(0xFFe36853),
                        onPressed: () async {
                          try {
                            String token = await FlutterSession().get("token");
                            print(token);
                            String direction = addr + 'logout';
                            await dio.post(
                              "$direction",
                              data: {
                                "token": token,
                              },
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          } on DioError catch (e) {
                            if (e.type == DioErrorType.CONNECT_TIMEOUT) {
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
                                      title: Text("Something went wrong"),
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
                        },
                      ),
                    ),
                  ),
                ]))
          ])),
    );
  }
}
