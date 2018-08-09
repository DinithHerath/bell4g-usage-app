import 'dart:async';

import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as htmlDom;
import 'package:http/http.dart' as http;

import 'package:bell4g_app/browser/browser.dart' as browser;
import 'package:bell4g_app/browser/bell4g.dart';
import 'package:meta/meta.dart';

// Urls
const String postUrl = "http://www.lankabell.com/lte/home1.jsp";
const String homeUrl = "http://www.lankabell.com/lte/home.jsp";
const String usageUrl = "http://www.lankabell.com/lte/usage.jsp";
const String myProfileUrl = "http://www.lankabell.com/lte/myProfile.jsp";

class Bell4GSiteParser {
  /// Scrape all data and send as a [Bell4GInfo] object
  Future<Bell4GInfo> scrapeData() async {
    // Parse Usage Oage
    List<double> usagePageData = List<double>.from(
      await _parseDataPage(
        pageUrl: usageUrl,
        getFormattedDataFunc: _getFormatedUsageData,
      ),
    );
    // Parse Home Page
    List<String> homePageData = List<String>.from(
      await _parseDataPage(
        pageUrl: homeUrl,
        getFormattedDataFunc: _getFormatedHomeData,
      ),
    );

    // Parse My Profile Page
    List<String> myProfilePageData = List<String>.from(
      await _parseDataPage(
        pageUrl: myProfileUrl,
        getFormattedDataFunc: _getFormatedMyProfileData,
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
  double _getFormatedUsageData(htmlDom.Element element) {
    String text = element.text;
    int breakPos = text.indexOf(": ");
    String val = text.substring(breakPos + 1).trim();
    double data = Bell4GInfo.formatStringToData(val);
    return data;
  }

  /// Take a HTML element and return its text.
  /// All additional whitespaces will be removed.
  String _getFormatedHomeData(htmlDom.Element element) {
    return element.text.replaceAll(RegExp(r"\s+"), " ");
  }

  /// Take a HTML element and return its text.
  /// All additional whitespaces will be removed.
  String _getFormatedMyProfileData(htmlDom.Element element) {
    return element.text.replaceAll(RegExp(r"\s+"), " ");
  }

  /// Parse a data page. Page Url and formmating function to apply must be supplied.
  /// Result will be a list. 
  Future<List> _parseDataPage(
      {@required String pageUrl,
      @required Function getFormattedDataFunc,
      String selectClass = "styleCommon",
      String ignoreClass = "c-font-bold"}) async {
    // GET page data and
    // Parse it into a HTML document object
    http.Response response = await browser.Browser(this.cookies).pageGET(url: pageUrl);
    htmlDom.Document parsed = html.parse(response.body);
    // Get all needed type elements
    List<htmlDom.Element> elemList = parsed.getElementsByClassName(selectClass);
    List result = [];
    for (htmlDom.Element elem in elemList) {
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

  final Map<String, String> cookies;
  Bell4GSiteParser({@required this.cookies});
}
