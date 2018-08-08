import 'package:flutter/material.dart';

import 'package:bell4g_app/login/login_bloc.dart';

class LoginPage extends StatefulWidget {
  final LoginBLoC loginBloc = LoginBLoC(Map());

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  /// Dialog builder. The main interface.
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: <Widget>[
        // Divider between title and Content
        _buildUsernameText(),
        _buildPasswordText(),
        _buildButton(),
      ],
      // Title
      title: Text("Login to Continue"),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.loginBloc.init();
  }

  @override
  void dispose() {
    super.dispose();
    widget.loginBloc.dispose();
  }

  /// Username Text Field
  Widget _buildUsernameText() {
    return StreamBuilder<String>(
      stream: widget.loginBloc.getInvalidString,
      builder: (_, invalidTextSnapshot) {
        return TextBoxWidget(
          hintText: "Username",
          helperText: "Bell 4G Account name",
          icon: Icons.person,
          isPassword: false,
          invalidText: invalidTextSnapshot?.data,
          onSubmit: () =>
              widget.loginBloc.logIn.add(LoginType.useCurrentCredentials),
          changeApplyFunc: (s) => widget.loginBloc.updateUsername.add(s),
        );
      },
    );
  }

  /// Password Text Field
  Widget _buildPasswordText() {
    return StreamBuilder<String>(
      stream: widget.loginBloc.getInvalidString,
      builder: (_, invalidTextSnapshot) {
        return TextBoxWidget(
          hintText: "Password",
          helperText: "Bell 4G Account password",
          icon: Icons.lock_outline,
          isPassword: true,
          invalidText: invalidTextSnapshot?.data,
          onSubmit: () =>
              widget.loginBloc.logIn.add(LoginType.useCurrentCredentials),
          changeApplyFunc: (s) => widget.loginBloc.updatePassword.add(s),
        );
      },
    );
  }

  /// Builds the button, Will contain a Progess Indicator inline.
  /// It will show when [loading] is [true]
  Widget _buildButton() {
    return StreamBuilder<bool>(
      stream: widget.loginBloc.getWhetherLoading,
      builder: (_, isLoadingSnapshot) {
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child:
                    (isLoadingSnapshot?.data != null && isLoadingSnapshot.data)
                        ? CircularProgressIndicator()
                        : Container(),
              ),
              RaisedButton.icon(
                icon: Icon(Icons.arrow_forward),
                label: Text("Next"),
                onPressed: () =>
                    widget.loginBloc.logIn.add(LoginType.useCurrentCredentials),
              ),
            ],
          ),
        );
      },
    );
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
