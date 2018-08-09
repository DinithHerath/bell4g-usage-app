import 'dart:math' as math;

class Bell4GInfo {
  // Add fields
  double usedDataDay = 0.0;
  double remainingDataDay = 1.0;
  double usedDataNight = 0.0;
  double remainingDataNight = 1.0;

  String activatedPackage = "Loading";
  String totalOutstanding = "Loading";
  String packageValue = "Loading";
  String lastPaymentAmount = "Loading";
  String packageDownSpeed = "Download Upto: Loading";
  String packageUpSpeed = "Upload Upto: Loading";
  String lastPaymentDate = "Loading";

  String profileName = "Loading";
  String profileEmail = "Loading";
  String profileMobileNumber = "Loading";
  String profileAddress = "Loading";
  String profileDirectoryNumber = "Loading";
  String profileAccountNumber = "Loading";
  String profileActivePackage = "Loading";
  String profileNextBillDate = "Loading";
  String profileLoginName = "Loading";

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
    if (data > math.pow(10, 9)) {
      return "${data/math.pow(10, 9)} GB";
    } else if (data > math.pow(10, 6)) {
      return "${data/math.pow(10, 6)} MB";
    } else if (data > math.pow(10, 3)) {
      return "${data/math.pow(10, 3)} KB";
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
        return data * math.pow(10, 9);
      case "MB":
        return data * math.pow(10, 6);
      case "KB":
        return data * math.pow(10, 3);
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
    this.profileAccountNumber = data[16];
    this.profileActivePackage = data[19];
    this.profileNextBillDate = data[22];
    this.profileLoginName = data[31];
  }
}
