import 'dart:async';

import 'package:glutassistant/Common/Constant.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteUtil {
  static final int _dbVersion = Constant.DB_VERSION;
  static final String _dbFileName = Constant.File_DB;
  static final String _dbTableName = Constant.VAR_TABLE_NAME;
  static String _dbPath;
  static Database _db;
  static void closeDb() {
    if (_db != null) _db.close();
    _db = null;
  }

  static Future createTable() async {
    await _db.execute(Constant.SQL_CREATE_TABLE);
  }

  static bool dbIsOpen() {
    return _db == null ? false : true;
  }

  static Future dropTable() async {
    await _db.execute(Constant.SQL_DROP_TABLE);
  }

  static init() async {
    if (_dbPath == null) {
      _dbPath = await getDatabasesPath();
      _dbPath = _dbPath + '/' + _dbFileName;
    }
    if (_db == null)
      _db = await openDatabase(_dbPath, version: _dbVersion,
          onCreate: (Database db, int version) async {
        await db.execute(Constant.SQL_CREATE_TABLE);
      });
  }

  static insertTimetable(Map coursedetail) {
    return _db.insert(_dbTableName, coursedetail);
  }

  static isTableExist() async {
    var res = await _db.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '$_dbTableName'");
    return res != null && res.length > 0;
  }

  static Future queryCourse(int week, int weekday) async {
    String weektype = week % 2 == 0 ? 'D' : 'S';
    String sql =
        'SELECT * FROM ${Constant.VAR_TABLE_NAME} WHERE startWeek <= "$week" AND endWeek >= "$week" AND location != "" AND (weekType = "A" OR weekType = "$weektype") AND weekday = $weekday ORDER BY startTime ASC';
    return _db.rawQuery(sql);
  }
}
