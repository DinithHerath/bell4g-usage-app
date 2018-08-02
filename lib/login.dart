import 'package:flutter/material.dart';

import 'package:bell4g_app/colors.dart';
import 'package:bell4g_app/browser.dart';

class LoginPage extends StatefulWidget {
  final VirtualBrowser browser;

  LoginPage(this.browser, this.theme);
  final ColorTheme theme;

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return _buildDialog();
  }

  /// Dialog builder. The main interface.
  Widget _buildDialog() {
    return Theme(
      data: widget.theme.asTheme,
      child: SimpleDialog(
        children: <Widget>[
          // Divider between title and Content
          Divider(color: widget.theme.black),
          // Username Text Field
          Padding(
            padding: EdgeInsets.all(8.0),
            child: _buildTextBox(
                hintText: "Username",
                helperText: "Bell 4G Account name",
                icon: Icons.person,
                onSubmit: _handleTextSubmitted,
                changeApplyFunc: (s) {
                  this.username = s;
                }),
          ),
          // Password Text Field
          Padding(
            padding: EdgeInsets.all(8.0),
            child: _buildTextBox(
                hintText: "Password",
                helperText: "Bell 4G Account password",
                icon: Icons.lock_outline,
                isPassword: true,
                onSubmit: _handleTextSubmitted,
                changeApplyFunc: (s) {
                  this.password = s;
                }),
          ),
          // Button
          _buildButton(),
        ],
        // Title
        title: Text("Login to Continue"),
      ),
    );
  }

  /// Builds the button, Will contain a Progess Indicator inline.
  /// It will show when [loading] is [true]
  Widget _buildButton() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: loading
                ? CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(widget.theme.secondaryColor),
                  )
                : Container(),
          ),
          RaisedButton.icon(
            icon: Icon(Icons.arrow_forward),
            label: Text("Next"),
            onPressed: _handleTextSubmitted,
          ),
        ],
      ),
    );
  }

  /// Builds a text box.
  /// **Unknown reason causing adding a controller to clear text box when unfocused.**
  /// So will use [onChange] to record changes.
  /// So need to pass a function that will change outer variable value.
  Widget _buildTextBox({
    IconData icon,
    String helperText,
    String hintText,
    bool isPassword = false,
    Function onSubmit,
    Function changeApplyFunc,
  }) {
    return TextField(
      decoration: InputDecoration(
          icon: CircleAvatar(
              child: Icon(
            icon,
            color: widget.theme.white,
          )),
          hintText: hintText,
          helperText: helperText,
          errorText: this.wrongInputs ? "Invalid Username/Password" : null),
      obscureText: isPassword,
      onSubmitted: (s) => onSubmit(),
      onChanged: changeApplyFunc,
    );
  }

  /// When text submitted or button pressed.
  void _handleTextSubmitted() async {
    // Nothing entered
    if (this.username == "" || this.password == "") {
      return;
    }
    // Default state
    setState(() {
      wrongInputs = false;
      loading = true;
    });
    // Log in
    bool loggedIn = await widget.browser.logIn(this.username, this.password);
    if (loggedIn) {
      // Logged in, Pass true to parent.
      Navigator.pop(context, true);
    } else {
      // login failed, display error messages.
      setState(() {
        wrongInputs = true;
        loading = false;
      });
    }
  }

  bool wrongInputs = false;
  bool loading = false;
  String username = "";
  String password = "";
}
