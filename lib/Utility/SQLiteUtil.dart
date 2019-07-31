import 'dart:async';

import 'package:glutassistant/Common/Constant.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteUtil {
  final int _dbVersion = Constant.DB_VERSION;
  final String _dbFileName = Constant.FILE_DB;
  final String _dbTableName = Constant.VAR_TABLE_NAME;

  static String _dbPath;
  static Database _db;
  static SQLiteUtil _instance;

  SQLiteUtil._();

  static Future<SQLiteUtil> get instance async {
    return await getInstance();
  }

  static Future<SQLiteUtil> getInstance() async {
    if (_instance == null) {
      _instance = new SQLiteUtil._();
      await _instance.init();
    }
    return _instance;
  }

  void closeDb() {
    if (_db != null) _db.close();
    _db = null;
  }

  Future createTable() async {
    await _db.execute(Constant.SQL_CREATE_TABLE);
  }

  bool dbIsOpen() {
    return _db == null ? false : true;
  }

  Future deleteCourse(int no) {
    return _db
        .delete(Constant.VAR_TABLE_NAME, where: 'No = ?', whereArgs: [no]);
  }

  Future dropTable() async {
    await _db.execute(Constant.SQL_DROP_TABLE);
  }

  init() async {
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

  insertTimetable(Map coursedetail) {
    return _db.insert(_dbTableName, coursedetail);
  }

  isTableExist() async {
    var res = await _db.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '$_dbTableName'");
    return res != null && res.length > 0;
  }

  Future<List<Map<String, dynamic>>> queryCourse(int week, int weekday) async {
    String weektype = week % 2 == 0 ? 'D' : 'S';
    String sql =
        'SELECT * FROM ${Constant.VAR_TABLE_NAME} WHERE startWeek <= "$week" AND endWeek >= "$week" AND location != "" AND (weekType = "A" OR weekType = "$weektype") AND weekday = $weekday ORDER BY startTime ASC';
    return _db.rawQuery(sql);
  }

  Future queryCourseByTime(
      int week, int weekday, int startTime, int endTime) async {
    String weektype = week % 2 == 0 ? 'D' : 'S';
    String sql =
        'SELECT * FROM ${Constant.VAR_TABLE_NAME} WHERE startWeek <= $week AND endWeek >= $week  AND location != "" AND (weekType = "A" OR weekType = "$weektype") AND weekday = $weekday AND startTime = $startTime AND endTime = $endTime ORDER BY startTime ASC';
    return _db.rawQuery(sql);
  }

  Future queryCourseList() {
    String sql = 'SELECT * FROM ${Constant.VAR_TABLE_NAME}';
    return _db.rawQuery(sql);
  }

  Future updateCourse(int no, Map coursedetail) {
    return _db
        .update(_dbTableName, coursedetail, where: 'No = ?', whereArgs: [no]);
  }
}
