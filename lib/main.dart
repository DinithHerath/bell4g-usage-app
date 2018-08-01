import 'package:flutter/material.dart';

import 'package:bell4g_app/colors.dart' as ColorTheme;
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
      theme: ThemeData(
        primaryColor: ColorTheme.primaryColor,
        accentColor: ColorTheme.accentColor,
        primaryColorDark: ColorTheme.secondaryColor,
      ),
      home: StartUpPage(browser),
    );
  }

  final VirtualBrowser browser;
  MyApp(this.browser);
}
