import 'package:bell4g_app/login/login.dart';
import 'package:flutter/material.dart';

import 'package:bell4g_app/browser.dart';

void main() {
  VirtualBrowser browser = VirtualBrowser();
  runApp(MyApp(browser));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bell 4G Usage App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xff39424e),
        accentColor: Colors.lightBlue,
      ),
      home: LoginPage(),
    );
  }

  final VirtualBrowser browser;
  MyApp(this.browser);
}
