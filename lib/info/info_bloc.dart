import 'dart:async';

import 'package:bell4g_app/browser/bell4g.dart';
import 'package:rxdart/rxdart.dart';

import 'package:bell4g_app/browser/parser.dart' as parser;

enum RefreshingState { refreshing, refreshed }

class InfoBLoC {
  void init() {}

  void dispose() {
    _isRefreshingStream.close();
    _updateDataController.close();
    _bell4GDataStream.close();
  }

  InfoBLoC() {
    _updateDataController.stream.listen(_updateData);
  }

  final _isRefreshingStream =
      BehaviorSubject<RefreshingState>(seedValue: RefreshingState.refreshed);
  Stream<RefreshingState> get isRefreshing => _isRefreshingStream;

  final _bell4GDataStream =
      BehaviorSubject<Bell4GInfo>(seedValue: Bell4GInfo());
  Stream<Bell4GInfo> get bell4GInfo => _bell4GDataStream;

  final _updateDataController = StreamController<Map<String, String>>();
  Sink<Map<String, String>> get updateData => _updateDataController;

  void _updateData(Map<String, String> cookies) async{
    parser.Bell4GSiteParser pageParser =
        parser.Bell4GSiteParser(cookies: cookies);
    Bell4GInfo scrapedData = await pageParser.scrapeData();
    _bell4GDataStream.add(scrapedData);
  }
}
