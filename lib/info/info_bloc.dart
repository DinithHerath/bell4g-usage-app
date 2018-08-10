import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:bell4g_app/browser/parser.dart' as parser;
import 'package:bell4g_app/storage/data_persist.dart' as storage;
import 'package:bell4g_app/browser/bell4g.dart';

enum RefreshingState { refreshing, refreshed }

enum NavigationFromInfoPage { noNavigation, navigateToLoginPage }

enum ShouldLogout { dontLogout, logout }

/// Calss to Store data usage details
class DataUsage {
  final String daysTillNewPackage;
  final String hoursTillNewPackage;
  final String allocationDayTime;
  final String allocationightTime;

  DataUsage(
      {this.daysTillNewPackage,
      this.hoursTillNewPackage,
      this.allocationDayTime,
      this.allocationightTime});

  /// Initializing factory
  factory DataUsage.initial() {
    return DataUsage(
        daysTillNewPackage: "[DAYS]",
        hoursTillNewPackage: "[HOURS]",
        allocationDayTime: "[DAYTIME]",
        allocationightTime: "[NIGHTTIME]");
  }
}

/// Business logic component of info screen
class InfoBLoC {
  /// Initializer - things to do at startup
  void init(Map<String, String> cookies) {
    updateData.add(cookies);
  }

  /// Dispose of all streams
  void dispose() {
    _isRefreshingStream.close();
    _updateDataController.close();
    _bell4GDataStream.close();
    _usageStream.close();
    _navigationControlStream.close();
    _logoutController.close();
  }

  /// Constructor - Listen to incoming streams
  InfoBLoC() {
    _updateDataController.stream.listen(_updateData);
    _logoutController.stream.listen(_handleLogout);
  }

  /// Stream to inform whether data is being refreshed
  final _isRefreshingStream =
      BehaviorSubject<RefreshingState>(seedValue: RefreshingState.refreshed);

  /// getter for Stream which indicted whether data is being updated
  Stream<RefreshingState> get isRefreshing => _isRefreshingStream;

  /// Stream to give bell 4g data
  final _bell4GDataStream =
      BehaviorSubject<Bell4GInfo>(seedValue: Bell4GInfo());

  /// getter for Stream which gives bell 4g data
  Stream<Bell4GInfo> get bell4GInfo => _bell4GDataStream;

  /// Stream to give bell 4g usage details
  final _usageStream =
      BehaviorSubject<DataUsage>(seedValue: DataUsage.initial());

  /// getter for Stream which gives bell 4g usage details
  Stream<DataUsage> get usageInfo => _usageStream;

  final _navigationControlStream = BehaviorSubject<NavigationFromInfoPage>(
      seedValue: NavigationFromInfoPage.noNavigation);

  Stream<NavigationFromInfoPage> get navigationControl =>
      _navigationControlStream;

  /// Listening sink to get whether data needs to be updated
  final _updateDataController = StreamController<Map<String, String>>();

  /// Send a signal to BLoC to update data. Cookies to login are required
  Sink<Map<String, String>> get updateData => _updateDataController;

  /// Listening sink to get whether to logout
  final _logoutController = StreamController<ShouldLogout>();

  /// Send a signal to BLoC to logout
  Sink<ShouldLogout> get logout => _logoutController;

  void _handleLogout(ShouldLogout control) {
    if (control == ShouldLogout.logout) {
      storage.DataPersist dataPersist = storage.DataPersist();
      dataPersist.deleteData(userdata: true);
      _navigationControlStream.add(NavigationFromInfoPage.navigateToLoginPage);
    }
  }

  /// Update data in info page
  void _updateData(Map<String, String> cookies) async {
    // Set that this is refreshing
    _isRefreshingStream.add(RefreshingState.refreshing);

    Bell4GInfo scrapedData;

    try {
      // Initialize and parse pages
      parser.Bell4GSiteParser pageParser =
          parser.Bell4GSiteParser(cookies: cookies);
      scrapedData = await pageParser.scrapeData();
      _bell4GDataStream.add(scrapedData);
    } catch (e) {
      print("Network Error");
      _isRefreshingStream.add(RefreshingState.refreshed);
      return;
    }

    // Calculate no of day times and night times left
    Duration remainingDays =
        scrapedData.formattedNextBillDate.difference(DateTime.now());
    int remainingDayTimes = remainingDays.inDays + 1;
    int remainingNightTimes =
        remainingDays.inDays + (remainingDays.inHours > 18 ? 1 : 0);
    String allocationDayTime = Bell4GInfo.formatDataToString(double.parse(
        (scrapedData.remainingDataDay / remainingDayTimes)
            .toStringAsPrecision(3)));
    String allocationNightTime = Bell4GInfo.formatDataToString(double.parse(
        (scrapedData.remainingDataNight / remainingNightTimes)
            .toStringAsPrecision(3)));

    // Calculate and add data usage days and allocation data
    DataUsage dataUsage = DataUsage(
        daysTillNewPackage: "${remainingDays.inDays} DAYS",
        hoursTillNewPackage:
            "${(remainingDays - Duration(days: remainingDays.inDays)).inHours} HOURS",
        allocationDayTime: "$allocationDayTime",
        allocationightTime: "$allocationNightTime");
    _usageStream.add(dataUsage);

    _isRefreshingStream.add(RefreshingState.refreshed);
  }
}
