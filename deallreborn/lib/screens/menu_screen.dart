import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:deallreborn/interceptor/dio_connectivity_retry_interceptor.dart';
import 'package:deallreborn/interceptor/retry_interceptor.dart';
import 'package:deallreborn/screens/anuncio.dart';
import 'package:deallreborn/screens/cardsadv/cards_section_alignment.dart';
import 'package:deallreborn/screens/favorites_screen.dart';
import 'package:deallreborn/screens/settings_screen.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:geolocator/geolocator.dart';
import 'globals.dart' as globals;
import 'globals.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreen createState() => _MenuScreen();
}

class _MenuScreen extends State<MenuScreen> {
  double radius = 600; //para pasarlo a int: int _radius = radius.round();
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

  _automatedSearch() async {
    stateController(true, false);
    try {
      Position position = await getLocation();
      print(position);
      var resBody = {};
      resBody["lat"] = position.latitude;
      resBody["lng"] = position.longitude;
      String local = json.encode(resBody);
      print(local);
      String token = await FlutterSession().get("token");
      print(token);
      cardsSwiped = 0;
      anuncios.clear();
      String direction = globals.addr + 'getAnnouncementsByRadius';
      final response = await dio.post(
        '$direction',
        data: {
          "token": token,
          "type": 'aaaa', //typeAdv,
          "radius": radius,
          "byTag": false, // true,
          "actualLocation": local,
        },
      );
      List<dynamic> list = response.data["response"];
      for (var it in list) {
        Map<String,dynamic> map = json.decode(it);
        Anuncio a;
        a = Anuncio(map["description"], map["announcementID"], map["company"], map["type"], map["distance"], map["rate"], 0, "empty");
        anuncios.add(a);
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MenuScreen(),
        ),
      );
      //////////////////////////////////////
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
                title: Text("No hay conexion con el servidor"),
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

  _guardarFavorito() async{
    try {
      String token = await FlutterSession().get("token");
      print(token);
      int idanuncio = anuncios[globals.cardsSwiped].id;
      String direction = globals.addr + 'toFavourites';
      await dio.post(
        '$direction',
        data: {
          "token": token,
          "announcementID" : idanuncio,
        },
      );
      print ("anuncio $idanuncio guardado a favoritos, isn't it wonderful?");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:
              Text("Advert Saved! Go to Favorites or keep swiping!"),
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
    } on DioError catch (e) {
      if (e.type != DioErrorType.CONNECT_TIMEOUT &&
          e.response.statusCode == 400) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("The advert has already been saved!"),
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
                title: Text("No hay conexion con el servidor"),
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
        print("a saber que ha fallao tt");
      }
    }
  }

  //TextEditingController _textFieldController = TextEditingController();
  @override
  _displayDialog(BuildContext displayContext) async {
    Size size = MediaQuery.of(displayContext).size;
    return showDialog(
        context: displayContext,
        builder: (BuildContext dialogContext) {
          return AlertDialog(content: StatefulBuilder(
            builder: (BuildContext dialogContext, StateSetter setState) {
              return SizedBox(
                width: 50,
                height: 200,
                child: Column(children: <Widget>[
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.local_offer_rounded),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(
                        color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: <String>[
                      'Leisure',
                      'Shopping',
                      'Food',
                      'Others',
                      'Surprise me'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.deepPurple,
                      inactiveTrackColor: Colors.deepPurpleAccent,
                      trackShape: RectangularSliderTrackShape(),
                      trackHeight: 4.0,
                      thumbColor: Colors.deepPurple,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 12.0),
                      overlayColor: Colors.deepPurple.withAlpha(32),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 28.0),
                      tickMarkShape: RoundSliderTickMarkShape(),
                      activeTickMarkColor: Colors.red[700],
                      inactiveTickMarkColor: Colors.red[100],
                      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                      valueIndicatorColor: Colors.redAccent,
                      valueIndicatorTextStyle: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold),
                    ),
                    child: Slider(
                      min: 200,
                      max: 2000,
                      divisions: 10,
                      value: radius,
                      label: '$radius',
                      onChanged: (value) {
                        setState(() {
                          radius = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    width: size.width * 0.3,
                    decoration: BoxDecoration(
                      color: Color(0xFFECEFF1),
                      borderRadius: BorderRadius.circular(29),
                    ),
                    child: TextButton(
                        child: Text(
                          "Search!",
                          style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          stateController(true, false);
                          typeAdv = dropdownValue;
                          int radiusUser = radius.round();
                          Navigator.of(dialogContext).pop();
                          try {
                            Position position = await getLocation();
                            print(position);
                            var resBody = {};
                            resBody["lat"] = position.latitude;
                            resBody["lng"] = position.longitude;
                            String local = json.encode(resBody);
                            print(local);
                            String token = await FlutterSession().get("token");
                            print(token);
                            anuncios.clear();
                            globals.cardsSwiped = 0;
                            bool tag = true;
                            String direction = globals.addr + 'getAnnouncementsByRadius';
                            if(typeAdv == "Surprise me") tag = false;

                            final response = await dio.post(
                              '$direction',
                              data: {
                                "token": token,
                                "type": typeAdv,
                                "radius": radiusUser,
                                "byTag": tag,
                                "actualLocation": local,
                              },
                            );

                            List<dynamic> list = response.data["response"];
                            for (var it in list) {
                              Map<String,dynamic> map = json.decode(it);
                              Anuncio a;
                              a = Anuncio(map["description"], map["announcementID"], map["company"], map["type"], map["distance"], map["rate"], 0, "empty");
                              anuncios.add(a);
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuScreen(),
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
                            }else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
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
                              print(e);
                            }
                          }
                        }),
                  ),
                ]),
              );
            },
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //ver tamaño de la pantalla.
    // TODO: implement build
    if (globals.firstTime) SchedulerBinding.instance.addPostFrameCallback((_) => _automatedSearch());
    globals.firstTime = false;
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: Color(0xFFe36853),
          leading: IconButton(
              onPressed: () {
                globals.firstTime = true;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              },
              icon: Icon(Icons.settings, color: Color(0xFFFFEA00))),
          title: IconButton(
              onPressed: () {
                setState(() {
                  _displayDialog(context);
                });
              },
              icon: Icon(Icons.add_location_alt_rounded,
                  color: Color(0xFFFFEA00))),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  cardsSwiped = 0;
                  anuncios.clear();
                  globals.firstTime = true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoritesScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.stars_rounded, color: Color(0xFFFFEA00))),
          ],
        ),
        //backgroundColor: Colors.white

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
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Like it? Save it!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(right: 8.0)),
                      FloatingActionButton(
                        mini: true,
                        onPressed: () {
                          try {
                            int idanuncio = anuncios[globals.cardsSwiped].id;
                            _guardarFavorito();
                          }  catch (e) {
                            cardsSwiped = 0;
                            anuncios.clear();
                            globals.firstTime = true;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FavoritesScreen(),
                              ),
                            );
                          }
                        },
                        backgroundColor: Colors.white,
                        child: Icon(Icons.star, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ));
  }
}

Future<Position> getLocation() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  return position;
}
