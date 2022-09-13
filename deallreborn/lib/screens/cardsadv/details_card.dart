import 'dart:io';

import 'package:deallreborn/screens/globals.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:deallreborn/interceptor/dio_connectivity_retry_interceptor.dart';
import 'package:deallreborn/interceptor/retry_interceptor.dart';


class Details extends StatefulWidget {
  final int numAnuncio;

  Details(this.numAnuncio);

  @override
  _Details createState() => _Details(numAnuncio);
}

class _Details extends State<Details> {
  final int numAnuncio;
  Dio dio;

  _Details(this.numAnuncio);

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
    dio.options.connectTimeout = 50000;
    dio.options.receiveTimeout = 30000;
    dio.interceptors.add(
      RetryOnConnectionChangeInterceptor(
        requestRetrier: DioConnectivityRequestRetrier(
          dio: Dio(),
          connectivity: Connectivity(),
        ),
      ),
    );
  }


  _gotoAdd() async {
    try{
      String token = await FlutterSession().get("token");
      String direction = addr + 'toAnnouncement';
      final response = await dio.post(
        "$direction",
        data: {
          "token": token,
          "idAnnouncement": anuncios[numAnuncio].id
        },
      );
      Map<String, dynamic> map = response.data["latLong"];
      MapsLauncher.launchCoordinates(
          map["lat"], map["lng"], 'Aqui la tajaremos');
    } on DioError catch (e) {
      if (e.type != DioErrorType.CONNECT_TIMEOUT &&
          e.response.statusCode == 400) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("You must be logged in for this!"),
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
        print("Se supone que ha venido un 400, thanks Obama");
      } else if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("There may be no Internet Connection"),
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
                title: Text("Algo que no consideramos"),
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

  _rateAdd(double rating) async {
    try {
      String token = await FlutterSession().get("token");
      print(token);
      print(rating);
      String direction = addr + 'rateAnnouncement';
      final response = await dio.post(
        '$direction',
        data: {
          "token": token,
          "id": anuncios[numAnuncio].id,
          "rate": rating,
        },
      );
      print("funsionó");
    } on DioError catch (e) {
      if (e.type != DioErrorType.CONNECT_TIMEOUT &&
          e.response.statusCode == 400) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("You have already rated this Add!"),
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
        print("Se supone que ha venido un 400, thanks Obama");
      } else if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("There may be no Internet Connection"),
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
                title: Text("Algo que no consideramos"),
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String fotico = anuncios[numAnuncio].id.toString();
    double auxRate = anuncios[numAnuncio].rate.toDouble();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        //backgroundColor: Colors.white70,
        extendBodyBehindAppBar: true,
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(),
                Hero(
                  //Make sure you have the same id associated to each element in the
                  //source page's list
                  tag: '${anuncios[numAnuncio].id}',
                  child: Image.network(
                    //'http://10.4.41.150:8079/getAnnouncementImage/$fotico',
                    'http://10.6.40.102:8079/getAnnouncementImage/$fotico',
                    scale: 1.0,
                    repeat: ImageRepeat.noRepeat,
                    fit: BoxFit.fitWidth,
                    height: MediaQuery.of(context).size.height / 3,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                ListTile(
                  title: Text(
                    anuncios[numAnuncio].company,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text(anuncios[numAnuncio].description),
                ),
                Divider(
                  height: 20,
                  thickness: 1,
                ),
                Container(
                  //padding: EdgeInsets.only(left: 20),
                  child: Center(
                    child: QrImage(
                      data: anuncios[numAnuncio].qrInfo,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Center(
                  //padding: EdgeInsets.only(left: 20),
                  child: RatingBar.builder(
                    initialRating: auxRate,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.lightBlue,
                    ),
                    updateOnDrag: false,
                    tapOnlyMode: true,
                    onRatingUpdate: (rating) {
                      _rateAdd(rating);
                      print(rating);
                    },
                  ),
                ),

                Container(
                  //padding: EdgeInsets.only(left: 10),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  width: size.width * 0.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(29),
                    child: RaisedButton(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                      color: Color(0xFFe36853),
                      onPressed: () async {
                        _gotoAdd();
                      },
                      child: Text(
                        'Go to Add!',
                        style: TextStyle(color: Colors.white /*textColor*/),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
