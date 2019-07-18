import 'package:flutter/foundation.dart';
import 'package:glutassistant/Utility/SQLiteUtil2.dart';
import 'package:glutassistant/Utility/SPUtil.dart';

class CourseList with ChangeNotifier {
  int _dashboardType = 0;
  int _firstWeek;
  String _firstWeekTimestamps;
  int _startWeek;
  int _currentWeek = 1;
  List<Map<String, dynamic>> _courseList = [];

  bool isFirst = true;

  int get displayType => _dashboardType;
  List<Map<String, dynamic>> get courseList => _courseList;

  Future refreshCourseList() async {
    SharedPreferenceUtil sp = await SharedPreferenceUtil.getInstance();
    _dashboardType = await sp.getInt('dashboard_type');
    SQLiteUtil su = await SQLiteUtil.getInstance();
    _courseList = await su.queryCourse(8, 3);

    notifyListeners();
  }

  void init() {
    if (!isFirst) return;
    refreshCourseList();
    isFirst = false;
  }
}
