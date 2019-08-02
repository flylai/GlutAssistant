import 'package:flutter/foundation.dart';
import 'package:glutassistant/Utility/SQLiteUtil.dart';

class TodayCourseList with ChangeNotifier {
  List<Map<String, dynamic>> _courseList = [];

  bool isFirst = true;

  List<Map<String, dynamic>> get courseList => _courseList;

  Future refreshCourseList(currentWeek, weekday) async {
    SQLiteUtil su = await SQLiteUtil.getInstance();
    _courseList = await su.queryCourse(currentWeek, weekday);

    notifyListeners();
  }

  void init(currentWeek, weekday) {
    if (!isFirst) return;
    refreshCourseList(currentWeek, weekday);
    isFirst = false;
  }
}
