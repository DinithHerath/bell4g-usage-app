import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Themes { DARK, LIGHT, BELL4G, ORANGE }

class ColorTheme {
  Color primaryColor;
  Color scaffoldBackColor;
  Color accentColor;
  Color secondaryColor;
  Color chartRed;
  Color chartGreen;
  Color white;
  Color whiteGrey;
  Color black;
  Themes currentTheme;

  void switchToLightTheme() {
    this.currentTheme = Themes.LIGHT;
    this.primaryColor = Color(0xffffffff);
    this.scaffoldBackColor = Color(0xffffffff);
    this.accentColor = Color(0xff000000);
    this.secondaryColor = Color(0xff24b557);
    this.chartRed = Color(0xffef5350);
    this.chartGreen = Color(0xff66BB6A);
    this.white = Color(0xff000000);
    this.whiteGrey = Color(0xff455A64);
    this.black = Color(0xffffffff);
  }

  void switchToOrangeTheme() {
    this.currentTheme = Themes.ORANGE;
    this.primaryColor = Color(0xffFF5722);
    this.scaffoldBackColor = Color(0xffFBE9E7);
    this.accentColor = Color(0xff000000);
    this.secondaryColor = Color(0xffFFB74D);
    this.chartRed = Color(0xffDD2C00);
    this.chartGreen = Color(0xffAFB42B);
    this.white = Color(0xff000000);
    this.whiteGrey = Color(0xffE0E0E0);
    this.black = Color(0xffffffff);
  }

  void switchToDarkTheme() {
    this.currentTheme = Themes.DARK;
    this.primaryColor = Color(0xff39424e);
    this.scaffoldBackColor = Color(0xff39424e);
    this.accentColor = Color(0x4439424e);
    this.secondaryColor = Color(0xff24b557);
    this.chartRed = Color(0xffef5350);
    this.chartGreen = Color(0xff66BB6A);
    this.white = Color(0xffffffff);
    this.whiteGrey = Color(0xffE0E0E0);
    this.black = Color(0xff000000);
  }

  void switchToBell4GTheme() {
    this.currentTheme = Themes.BELL4G;
    this.primaryColor = Color(0xff52a2c7);
    this.scaffoldBackColor = Color(0xffffffff);
    this.accentColor = Color(0x4439424e);
    this.secondaryColor = Color(0xfff7d82f);
    this.chartRed = Color(0xffff0000);
    this.chartGreen = Color(0xff1B5E20);
    this.white = Color(0xff000000);
    this.whiteGrey = Color(0xff455A64);
    this.black = Color(0xffffffff);
  }

  void switchTheme() {
    switch (this.currentTheme) {
      case Themes.LIGHT:
        this.switchToOrangeTheme();
        break;
      case Themes.ORANGE:
        this.switchToDarkTheme();
        break;
      case Themes.DARK:
        this.switchToBell4GTheme();
        break;
      case Themes.BELL4G:
        this.switchToLightTheme();
        break;
    }
  }

  String get themeName {
    switch (this.currentTheme) {
      case Themes.LIGHT:
        return "Light Theme";
      case Themes.DARK:
        return "Dark Theme";
        break;
      case Themes.BELL4G:
        return "Bell 4G Theme";
        break;
      case Themes.ORANGE:
        return "Orange Theme";
        break;
      default:
        return "No Theme";
    }
  }

  IconData get themeIcon {
    switch (this.currentTheme) {
      case Themes.LIGHT:
        return FontAwesomeIcons.sun;
      case Themes.DARK:
        return FontAwesomeIcons.moon;
        break;
      case Themes.BELL4G:
        return FontAwesomeIcons.bell;
        break;
      case Themes.ORANGE:
        return FontAwesomeIcons.circle;
        break;
      default:
        return FontAwesomeIcons.circle;
    }
  }

  ThemeData get asTheme => ThemeData(
      primaryColor: this.primaryColor,
      accentColor: this.accentColor,
      primaryColorDark: this.secondaryColor,
      scaffoldBackgroundColor: this.scaffoldBackColor,
      iconTheme: IconThemeData(
        color: this.white,
      ),
      textTheme: TextTheme(
        body1: TextStyle(color: this.white),
        caption: TextStyle(color: this.white),
        subhead: TextStyle(color: this.white),
        button: TextStyle(color: this.white),
        body2: TextStyle(color: this.white),
        title: TextStyle(color: this.white),
      ),
      dialogBackgroundColor: this.primaryColor,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: this.white),
        hintStyle: TextStyle(color: this.whiteGrey),
        helperStyle: TextStyle(color: this.whiteGrey),
      ));

  ColorTheme();

  factory ColorTheme.lightTheme() {
    return ColorTheme()..switchToLightTheme();
  }

  factory ColorTheme.darkTheme() {
    return ColorTheme()..switchToDarkTheme();
  }
}
