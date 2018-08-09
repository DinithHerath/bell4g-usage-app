import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DataUsageInfo extends StatefulWidget {
  @override
  DataUsageInfoState createState() => DataUsageInfoState();

  DataUsageInfo();
}

class DataUsageInfoState extends State<DataUsageInfo>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: TabBarView(
          children: <Widget>[
            _buildHomePage(),
            _buildHomeDataTimes(),
            _buildProfileDataTiles(),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  /// App Bar
  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FlatButton.icon(
            label: Text("Sign Out"),
            icon: Icon(FontAwesomeIcons.signOutAlt),
            onPressed: () {
              print("Clears browser cookies and goes back to login page.");
            },
          )
        ],
      ),
      bottom: TabBar(
        tabs: <Widget>[
          _buildTabItem(icon: Icons.data_usage),
          _buildTabItem(icon: Icons.info_outline),
          _buildTabItem(icon: Icons.person_pin),
        ],
      ),
    );
  }

  /// Build the floating action button
  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      child: RotationTransition(
        child: Icon(
          Icons.refresh,
        ),
        turns: Tween(begin: 0.0, end: 1.0)
            .animate(refreshRotationAnimationController),
      ),
      onPressed: () {
        print("Refreshes Data");
      },
    );
  }

  /// Builds icon in tab bar
  Widget _buildTabItem({@required IconData icon}) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Icon(icon),
    );
  }

  /// Pie/Radial Chart
  Widget _buildChart() {
    // Responsive chart size
    double chartWidth = MediaQuery.of(context).size.width * 0.75;
    // If data is still not loaded show a progess indicater instaead
    // TODO: Add Circular chart otherwise
    return SizedBox(
      child: Center(child: CircularProgressIndicator()),
      width: chartWidth,
      height: chartWidth,
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
            onPressed: () {
              print("Switch to Day time");
            },
          ),
          RaisedButton(
            child: SizedBox(
              child: Text("Night Time"),
              width: 70.0,
            ),
            onPressed: () {
              print("Switch to Night time");
            },
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
          label: Text("About"),
          icon: Icon(FontAwesomeIcons.questionCircle),
          onPressed: () => showDialog(
                builder: (_) => AboutDialog(
                      applicationLegalese: "By kdsuneraavinash\n"
                          "kdsuneraavinash@gmail.com",
                      applicationName: "Bell 4G Data Usage",
                      applicationVersion: "0.3.0-alpha",
                    ),
                context: context,
              ),
        ),
      ],
    );
  }

  /// Remaining days and data info
  Widget _buildRemainingDays() {
    return Center(
      child: Column(
        children: <Widget>[
          _buildSmallText("Remaining till new package"),
          _buildLargeText(
            text: "[DAYS]",
            fontSize: 68.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 8.0,
          ),
          _buildLargeText(
            text: "AND [HOURS]",
            fontSize: 24.0,
            fontWeight: FontWeight.w300,
            letterSpacing: 10.0,
          ),
          SizedBox(height: 50.0),
          _buildSmallText("Allocation per Day Time"),
          _buildLargeText(
            text: "[DAY]",
            fontWeight: FontWeight.w600,
            letterSpacing: 10.0,
            fontSize: 36.0,
          ),
          SizedBox(height: 25.0),
          _buildSmallText("Allocation per Night Time"),
          _buildLargeText(
              text: "[NIGHT]",
              fontWeight: FontWeight.w600,
              letterSpacing: 10.0,
              fontSize: 36.0),
          SizedBox(height: 50.0),
        ],
      ),
    );
  }

  /// Text builder for [_buildRemainingDays]
  Widget _buildLargeText(
      {@required String text,
      FontWeight fontWeight = FontWeight.w400,
      double letterSpacing = 3.0,
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

  /// Text builder for Description of [_buildLargeText]
  Widget _buildSmallText(String text) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          letterSpacing: 3.0,
        ),
      ),
    );
  }

  /// View data scraped from home page as tiles
  Widget _buildHomeDataTimes() {
    return ListView(
      children: <Widget>[
        _buildInfoTile(
            "[Please Wait]", "Activated Package", FontAwesomeIcons.shoppingBag),
        _buildInfoTile(
            "[Please Wait]", "Package Value", FontAwesomeIcons.shoppingCart),
        _buildInfoTile(
            "[Please Wait]", "Max Download Speed", FontAwesomeIcons.download),
        _buildInfoTile(
            "[Please Wait]", "Max Upload Speed", FontAwesomeIcons.upload),
        _buildInfoTile(
            "[Please Wait]", "Total Outstanding", FontAwesomeIcons.dollarSign),
        _buildInfoTile(
            "[Please Wait]", "Last Payment Amount", FontAwesomeIcons.wallet),
        _buildInfoTile("[Please Wait]", "Last Payment Date and Time",
            FontAwesomeIcons.calendar),
      ],
    );
  }

  /// View data scraped from profile page as tiles
  Widget _buildProfileDataTiles() {
    return ListView(
      children: <Widget>[
        _buildInfoTile("[Please Wait]", "Name", FontAwesomeIcons.userAlt),
        _buildInfoTile("[Please Wait]", "E-mail", FontAwesomeIcons.googlePlusG),
        _buildInfoTile(
            "[Please Wait]", "Mobile Number", FontAwesomeIcons.mobile),
        _buildInfoTile(
            "[Please Wait]", "Address", FontAwesomeIcons.addressBook),
        _buildInfoTile(
            "[Please Wait]", "Directory Number", FontAwesomeIcons.phone),
        _buildInfoTile(
            "[Please Wait]", "Account Number", FontAwesomeIcons.userLock),
        _buildInfoTile(
            "[Please Wait]", "Active Package", FontAwesomeIcons.shoppingBasket),
        _buildInfoTile("[Please Wait]", "Next Bill/Quota Issue Date",
            FontAwesomeIcons.calendar),
      ],
    );
  }

  /// List Tiles to show information
  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(icon, size: 18.0),
      ),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  @override
  void initState() {
    super.initState();
    refreshRotationAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  AnimationController refreshRotationAnimationController;
}
