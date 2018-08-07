import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DataPersist {
  // Saved data keys
  static String usernameSaveKey = "username";
  static String passwordSaveKey = "password";
  static String themeKey = "theme";

  /// Initialixe [FlutterSecureStorage]
  FlutterSecureStorage storage = FlutterSecureStorage();

  void deleteData({bool userdata = false, bool themedata = false}) {
    FlutterSecureStorage storage = FlutterSecureStorage();
    if (userdata) {
      storage.delete(key: usernameSaveKey);
      storage.delete(key: passwordSaveKey);
    }
    if (themedata) {
      storage.delete(key: themeKey);
    }
  }

  void saveData({String username, String password, String themedata}) {
    FlutterSecureStorage storage = FlutterSecureStorage();
    if (username != null) storage.write(key: usernameSaveKey, value: username);
    if (username != null) storage.write(key: passwordSaveKey, value: password);
    if (themedata != null) storage.write(key: themeKey, value: themedata);
  }

  Future<String> readData(String key) async {
    String value = await storage
        .read(key: key)
        .timeout(Duration(milliseconds: 200), onTimeout: () => null);
    return value;
  }
}
