import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:bell4g_app/browser/browser.dart' as browser;
import 'package:bell4g_app/storage/data_persist.dart';

enum LoginType { useStoredCredentials, useCurrentCredentials }

enum NetworkLoadingType { loadingFromInternet, doneLoading }

/// Business Logic Component to Login page.
/// This will,
/// - capture texts in username, password text fields
/// - issue values concerning entered text is invalid or loading
/// - login using saved username/password of entered username.password
///
/// FIXME: When state updates through hot reload, [_username] and [_password] empties
/// even though [TextBox] doesn't. So tapping on [Next] will cause in `Empty Field`.
class LoginBLoC {
  /// Virtual browser variable used. Will load cookies as given through the constructor
  browser.Browser _virtualBrowser;

  /// Storage varibale to use. *Specific to flutter.*
  DataPersist storage = DataPersist();

  /// Variables to hold user information.
  /// Can be changed through [updateUsername] and [updatePassword] sinks.
  String _username = "", _password = "";

  /// Stream which is used to notify login event.
  /// Can give whether to use saved password or text box password.
  final _loginController = StreamController<LoginType>();

  /// [StreamController] to update value of [_username].
  final _usernameTextChangeController = StreamController<String>();

  /// [StreamController] to update value of [_password].
  final _passwordTextChangeController = StreamController<String>();

  /// Stream to show whether given inputs are invalid.
  /// [validInput] is considered as the [null] value.
  final _invalidStringUpdateStream =
      BehaviorSubject<String>(seedValue: LoginBLoC.validInput);
  static const validInput = "";

  /// Stream to get whether a network call is running.
  final _isLoadingValueUpdateStream = BehaviorSubject<NetworkLoadingType>(
      seedValue: NetworkLoadingType.doneLoading);

  /// Add to this sink to login using a [username] and a [password]
  Sink<LoginType> get logIn => _loginController;

  /// Add to this sink to change [_username]
  Sink<String> get updateUsername => _usernameTextChangeController;

  /// Add to this sink to change [_password]
  Sink<String> get updatePassword => _passwordTextChangeController;

  /// Use this stream to get whether input is invalid
  Stream<String> get getInvalidString => _invalidStringUpdateStream;

  /// Use this stream to get whether data is loading
  Stream<NetworkLoadingType> get getWhetherLoading =>
      _isLoadingValueUpdateStream;

  /// Constructor. Takes [browserCookies] value.
  /// To create new session use [LoginBLoC(Map())] or something similar.
  LoginBLoC(Map<String, String> browserCookies) {
    _virtualBrowser = browser.Browser.fromCookies(browserCookies);
    _loginController.stream.listen(_handleLoginRequested);
    _usernameTextChangeController.stream.listen(_handleUsernameChanged);
    _passwordTextChangeController.stream.listen(_handlePasswordChanged);
  }

  /// Try to log in using already present username and password
  void init() {
    _loginController.add(LoginType.useStoredCredentials);
  }

  /// Dispose of all streams.
  /// **Call this when disposing.**
  void dispose() {
    _loginController.close();
    _usernameTextChangeController.close();
    _passwordTextChangeController.close();
    _invalidStringUpdateStream.close();
    _isLoadingValueUpdateStream.close();
  }

  /// Function to update [_username]
  void _handleUsernameChanged(String usernameText) {
    this._username = usernameText;
  }

  /// Function to update [_password]
  void _handlePasswordChanged(String passwordText) =>
      this._password = passwordText;

  /// Handles when a new login info is added to the stream,
  /// which means that this will take care when a new login is requested.
  /// if [useSavedUser] is [true], this will get username and password
  /// from storage and try to login
  void _handleLoginRequested(LoginType useSavedUser) async {
    String loginUsername, loginPassword;
    bool isLoggedIn;

    _invalidStringUpdateStream.add(LoginBLoC.validInput);

    if (useSavedUser == LoginType.useStoredCredentials) {
      // Load saved data
      loginUsername = await storage.readData(DataPersist.usernameSaveKey);
      loginPassword = await storage.readData(DataPersist.passwordSaveKey);
    } else {
      loginUsername = this._username;
      loginPassword = this._password;
    }

    if (loginUsername == null || loginPassword == null) {
      return;
    }

    if (loginUsername == "" || loginPassword == "") {
      _invalidStringUpdateStream.add("Empty Field");
      return;
    }

    _isLoadingValueUpdateStream.add(NetworkLoadingType.loadingFromInternet);
    try {
      // Get request body using username and password
      // Send POST request
      await _virtualBrowser.pagePOST(
        url: browser.Browser.postUrl,
        body: {
          "logName": loginUsername,
          "password": loginPassword,
          "logtype": "login",
          "submit": "Sign+In"
        },
      );
      // Send a GET request to confirm login
      // If logged in response will have usage page data
      isLoggedIn = await _virtualBrowser
          .pageGET(url: browser.Browser.usageUrl)
          .then((response) => response.body.contains("USAGE"));
    } catch (e) {
      _invalidStringUpdateStream.add("Network Error");
      _isLoadingValueUpdateStream.add(NetworkLoadingType.doneLoading);
      return;
    }

    if (isLoggedIn) {
      storage.saveData(username: loginUsername, password: loginPassword);
    } else {
      _invalidStringUpdateStream.add("Invalid Field");
    }
    _isLoadingValueUpdateStream.add(NetworkLoadingType.doneLoading);
  }
}
