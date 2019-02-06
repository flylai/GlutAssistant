import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtil {
  static SharedPreferences _pref;

  static Future<bool> getBool(String field) async {
    return _pref.getBool(field);
  }

  static Future<int> getInt(String field) async {
    return _pref.getInt(field);
  }

  static Future<String> getString(String field) async {
    return _pref.getString(field);
  }

  static Future init() async {
    if (_pref == null) _pref = await SharedPreferences.getInstance();
  }

  static Future setBool(String field, bool contents) async {
    _pref.setBool(field, contents);
  }

  static Future setInt(String field, int contents) async {
    _pref.setInt(field, contents);
  }

  static Future setString(String field, String contents) async {
    _pref.setString(field, contents);
  }
}
