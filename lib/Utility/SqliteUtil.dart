import 'package:glutassistant/Common/Constant.dart';
import 'package:sqflite/sqflite.dart';

class SqliteUtil {
  static final int _dbVersion = Constant.DB_VERSION;
  static final String _dbFileName = Constant.File_DB;
  static final String _dbTableName = Constant.VAR_TABLE_NAME;
  static String _dbPath;
  static var _db;
  static init() async {
    _dbPath = await getDatabasesPath();
    _dbPath = _dbPath + '/' + _dbFileName;
    _db = openDatabase(_dbPath, version: _dbVersion,
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

  static insertTimetable(Map coursedetail)
  {

  }
}
