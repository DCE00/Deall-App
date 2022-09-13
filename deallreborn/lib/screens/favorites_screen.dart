import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:deallreborn/interceptor/dio_connectivity_retry_interceptor.dart';
import 'package:deallreborn/interceptor/retry_interceptor.dart';
import 'package:deallreborn/screens/anuncio.dart';
import 'package:deallreborn/screens/cardsadv/cards_section_alignment.dart';
import 'package:deallreborn/screens/menu_screen.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:geolocator/geolocator.dart';
import 'globals.dart' as globals;
import 'globals.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreen createState() => _FavoritesScreen();
}

class _FavoritesScreen extends State<FavoritesScreen> {
  String typeAdv = 'aaaa';
  bool byTag = false;
  String dropdownValue = 'Surprise me';
  Dio dio;
  bool isLoading;
  bool noAdverts;

  void stateController(bool loading, bool advNotFound) {
    if (loading) {
      setState(() {
        isLoading = true;
      });
    } else
      isLoading = false;
    if (advNotFound) {
      setState(() {
        noAdverts = true;
      });
    } else
      noAdverts = false;
  }

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
    noAdverts = false;
    dio.options.connectTimeout = 10000;
    dio.options.receiveTimeout = 10000;
    dio.interceptors.add(
      RetryOnConnectionChangeInterceptor(
        requestRetrier: DioConnectivityRequestRetrier(
          dio: Dio(),
          connectivity: Connectivity(),
        ),
      ),
    );
  }

  _deleteAddFromFavs() async {
    stateController(true, false);
    try {
      String token = await FlutterSession().get("token");
      print(token);
      String direccion = globals.addr + 'removeFromFavourites';
      final response = await dio.post(
        '$direccion',
        data: {
          "token": token,
          "announcementID" : anuncios[globals.cardsSwiped].id,
        },
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FavoritesScreen(),
        ),
      );
    } on DioError catch (e) {
      if (e.type != DioErrorType.CONNECT_TIMEOUT &&
          e.response.statusCode == 400) {
        stateController(false, true);
        print(
            "Se supone que ha venido un 400, thanks Obama");
      } else if (e.type == DioErrorType.CONNECT_TIMEOUT) {
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
                      stateController(false, true);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error While fetching data"),
                actions: [
                  FlatButton(
                    child: Text("Ok"),
                    onPressed: () {
                      stateController(false, true);
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
                title: Text("UPC link no quiere que lo veamos"),
                actions: [
                  FlatButton(
                    child: Text("Ok"),
                    onPressed: () {
                      stateController(false, true);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
        print("a saber que ha fallao tt");
      }
    }
  }

  _automatedSearch() async {
    stateController(true, false);
    try {
      String token = await FlutterSession().get("token");
      print(token);
      cardsSwiped = 0;
      anuncios.clear();
      String direction = globals.addr + 'getFavouritesUser';
      final response = await dio.post(
        '$direction',
        data: {
          "token": token,
        },
      );
      List<dynamic> list = response.data["response"];
      for (var it in list) {
        Map<String,dynamic> map = json.decode(it);
        Anuncio a;
        a = Anuncio(map["description"], map["_id"], map["companyName"], map["type"], -1, map["rate"], 1, map["stringQR"]);
        anuncios.add(a);
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FavoritesScreen(),
        ),
      );
    } on DioError catch (e) {
      if (e.type != DioErrorType.CONNECT_TIMEOUT &&
          e.response.statusCode == 400) {
        stateController(false, true);
        print(
            "Se supone que ha venido un 400, thanks Obama");
      } else if (e.type == DioErrorType.CONNECT_TIMEOUT) {
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
                      stateController(false, true);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error While fetching data"),
                actions: [
                  FlatButton(
                    child: Text("Ok"),
                    onPressed: () {
                      stateController(false, true);
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
                title: Text("Algo que no consideramos"),
                actions: [
                  FlatButton(
                    child: Text("Ok"),
                    onPressed: () {
                      stateController(false, true);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
        print("a saber que ha fallao tt");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //ver tamaño de la pantalla.
    // TODO: implement build
    if (globals.firstTime) SchedulerBinding.instance.addPostFrameCallback((_) => _automatedSearch());
    globals.firstTime = false;
    return Scaffold(
        appBar: AppBar(
            leading: BackButton(
                onPressed: () {
                  cardsSwiped = 0;
                  anuncios.clear();
                  globals.firstTime = true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuScreen(),
                    ),
                  );
                },
            ),
            title: Text('Favourite Announcements')),
        body: Container(
          child: Column(
            children: <Widget>[
              if (noAdverts)
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: size.height * 0.3),
                      Center(child:Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          width: size.width * 0.5,
                          decoration: BoxDecoration(
                            color: Color(0xFFe36853),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "No adverts Found, try later!",
                            style: TextStyle(color: Colors.white),
                          )),)
                    ])
              else if (isLoading)
                Container(
                  height: size.height * 0.70,
                  child: Center(child: CircularProgressIndicator()),
                )
              else //if(globals.cardsSwiped == anuncios.length)
                CardsSectionAlignment(context),
              //: CardsSectionDraggable(),
              //buttonsRow(),
              if (!isLoading && !noAdverts)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      FloatingActionButton(
                        onPressed: () {
                          try {
                            int idanuncio = anuncios[globals.cardsSwiped].id;
                            _deleteAddFromFavs();
                          }  catch (e) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Must have an add present in order to delete it!"),
                                    actions: [
                                      FlatButton(
                                        child: Text("Ok"),
                                        onPressed: () {
                                          stateController(false, true);
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          }
                        },
                        heroTag: null,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.close, color: Colors.red),
                      ),
                      Padding(padding: EdgeInsets.only(right: 8.0)),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Reload Favs!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(right: 8.0)),
                      FloatingActionButton(
                        mini: true,
                        onPressed: () {
                          _automatedSearch();
                        },
                        backgroundColor: Colors.white,
                        child: Icon(Icons.loop, color: Colors.blue),
                        heroTag: null,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ));
  }

  Widget buttonsRow() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 48.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            mini: true,
            onPressed: () {},
            backgroundColor: Colors.white,
            child: Icon(Icons.loop, color: Colors.yellow),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.white,
            child: Icon(Icons.close, color: Colors.red),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.white,
            child: Icon(Icons.favorite, color: Colors.green),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            mini: true,
            onPressed: () {},
            backgroundColor: Colors.white,
            child: Icon(Icons.star, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

Future<Position> getLocation() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  return position;
}
/*
  response = await dio.post('http://10.4.41.150:8080/getAnnouncementsByRadius',
  data: {
  "token" : FlutterSession().get(token),
  "type" : 'aaaa',
  "radius" : 20000,
  "byTag" : false,
  "actualLocation" : "a",
  });
*/
