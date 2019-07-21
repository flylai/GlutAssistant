import 'package:flutter/foundation.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';

class SingleCourse with ChangeNotifier {
  int _courseNo;
  String _courseName;
  String _teacher;
  int _startWeek;
  int _endWeek;
  int _weekday;
  String _weekType;
  int _startTime;
  int _endTime;
  String _location;

  String _weekTypeStr = '';
  String _weekdayStr = '';
  String _startTimeStr = '';
  String _endTimeStr = '';

  int get courseNo => _courseNo;
  String get courseName => _courseName;
  String get teacher => _teacher;
  int get startWeek => _startWeek;
  int get endWeek => _endWeek;
  int get weekday => _weekday;
  String get weekType => _weekType;
  int get startTime => _startTime;
  int get endTime => _endTime;
  String get location => _location;

  String get weekTypeStr => _weekTypeStr;
  String get weekdayStr => _weekdayStr;
  String get startTimeStr => _startTimeStr;
  String get endTimeStr => _endTimeStr;

  set courseNo(int courseNo) {
    if (_courseNo == courseNo) return;
    _courseNo = courseNo;
    notifyListeners();
  }

  set courseName(String courseName) {
    if (_courseName == courseName) return;
    _courseName = courseName;
    notifyListeners();
  }

  set teacher(String teacher) {
    if (_teacher == teacher) return;
    _teacher = teacher;
    notifyListeners();
  }

  set startWeek(int startWeek) {
    if (_startWeek == startWeek) return;
    _startWeek = startWeek;
    notifyListeners();
  }

  set endWeek(int endWeek) {
    if (_endWeek == endWeek) return;
    _endWeek = endWeek;
    notifyListeners();
  }

  set weekday(int weekday) {
    if (_weekday == weekday) return;
    _weekday = weekday;
    _weekdayStr = BaseFunctionUtil().getWeekdayByNum(_weekday);
    notifyListeners();
  }

  set weekType(String weekType) {
    if (_weekType == weekType) return;
    _weekType = weekType;
    if (_weekType == 'D')
      _weekTypeStr = '双';
    else if (_weekType == 'S')
      _weekTypeStr = '单';
    else
      _weekTypeStr = '全';

    notifyListeners();
  }

  set startTime(int startTime) {
    if (_startTime == startTime) return;
    _startTime = startTime;
    _startTimeStr = BaseFunctionUtil().getWeekdayByNum(_startTime);
    notifyListeners();
  }

  set endTime(int endTime) {
    if (_endTime == endTime) return;
    _endTime = endTime;
    _endTimeStr = BaseFunctionUtil().getWeekdayByNum(_endTime);
    notifyListeners();
  }

  set location(String location) {
    if (_location == location) return;
    _location = location == '' ? '未知地点' : location;
    notifyListeners();
  }

  void fromMap(Map<String, dynamic> course) {
    _courseNo = course['No'];
    _courseName = course['courseName'];
    _teacher = course['teacher'];
    _startWeek = course['startWeek'];
    _endWeek = course['endWeek'];
    weekday = course['weekday'];
    weekType = course['weekType'];
    startTime = course['startTime'];
    endTime = course['endTime'];
    _location = course['location'];
    notifyListeners();
  }
}
