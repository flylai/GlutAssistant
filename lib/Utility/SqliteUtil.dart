import 'package:sqflite/sqflite.dart';

import 'package:glutassistant/Common/Constant.dart';

class SQLiteUtil {
  static final int _dbVersion = Constant.DB_VERSION;
  static final String _dbFileName = Constant.File_DB;
  static final String _dbTableName = Constant.VAR_TABLE_NAME;
  static String _dbPath;
  static Database _db;
  static init() async {
    _dbPath = await getDatabasesPath();
    _dbPath = _dbPath + '/' + _dbFileName;
    _db = await openDatabase(_dbPath, version: _dbVersion,
        onCreate: (Database db, int version) async {
      await db.execute(Constant.SQL_CREATE_TABLE);
    });
  }

  static isTableExist() async {
    var res = await _db.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '$_dbTableName'");
    return res != null && res.length > 0;
  }

  static void closeDb() {
    if (_db != null) _db.close();
    _db = null;
  }

  static insertTimetable(Map coursedetail) {
    return _db.insert(_dbTableName, coursedetail);
  }

  static Future createTable() async {
    await _db.execute(Constant.SQL_CREATE_TABLE);
  }

  static Future dropTable() async {
    await _db.execute(Constant.SQL_DROP_TABLE);
  }
}
