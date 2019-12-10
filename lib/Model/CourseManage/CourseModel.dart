import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';

class SingleCourse with ChangeNotifier {
  int _courseNo;
  String _courseName;
  String _teacher;
  int _startWeek = 1;
  int _endWeek = 1;
  int _weekday = 1;
  String _weekType = 'A';
  int _startTime = 1;
  int _endTime = 1;
  String _location;

  String _weekTypeStr = '全';
  String _weekdayStr = '一';
  String _startTimeStr = '1';
  String _endTimeStr = '1';

  TextEditingController _courseNameController = TextEditingController();
  TextEditingController _teacherController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

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

  TextEditingController get courseNameController => _courseNameController;
  TextEditingController get teacherController => _teacherController;
  TextEditingController get locationController => _locationController;

  set courseNo(int courseNo) {
    if (_courseNo == courseNo) return;
    _courseNo = courseNo;
    notifyListeners();
  }

  set courseName(String courseName) {
    if (_courseName == courseName) return;
    _courseName = courseName;
    _courseNameController.text = _courseName;
    notifyListeners();
  }

  set teacher(String teacher) {
    if (_teacher == teacher) return;
    _teacher = teacher;
    _teacherController.text = _teacher;
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
    _weekdayStr = BaseFunctionUtil.getWeekdayByNum(_weekday);
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
    _startTimeStr = BaseFunctionUtil.getTimeByNum(_startTime);
    notifyListeners();
  }

  set endTime(int endTime) {
    if (_endTime == endTime) return;
    _endTime = endTime;
    _endTimeStr = BaseFunctionUtil.getTimeByNum(_endTime);
    notifyListeners();
  }

  set location(String location) {
    if (_location == location) return;
    _location = location == '' ? '未知地点' : location;
    _locationController.text = _location;
    notifyListeners();
  }

  SingleCourse();

  SingleCourse.fromJson(Map<String, dynamic> course) {
    _courseNo = course['courseNo'];
    _courseName = course['courseName'];
    _teacher = course['teacher'];
    _startWeek = course['startWeek'];
    _endWeek = course['endWeek'];
    weekday = course['weekday']; // 与众不同是因为要赋予xxStr的值，懒得写几次。
    weekType = course['weekType'];
    startTime = course['startTime'];
    endTime = course['endTime'];
    _location = course['location'];
    _courseNameController.text = _courseName;
    _teacherController.text = _teacher;
    _locationController.text = _location;
    notifyListeners();
  }

  @override
  String toString() {
    return 'CourseNo: $_courseNo, CourseName: $_courseName, Teacher: $_teacher, StartWeek: $_startWeek, EndWeek: $_endWeek, Weekday: $_weekday, WeekType: $_weekType, StartTime: $_startTime, EndTime: $_endTime, Location: $_location';
  }
}
