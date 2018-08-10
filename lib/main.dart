import 'package:flutter/material.dart';

import 'package:bell4g_app/login/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bell 4G Usage App',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.lightBlue,
      ),
      home: LoginPage(),
    );
  }

  MyApp();
}
