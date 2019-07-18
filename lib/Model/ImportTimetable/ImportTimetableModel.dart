import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/FileUtil2.dart';
import 'package:glutassistant/Utility/HttpUtil.dart';
import 'package:glutassistant/Utility/SQLiteUtil2.dart';

class ImportTimetableModel with ChangeNotifier {
  int _year = DateTime.now().year;
  int _term = 2;
  bool _isLoading = false;
  String _msg = '';

  int get year => _year;
  int get term => _term;
  bool get isLoading => _isLoading;
  String get msg => _msg;

  set year(int year) {
    if (year == _year) return;
    _year = year;
    notifyListeners();
  }

  set term(int term) {
    if (term == _year) return;
    _term = term;
    notifyListeners();
  }

  Future<void> importTimetable() async {
    _isLoading = true;

    Map<String, dynamic> result;
    notifyListeners();

    FileUtil fp = await FileUtil.getInstance();
    String cookie = fp.readFile(Constant.FILE_SESSION);

    result = await HttpUtil()
        .importTimetable(_year.toString(), _term.toString(), cookie);

    if (result['success'] && result['data'].length > 0) {
      SQLiteUtil su = await SQLiteUtil.getInstance();
      await su.dropTable();
      await su.createTable();
      for (var item in result['data']) await su.insertTimetable(item);
      _msg = '课表导入成功了，请前往课程表界面查看';
    } else
      _msg = '获取得到的课表为空，请检查是否选对学年学期或者重新登录教务';

    _isLoading = false;
    notifyListeners();
  }
}
