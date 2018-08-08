import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class Browser {
  final http.Client _httpClient = http.Client();
  final Map<String, String> _headers;

  Map<String, String> get cookies => this._headers;

  static const Duration _kRequestTimeoutDuration = Duration(seconds: 5);

  Browser(this._headers);

  factory Browser.createNew() => Browser(Map());
  factory Browser.fromCookies(Map<String, String> cookies) => Browser(cookies);

  /// Send a GET request to the server.
  /// Default headers will be used.
  /// Results will be returned.
  Future<http.Response> pageGET({@required String url}) async {
    return await this
        ._httpClient
        .get(url, headers: this._headers)
        .timeout(_kRequestTimeoutDuration);
  }

  /// Send a POST Request to the server.
  /// Default headers will be used.
  /// Result will be returned.
  Future<http.Response> pagePOST(
      {@required String url,
      @required Map body,
      bool saveCookies = true}) async {
    http.Response response = await this
        ._httpClient
        .post(url, body: body, headers: this._headers)
        .timeout(_kRequestTimeoutDuration);

    // Save the cookie
    if (saveCookies) updateCookies(response);

    return response;
  }

  /// Based on answer in :
  /// https://stackoverflow.com/questions/50299253/flutter-http-maintain-php-session
  ///
  /// Updates cookies by response data.
  /// **Important since server won't remember this client otherwise.**
  void updateCookies(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      this._headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}
