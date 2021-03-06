import 'package:flutter/material.dart';

import 'package:bell4g_app/info/info.dart';
import 'package:bell4g_app/login/login_bloc.dart';

class LoginPage extends StatefulWidget {
  final LoginBLoC loginBLoC = LoginBLoC();

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  /// Dialog builder. The main interface.
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Stack(
        children: <Widget>[
          SimpleDialog(
            children: <Widget>[
              // Divider between title and Content
              _buildUsernameText(),
              _buildPasswordText(),
              _buildButton(),
            ],
            // Title
            title: Text("Login to Continue"),
          ),
          _buildTopLoadingLayer(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.loginBLoC.init();
    widget.loginBLoC.navigationControl.listen(_handleNavigation);
  }

  @override
  void dispose() {
    super.dispose();
    widget.loginBLoC.dispose();
  }

  Widget _buildTopLoadingLayer() {
    return StreamBuilder<NetworkLoadingType>(
      stream: widget.loginBLoC.getWhetherLoading,
      builder: (_, isLoadingSnapshot) {
        return (isLoadingSnapshot?.data != null &&
                isLoadingSnapshot.data == NetworkLoadingType.doneLoading)
            ? Container()
            : Opacity(
                child: Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                  color: Theme.of(context).primaryColor,
                ),
                opacity: 0.8,
              );
      },
    );
  }

  /// Username Text Field
  Widget _buildUsernameText() {
    return StreamBuilder<String>(
      stream: widget.loginBLoC.getInvalidString,
      builder: (_, invalidTextSnapshot) {
        return TextBoxWidget(
          hintText: "Username",
          helperText: "Bell 4G Account name",
          icon: Icons.person,
          isPassword: false,
          invalidText: invalidTextSnapshot?.data,
          onSubmit: _handleLoginAction,
          changeApplyFunc: _handleUsernameChangeAction,
        );
      },
    );
  }

  /// Password Text Field
  Widget _buildPasswordText() {
    return StreamBuilder<String>(
      stream: widget.loginBLoC.getInvalidString,
      builder: (_, invalidTextSnapshot) {
        return TextBoxWidget(
          hintText: "Password",
          helperText: "Bell 4G Account password",
          icon: Icons.lock_outline,
          isPassword: true,
          invalidText: invalidTextSnapshot?.data,
          onSubmit: _handleLoginAction,
          changeApplyFunc: _handlePasswordChangeAction,
        );
      },
    );
  }

  /// Builds the button, Will contain a Progess Indicator inline.
  /// It will show when [loading] is [true]
  Widget _buildButton() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: RaisedButton.icon(
          icon: Icon(Icons.arrow_forward),
          label: Text("Next"),
          onPressed: _handleLoginAction,
        ),
      ),
    );
  }

  void _handleLoginAction() =>
      widget.loginBLoC.logIn.add(LoginType.useCurrentCredentials);

  void _handleUsernameChangeAction(str) =>
      widget.loginBLoC.updateUsername.add(str);

  void _handlePasswordChangeAction(str) =>
      widget.loginBLoC.updatePassword.add(str);

  void _handleNavigation(NavigateFromData navigationData) {
    if (navigationData.control == NavigationFromLoginPage.navigateToInfoPage) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) {
              return DataUsageInfo(navigationData.cookies);
            },
            transitionsBuilder:
                (_, Animation<double> animation, __, Widget child) {
              return SlideTransition(
                position: Tween<Offset>(
                        begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                    .animate(animation),
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 500)),
      );
    }
  }
}

class TextBoxWidget extends StatefulWidget {
  TextBoxWidgetState createState() => TextBoxWidgetState();

  TextBoxWidget({
    @required this.icon,
    @required this.onSubmit,
    @required this.changeApplyFunc,
    this.helperText,
    this.hintText,
    this.isPassword = false,
    this.invalidText = "",
  });

  final IconData icon;
  final Function onSubmit;
  final Function changeApplyFunc;
  final String helperText;
  final String hintText;
  final bool isPassword;
  final String invalidText;
}

/// Builds a text box.
/// **Unknown reason causing adding a controller to clear text box when unfocused.**
/// So will use [onChange] to record changes.
/// So need to pass a function that will change outer variable value.
class TextBoxWidgetState extends State<TextBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          icon: CircleAvatar(child: Icon(widget.icon)),
          hintText: widget.hintText,
          helperText: widget.helperText,
          errorText: widget.invalidText != "" ? widget.invalidText : null,
        ),
        obscureText: widget.isPassword,
        onSubmitted: (s) => widget.onSubmit(),
        onChanged: widget.changeApplyFunc,
      ),
    );
  }
}
