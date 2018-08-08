import 'package:bell4g_app/login/login.dart';
import 'package:flutter/material.dart';

import 'package:bell4g_app/colors.dart';
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
      home: Container(
        child: LoginPage(),
        color:theme.primaryColor,
      ),
    );
  }

  final VirtualBrowser browser;
  final ColorTheme theme = ColorTheme();
  MyApp(this.browser);
}
