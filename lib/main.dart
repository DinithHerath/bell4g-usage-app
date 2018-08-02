import 'package:flutter/material.dart';

import 'package:bell4g_app/colors.dart';
import 'package:bell4g_app/browser.dart';
import 'package:bell4g_app/startup.dart';

void main() {
  VirtualBrowser browser = VirtualBrowser();
  runApp(MyApp(browser));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: StartUpPage(browser, theme),
    );
  }

  final VirtualBrowser browser;
  final ColorTheme theme = ColorTheme();
  MyApp(this.browser);
}
