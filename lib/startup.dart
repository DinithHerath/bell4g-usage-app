import 'package:flutter/material.dart';

import 'package:bell4g_app/browser.dart';
import 'package:bell4g_app/info.dart';
import 'package:bell4g_app/login.dart';
import 'package:bell4g_app/colors.dart' as ColorTheme;
import 'transition_maker.dart';

class StartUpPage extends StatefulWidget {
  @override
  StartUpPageState createState() {
    return StartUpPageState();
  }

  final VirtualBrowser browser;

  StartUpPage(this.browser);
}

class StartUpPageState extends State<StartUpPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorTheme.primaryColor,
      child: Center(
        child: Container(
          color: ColorTheme.primaryColor,
        ),
      ),
    );
  }

  /// Handles main function of this window
  void _handleTransition() async {
    // try to login
    bool loggedIn = await widget.browser.tryLogIn();
    bool success = true;
    if (!loggedIn) {
      // If not logged in try to gain permission by showing login window
      success = await showDialog(
        context: context,
        builder: (context) => LoginPage(widget.browser),
      );
      // If nothing passed back (window closed by user) set success to false
      success ??= false;
    }
    // If logged in go to info page
    if (success) {
      TransitionMaker
          .slideTransition(
              destinationPageCall: () => DataUsageInfo(widget.browser))
          .startNoBack(context);
    }else{
      // If not logged in do this function again
      _handleTransition();
    }
  }

  @override
  void initState() {
    super.initState();
    _handleTransition();
  }
}