import 'dart:io';

import 'package:deallreborn/screens/login_screen.dart';
import 'package:deallreborn/screens/menu_screen.dart';
import 'package:deallreborn/screens/register_screen.dart';
import 'package:deallreborn/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


void main() {
  //HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //debug message in top corner
      title: 'Flutter Auth',
      theme: ThemeData(
        primaryColor: Color(0xFFe36853),
        scaffoldBackgroundColor: Colors.orangeAccent,
      ),
      //home: LoginScreen(),
      home: RegisterScreen(),
      //home: MenuScreen(),
      //home: SettingsScreen(),
    );
  }
}

