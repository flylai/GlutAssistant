import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtil {
  static SharedPreferences _pref;

  static SharedPreferenceUtil _instance;

  static Future<SharedPreferenceUtil> get instance async {
    return await getInstance();
  }

  SharedPreferenceUtil._();

  Future<bool> getBool(String field) async {
    var res = _pref.getBool(field);
    if (res == null) return false;
    return res;
  }

  Future<double> getDouble(String field) async {
    var res = _pref.getDouble(field);
    if (res == null) return 0.7;
    return res;
  }

  Future<int> getInt(String field) async {
    var res = _pref.getInt(field);
    if (res == null) return 0;
    return res;
  }

  Future<String> getString(String field) async {
    var res = _pref.getString(field);
    if (res == null) return '';
    return res;
  }

  Future init() async {
    if (_pref == null) _pref = await SharedPreferences.getInstance();
  }

  Future setBool(String field, bool contents) async {
    _pref.setBool(field, contents);
  }

  Future setDouble(String field, double contents) async {
    _pref.setDouble(field, contents);
  }

  Future setInt(String field, int contents) async {
    _pref.setInt(field, contents);
  }

  Future setString(String field, String contents) async {
    _pref.setString(field, contents);
  }

  static Future<SharedPreferenceUtil> getInstance() async {
    if (_instance == null) {
      _instance = new SharedPreferenceUtil._();
      await _instance.init();
    }
    return _instance;
  }
}
