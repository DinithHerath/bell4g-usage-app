import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:bell4g_app/colors.dart';
import 'package:bell4g_app/browser.dart';
import 'package:bell4g_app/transition_maker.dart';

const String CHART_USED_KEY = 'Used';
const String CHART_REMAINING_KEY = 'Remaining';
const String CHART_SERIES_KEY = 'Data Usage';

class DataUsageInfo extends StatefulWidget {
  @override
  DataUsageInfoState createState() => DataUsageInfoState();

  // Browser
  final VirtualBrowser browser;
  DataUsageInfo(this.browser, this.theme);
  final ColorTheme theme;
}

class DataUsageInfoState extends State<DataUsageInfo>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme.asTheme,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: _buildAppBar(),
          body: TabBarView(
            children: <Widget>[
              _buildHomePage(),
              // User home data
              _buildHomeDataTimes(),
              _buildProfileDataTiles(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: RotationTransition(
              child: Icon(
                Icons.refresh,
                color: widget.theme.white,
              ),
              turns: Tween(begin: 0.0, end: 1.0)
                  .animate(refreshRotationAnimationController),
            ),
            onPressed: _handleOnPressedRefresh,
            backgroundColor: widget.theme.black,
          ),
        ),
      ),
    );
  }

  /// App Bar
  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton.icon(
            label: Text(widget.theme.themeName),
            icon: Icon(widget.theme.themeIcon),
            onPressed: () {
              widget.theme.switchTheme();
              // Refreshes Chart data (To switch colors)
              // This also calls setState() so no need to call again
              refreshChartData();
            },
            textColor: widget.theme.white,
          ),
          FlatButton.icon(
            label: Text("Sign Out"),
            icon: Icon(FontAwesomeIcons.signOutAlt),
            onPressed: _handleOnPressedLogout,
            textColor: widget.theme.white,
          )
        ],
      ),
      bottom: TabBar(
        indicatorColor: widget.theme.secondaryColor,
        tabs: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.data_usage),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.info_outline),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.person_pin),
          )
        ],
      ),
    );
  }

  /// Pie/Radial Chart
  Widget _buildChart() {
    double chartWidth = MediaQuery.of(context).size.width * 0.75;
    // If data is still not loaded show a progess indicatr instaead
    if (this.isInitial) {
      return SizedBox(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(widget.theme.secondaryColor),
          ),
        ),
        width: chartWidth,
        height: chartWidth,
      );
    }
    // If data is loaded show the Chart
    return AnimatedCircularChart(
      key: this._chartKey,
      size: Size(chartWidth, chartWidth),
      // This is here just to fix bug when chart refreshed to initial values when goes out of screen
      initialChartData: dayTimeSelected
          ? createChartData(
              currentInfo.usedDataDay, currentInfo.remainingDataDay)
          : createChartData(
              currentInfo.usedDataNight, currentInfo.remainingDataNight),
      chartType: CircularChartType.Radial,
      duration: Duration(milliseconds: 500),
      holeLabel: _buildCenterText(),
      labelStyle: TextStyle(color: widget.theme.white, fontSize: 24.0),
    );
  }

  /// Function to create chart data using used data and remaining data
  List<CircularStackEntry> createChartData(double used, double remaining) {
    return <CircularStackEntry>[
      CircularStackEntry(
        <CircularSegmentEntry>[
          CircularSegmentEntry(used, widget.theme.chartRed,
              rankKey: CHART_USED_KEY),
          CircularSegmentEntry(remaining, widget.theme.chartGreen,
              rankKey: CHART_REMAINING_KEY),
        ],
        rankKey: CHART_SERIES_KEY,
      ),
    ];
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
            onPressed: dayTimeSelected ? null : _handleOnPressedCycle,
          ),
          RaisedButton(
            child: SizedBox(
              child: Text("Night Time"),
              width: 70.0,
            ),
            onPressed: dayTimeSelected ? _handleOnPressedCycle : null,
          ),
        ],
      ),
    );
  }

  /// Main screen containing chart and texts
  Widget _buildHomePage() {
    return ListView(
      children: <Widget>[
        _buildChart(),
        _buildButtonBar(),
        SizedBox(height: 50.0),
        _buildRemainingDays(),
        FlatButton.icon(
          textColor: widget.theme.white,
          label: Text("About"),
          icon: Icon(FontAwesomeIcons.questionCircle),
          onPressed: () => showDialog(
                builder: (_) => AboutDialog(
                  applicationLegalese: "By kdsuneraavinash\nkdsuneraavinash@gmail.com",
                  applicationName: "Bell 4G Data Usage",
                  applicationVersion: "0.2.0-alpha",
                ),
                context: context,
              ),
        ),
      ],
    );
  }

  /// Remaining days and data info
  Widget _buildRemainingDays() {
    Duration remainingDays =
        this.currentInfo.formattedNextBillDate.difference(DateTime.now());
    String allocationDayTime = Bell4GInfo.formatDataToString(double.parse(
        (this.currentInfo.remainingDataDay / remainingDays.inDays)
            .toStringAsPrecision(3)));
    String allocationNightTime = Bell4GInfo.formatDataToString(double.parse(
        (this.currentInfo.remainingDataNight / remainingDays.inDays)
            .toStringAsPrecision(3)));
    return Center(
      child: Column(
        children: <Widget>[
          _buildLargeText(
            text: "${remainingDays.inDays} DAYS",
            fontSize: 72.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 8.0,
          ),
          _buildLargeText(
            text:
                "AND ${(remainingDays - Duration(days: remainingDays.inDays)).inHours} HOURS",
            fontSize: 24.0,
            fontWeight: FontWeight.w300,
            letterSpacing: 10.0,
          ),
          _buildLargeText(
            text: "Remaining till new package",
            fontWeight: FontWeight.w400,
            letterSpacing: 3.0,
          ),
          SizedBox(height: 50.0),
          _buildLargeText(
            text: "$allocationDayTime",
            fontWeight: FontWeight.w600,
            letterSpacing: 10.0,
            fontSize: 36.0,
          ),
          _buildLargeText(
            text: "Allocation per Day Time",
            fontWeight: FontWeight.w400,
            letterSpacing: 3.0,
          ),
          SizedBox(height: 25.0),
          _buildLargeText(
              text: "$allocationNightTime",
              fontWeight: FontWeight.w600,
              letterSpacing: 10.0,
              fontSize: 36.0),
          _buildLargeText(
            text: "Allocation per Night Time",
            fontWeight: FontWeight.w400,
            letterSpacing: 3.0,
          ),
          SizedBox(height: 50.0),
        ],
      ),
    );
  }

  /// Text builder for [_buildRemainingDays]
  Widget _buildLargeText(
      {String text,
      FontWeight fontWeight,
      double letterSpacing,
      double fontSize}) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        fontSize: fontSize,
      ),
    );
  }

  /// View data scraped from home page as tiles
  Widget _buildHomeDataTimes() {
    return ListView(
      children: <Widget>[
        _buildInfoTile(this.currentInfo.activatedPackage, "Activated Package",
            FontAwesomeIcons.shoppingBag),
        _buildInfoTile(this.currentInfo.packageValue, "Package Value",
            FontAwesomeIcons.shoppingCart),
        _buildInfoTile(this.currentInfo.packageDownSpeed, "Max Download Speed",
            FontAwesomeIcons.download),
        _buildInfoTile(this.currentInfo.packageUpSpeed, "Max Upload Speed",
            FontAwesomeIcons.upload),
        _buildInfoTile(this.currentInfo.totalOutstanding, "Total Outstanding",
            FontAwesomeIcons.dollarSign),
        _buildInfoTile(this.currentInfo.lastPaymentAmount,
            "Last Payment Amount", FontAwesomeIcons.wallet),
        _buildInfoTile(this.currentInfo.lastPaymentDate,
            "Last Payment Date and Time", FontAwesomeIcons.calendar),
      ],
    );
  }

  /// View data scraped from profile page as tiles
  Widget _buildProfileDataTiles() {
    return ListView(
      children: <Widget>[
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
      ],
    );
  }

  /// List Tiles to show information
  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(
          icon,
          size: 18.0,
          color: widget.theme.white,
        ),
      ),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  /// Text in middle of Chart
  String _buildCenterText() {
    if (dayTimeSelected) {
      return "Day Time\n${this.currentInfo.formattedRemainingDayData}";
    } else {
      return "Night Time\n  ${this.currentInfo.formattedRemainingNightData}";
    }
  }

  /// Logout
  void _handleOnPressedLogout() {
    // widget.browser.clearCookie();
    // TransitionMaker
    //     .slideTransition(
    //         destinationPageCall: () =>
    //             StartUpPage(widget.browser, widget.theme))
        // .startNoBack(context);
  }

  /// Refreshing FAB action
  void _handleOnPressedRefresh() async {
    refreshRotationAnimationController.repeat();
    await updateChart();
    refreshRotationAnimationController.stop();
  }

  /// Handle Pill Buttons to Switch between day and Night
  void _handleOnPressedCycle() {
    setState(() {
      dayTimeSelected = !dayTimeSelected;
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
    setState(() {
      this.isInitial = false;
    });
  }

  /// Refreshed chart (Called after changing day time/ night time)
  void refreshChartData() {
    double used, remaining;
    if (dayTimeSelected) {
      used = currentInfo.usedDataDay;
      remaining = currentInfo.remainingDataDay;
    } else {
      used = currentInfo.usedDataNight;
      remaining = currentInfo.remainingDataNight;
    }
    List<CircularStackEntry> nextData = createChartData(used, remaining);
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
  Bell4GInfo currentInfo = Bell4GInfo();
  bool isInitial = true;
  bool dayTimeSelected = true;
}
