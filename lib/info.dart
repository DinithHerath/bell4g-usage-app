import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:bell4g_app/colors.dart' as ColorTheme;
import 'package:bell4g_app/browser.dart';
import 'package:bell4g_app/startup.dart';
import 'package:bell4g_app/transition_maker.dart';

const String CHART_USED_KEY = 'Used';
const String CHART_REMAINING_KEY = 'Remaining';
const String CHART_SERIES_KEY = 'Data Usage';

class DataUsageInfo extends StatefulWidget {
  @override
  DataUsageInfoState createState() => DataUsageInfoState();

  /// Function to create chart data using used data and remaining data
  static List<CircularStackEntry> createChartData(
      double used, double remaining) {
    return <CircularStackEntry>[
      CircularStackEntry(
        <CircularSegmentEntry>[
          CircularSegmentEntry(used, ColorTheme.chartRed,
              rankKey: CHART_USED_KEY),
          CircularSegmentEntry(remaining, ColorTheme.chartGreen,
              rankKey: CHART_REMAINING_KEY),
        ],
        rankKey: CHART_SERIES_KEY,
      ),
    ];
  }

  // Initial state
  final List<CircularStackEntry> initData = createChartData(0.0, 100.0);
  // Browser
  final VirtualBrowser browser;
  DataUsageInfo(this.browser);
}

class DataUsageInfoState extends State<DataUsageInfo>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.primaryColor,
      appBar: _buildAppBar(),
      body: ListView(
        children: <Widget>[
          _buildChart(),
          _buildButtonBar(),
          // User home data
          Divider(color: ColorTheme.white),
          _buildInfoTile(this.currentInfo.activatedPackage, "Activated Package",
              FontAwesomeIcons.shoppingBag),
          _buildInfoTile(this.currentInfo.packageValue, "Package Value",
              FontAwesomeIcons.shoppingCart),
          _buildInfoTile(this.currentInfo.packageDownSpeed,
              "Max Download Speed", FontAwesomeIcons.download),
          _buildInfoTile(this.currentInfo.packageUpSpeed, "Max Upload Speed",
              FontAwesomeIcons.upload),
          _buildInfoTile(this.currentInfo.totalOutstanding, "Total Outstanding",
              FontAwesomeIcons.dollarSign),
          _buildInfoTile(this.currentInfo.lastPaymentAmount,
              "Last Payment Amount", FontAwesomeIcons.wallet),
          _buildInfoTile(this.currentInfo.lastPaymentDate,
              "Last Payment Date and Time", FontAwesomeIcons.calendar),
          // User profile data
          Divider(color: ColorTheme.white),
          _buildInfoTile(
              this.currentInfo.profileName, "Name", FontAwesomeIcons.userAlt),
          _buildInfoTile(this.currentInfo.profileEmail, "E-mail",
              FontAwesomeIcons.googlePlusG),
          _buildInfoTile(this.currentInfo.profileMobileNumber, "Mobile Number",
              FontAwesomeIcons.mobile),
          _buildInfoTile(this.currentInfo.profileAddress, "Address",
              FontAwesomeIcons.addressBook),
          _buildInfoTile(this.currentInfo.profileDirectoryNumber,
              "Directory Number", FontAwesomeIcons.phone),
          _buildInfoTile(this.currentInfo.profileAccounNumber, "Account Number",
              FontAwesomeIcons.userLock),
          _buildInfoTile(this.currentInfo.activatedPackage, "Active Package",
              FontAwesomeIcons.shoppingBasket),
          _buildInfoTile(this.currentInfo.profileNextBillDate,
              "Next Bill/Quota Issue Date", FontAwesomeIcons.calendar),
          _buildInfoTile(this.currentInfo.profileLoginName, "Login Name",
              FontAwesomeIcons.user),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: RotationTransition(
          child: Icon(Icons.refresh),
          turns: Tween(begin: 0.0, end: 1.0)
              .animate(refreshRotationAnimationController),
        ),
        onPressed: _handleOnPressedRefresh,
        backgroundColor: ColorTheme.black,
      ),
    );
  }

  /// App Bar
  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Bell 4G Data Usage"),
      actions: <Widget>[
        IconButton(
          icon: Icon(FontAwesomeIcons.signOutAlt),
          onPressed: _handleOnPressedLogout,
          tooltip: "Sign Out",
        )
      ],
    );
  }

  /// Pie/Radial Chart
  Widget _buildChart() {
    double phoneWidth = MediaQuery.of(context).size.width;
    return AnimatedCircularChart(
      key: this._chartKey,
      size: Size(phoneWidth * 0.75, phoneWidth * 0.75),
      // This is here just to fix bug when chart refreshed to initial values when goes out of screen
      initialChartData: isDay
          ? DataUsageInfo.createChartData(
              currentInfo.usedDataDay, currentInfo.remainingDataDay)
          : DataUsageInfo.createChartData(
              currentInfo.usedDataNight, currentInfo.remainingDataNight),
      chartType: CircularChartType.Radial,
      duration: Duration(milliseconds: 500),
      holeLabel: _buildCenterText(),
      labelStyle: TextStyle(color: ColorTheme.white, fontSize: 24.0),
    );
  }

  /// Pill like buttons to toggle between day time and night time
  Widget _buildButtonBar() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RaisedButton(
            child: SizedBox(
              child: Text("Day Time"),
              width: 70.0,
            ),
            onPressed: isDay ? null : _handleOnPressedCycle,
          ),
          RaisedButton(
            child: SizedBox(
              child: Text("Night Time"),
              width: 70.0,
            ),
            onPressed: isDay ? _handleOnPressedCycle : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingDays() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "05:04:03:23",
              style: TextStyle(fontSize: 32.0, color: ColorTheme.white),
            ),
          ),
        ],
      ),
    );
  }

  /// List Tiles to show information
  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(
          icon,
          color: ColorTheme.black,
          size: 18.0,
        ),
        backgroundColor: ColorTheme.white,
      ),
      title: Text(
        title,
        style: TextStyle(color: ColorTheme.white),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: ColorTheme.white),
      ),
    );
  }

  /// Text in middle of Chart
  String _buildCenterText() {
    if (isDay) {
      return "Day Time\n${this.currentInfo.formattedRemainingDayData}";
    } else {
      return "Night Time\n  ${this.currentInfo.formattedRemainingNightData}";
    }
  }

  /// Logout
  void _handleOnPressedLogout() {
    widget.browser.clearCookie();
    TransitionMaker
        .slideTransition(destinationPageCall: () => StartUpPage(widget.browser))
        .startNoBack(context);
  }

  void _handleOnPressedRefresh() async {
    refreshRotationAnimationController.repeat();
    await updateChart();
    refreshRotationAnimationController.stop();
  }

  /// Handle Pill Buttons to Switch between day and Night
  void _handleOnPressedCycle() {
    setState(() {
      isDay = !isDay;
    });
    refreshChartData();
  }

  /// Update chart with new data
  Future<void> updateChart() async {
    widget.browser.tryLogIn();
    Bell4GInfo info = await widget.browser.scrapeData();
    if (!info.transactionSuccessful) {
      return;
    } else {
      this.currentInfo = info;
      refreshChartData();
    }
  }

  /// Refreshed chart (Called after changing day time/ night time)
  void refreshChartData() {
    double used, remaining;
    if (isDay) {
      used = currentInfo.usedDataDay;
      remaining = currentInfo.remainingDataDay;
    } else {
      used = currentInfo.usedDataNight;
      remaining = currentInfo.remainingDataNight;
    }
    List<CircularStackEntry> nextData =
        DataUsageInfo.createChartData(used, remaining);
    setState(() {
      if (_chartKey.currentState != null) {
        _chartKey.currentState.updateData(nextData);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    refreshRotationAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    updateChart();
  }

  AnimationController refreshRotationAnimationController;
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      GlobalKey<AnimatedCircularChartState>();
  bool isDay = true;
  Bell4GInfo currentInfo = Bell4GInfo();
}
