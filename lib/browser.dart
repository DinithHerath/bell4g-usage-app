import 'dart:async';
import 'dart:math' as Math;

import 'package:http/http.dart' as Http;
import 'package:html/parser.dart' as Html;
import 'package:html/dom.dart' as HtmlDom;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Urls
const String POST_URL = "http://www.lankabell.com/lte/home1.jsp";
const String HOME_URL = "http://www.lankabell.com/lte/home.jsp";
const String USAGE_URL = "http://www.lankabell.com/lte/usage.jsp";
const String MYPROFILE_URL = "http://www.lankabell.com/lte/myProfile.jsp";

// Saved data keys
const String USERNAME_SAVE_KEY = "username";
const String PASSWORD_SAVE_KEY = "password";

class VirtualBrowser {
  Http.Client _client = Http.Client();
  FlutterSecureStorage _storage = FlutterSecureStorage();
  Map<String, String> _headers = {};

  /// Send a GET request to the server.
  /// Default headers will be used.
  /// Results will be returned.
  Future<Http.Response> _getData({String url}) async {
    return await this._client.get(
          url,
          headers: this._headers,
        );
  }

  /// Send a POST Request to the server.
  /// Default headers will be used.
  /// Result will be returned.
  Future<Http.Response> _postData({String url, Map body}) async {
    return await this._client.post(
          url,
          body: body,
          headers: this._headers,
        );
  }

  /// Creates a login request.
  /// this data will be posted to the server.
  Map<String, String> _createLoginRequestBody(
      {String username, String password}) {
    return {
      "logName": username,
      "password": password,
      "logtype": "login",
      "submit": "Sign+In"
    };
  }

  /// Login to the server.
  /// Sends a POST request and cookies from the result will be saved.
  /// Then saved headers will be used to send a GET request and confirm that user is signed in.
  Future<bool> logIn(String username, String password) async {
    // Get request body using username and password
    Map requestBody = this._createLoginRequestBody(
      username: username,
      password: password,
    );
    // Send POST request
    Http.Response response = await this._postData(
      url: POST_URL,
      body: requestBody,
    );
    // Save the cookie
    this._updateCookie(response);
    // Send a GET request to confirm login
    // If logged in response will have usage page data
    response = await this._getData(url: USAGE_URL);
    if (response.body.contains("USAGE")) {
      // User is logged in
      // Save username and password securely
      this._storage.write(key: USERNAME_SAVE_KEY, value: username);
      this._storage.write(key: PASSWORD_SAVE_KEY, value: password);
      return true;
    } else {
      // User is not logged in
      return false;
    }
  }

  /// Get saved password and usernames (if any), and
  /// - if they are null *login failed*
  /// - else try to login with that username and password, and
  ///   - if successfull *Logged in*
  ///   - else *login failed*
  Future<bool> tryLogIn() async {
    String username = await _storage.read(key: USERNAME_SAVE_KEY);
    String password = await _storage.read(key: PASSWORD_SAVE_KEY);
    if (username == null || password == null) {
      return false;
    } else {
      return await logIn(username, password);
    }
  }

  /// Based on answer in :
  /// https://stackoverflow.com/questions/50299253/flutter-http-maintain-php-session
  ///
  /// Updates cookies by response data.
  /// **Important since server won't remember this client otherwise.**
  void _updateCookie(Http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      this._headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  /// Clear all cookies and forget session details
  void clearCookie() {
    this._headers = {};
    this._storage.delete(key: USERNAME_SAVE_KEY);
    this._storage.delete(key: PASSWORD_SAVE_KEY);
  }

  /// Scrape all data and send as a [Bell4GInfo] object
  Future<Bell4GInfo> scrapeData() async {
    // Parse Usage Oage
    List<double> usagePageData = List<double>.from(
      await this._parseDataPage(
        pageUrl: USAGE_URL,
        getFormattedDataFunc: this._getFormatedUsageData,
      ),
    );
    // Parse Home Page
    List<String> homePageData = List<String>.from(
      await this._parseDataPage(
        pageUrl: HOME_URL,
        getFormattedDataFunc: this._getFormatedHomeData,
      ),
    );

    // Parse My Profile Page
    List<String> myProfilePageData = List<String>.from(
      await this._parseDataPage(
        pageUrl: MYPROFILE_URL,
        getFormattedDataFunc: this._getFormatedMyProfileData,
        selectClass: "stylePack",
      ),
    );

    // Convert to [Bell4GInfo]
    Bell4GInfo info = Bell4GInfo()
      ..addHomePageData(homePageData)
      ..addUsagePageData(usagePageData)
      ..addMyProfilePageData(myProfilePageData);

    return info;
  }

  /// Take a HTML element and return data(double) as result(in Bytes).
  double _getFormatedUsageData(HtmlDom.Element element) {
    String text = element.text;
    int breakPos = text.indexOf(": ");
    String val = text.substring(breakPos + 1).trim();
    double data = Bell4GInfo.formatStringToData(val);
    return data;
  }

  /// Take a HTML element and return its text.
  /// All additional whitespaces will be removed.
  String _getFormatedHomeData(HtmlDom.Element element) {
    return element.text.replaceAll(RegExp(r"\s+"), " ");
  }

  /// Take a HTML element and return its text.
  /// All additional whitespaces will be removed.
  String _getFormatedMyProfileData(HtmlDom.Element element) {
    return element.text.replaceAll(RegExp(r"\s+"), " ");
  }

  /// Parse a data page. Page Url and formmating function to apply must be supplied.
  /// Result will be a list.
  Future<List> _parseDataPage(
      {String pageUrl,
      Function getFormattedDataFunc,
      String selectClass = "styleCommon",
      String ignoreClass = "c-font-bold"}) async {
    // GET page data
    Http.Response response = await this._getData(url: pageUrl);
    // Parse it into a HTML document object
    HtmlDom.Document parsed = Html.parse(response.body);
    // Get all needed type elements
    List<HtmlDom.Element> elemList = parsed.getElementsByClassName(selectClass);
    List result = [];
    for (HtmlDom.Element elem in elemList) {
      if (elem.className.contains(ignoreClass)) {
        // This element is not what we need.
        continue;
      } else {
        // Needed data. Format it and store in list.
        result.add(getFormattedDataFunc(elem));
      }
    }
    return result;
  }
}

class Bell4GInfo {
  // Add fields
  double usedDataDay = 0.0;
  double remainingDataDay = 1.0;
  double usedDataNight = 0.0;
  double remainingDataNight = 1.0;

  String activatedPackage = "-";
  String totalOutstanding = "-";
  String packageValue = "-";
  String lastPaymentAmount = "-";
  String packageDownSpeed = "Download Upto : -";
  String packageUpSpeed = "Upload Upto :-";
  String lastPaymentDate = "-";

  String profileName = "-";
  String profileEmail = "-";
  String profileMobileNumber = "-";
  String profileAddress = "-";
  String profileDirectoryNumber = "-";
  String profileAccounNumber = "-";
  String profileActivatePackage = "-";
  String profileNextBillDate = "-";
  String profileLoginName = "-";

  bool transactionSuccessful = true;

  String get formattedRemainingDayData =>
      formatDataToString(this.remainingDataDay);
  String get formattedRemainingNightData =>
      formatDataToString(this.remainingDataNight);
  DateTime get formattedNextBillDate {
    if (this.profileNextBillDate == "-") {
      return DateTime.now();
    } else {
      List<String> date = this.profileNextBillDate.split(" ")[0].split("/");
      String time = this.profileNextBillDate.split(" ")[1];
      return DateTime.parse("${date[2]}-${date[1]}-${date[0]} $time");
    }
  }

  int get daysPerPackage {
    int month = this.formattedNextBillDate.month;
    int year = this.formattedNextBillDate.year;
    if (month == 2) {
      // February
      if (year % 400 == 0) {
        return 29;
      } else if (year % 100 == 0) {
        return 28;
      } else if (year % 4 == 0) {
        return 29;
      } else {
        return 28;
      }
    } else if ([1, 3, 5, 7, 8, 10, 12].contains(month)) {
      return 31;
    } else {
      return 30;
    }
  }

  /// Data to String (23234.12 => 23.234 KB)
  static String formatDataToString(double data) {
    if (data > Math.pow(10, 9)) {
      return "${data/Math.pow(10, 9)} GB";
    } else if (data > Math.pow(10, 6)) {
      return "${data/Math.pow(10, 6)} MB";
    } else if (data > Math.pow(10, 3)) {
      return "${data/Math.pow(10, 3)} KB";
    } else {
      return "$data B";
    }
  }

  /// String to Data (23.234 KB => 23234.12)
  static double formatStringToData(String str) {
    double data = double.parse(str.split(" ")[0]);
    String postfix = str.split(" ")[1];
    switch (postfix) {
      case "GB":
        return data * Math.pow(10, 9);
      case "MB":
        return data * Math.pow(10, 6);
      case "KB":
        return data * Math.pow(10, 3);
      default:
        return data;
    }
  }

  /// Constructor
  Bell4GInfo();

  /// Add usage page data
  void addUsagePageData(List<double> data) {
    if (data.length != 4) {
      this.transactionSuccessful = false;
      return;
    }
    this.usedDataDay = data[0];
    this.usedDataNight = data[1];
    this.remainingDataDay = data[2];
    this.remainingDataNight = data[3];
  }

  /// Add Home page data
  void addHomePageData(List<String> data) {
    if (data.length != 7) {
      this.transactionSuccessful = false;
      return;
    }
    this.activatedPackage = data[0];
    this.totalOutstanding = data[1];
    this.packageValue = data[2];
    this.lastPaymentAmount = data[3];
    this.packageDownSpeed = data[4];
    this.packageUpSpeed = data[5];
    this.lastPaymentDate = data[6];
  }

  /// Add Home page data
  void addMyProfilePageData(List<String> data) {
    if (data.length != 35) {
      this.transactionSuccessful = false;
      return;
    }
    this.profileName = data[1];
    this.profileEmail = data[4].replaceAll("Change", "").trim();
    this.profileMobileNumber = data[7].replaceAll("Change", "").trim();
    this.profileAddress = data[10];
    this.profileDirectoryNumber = data[13];
    this.profileAccounNumber = data[16];
    this.activatedPackage = data[19];
    this.profileNextBillDate = data[22];
    this.profileLoginName = data[31];
  }
}
