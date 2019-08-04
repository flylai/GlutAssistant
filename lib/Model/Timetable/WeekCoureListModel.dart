import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:glutassistant/Utility/SQLiteUtil.dart';

class WeekCourseList with ChangeNotifier {
  List<dynamic> _dateList = [];
  int _selectedWeek = 1;
  int _currentWeek = 1;

  set selectedWeek(int selectedWeek) {
    if (_selectedWeek == selectedWeek) return;
    _selectedWeek = selectedWeek;
    refreshDateList();
    refreshTimetable();
  }

  set currentWeek(int currentWeek) {
    if (_currentWeek == currentWeek) return;
    _currentWeek = currentWeek;
  }

  int get selectedWeek => _selectedWeek;

  List<List<Map<String, dynamic>>> _weekCourse = [[], [], [], [], [], [], []];
  List<Map<String, dynamic>> _courseList = [];

  List<dynamic> get dateList => _dateList;
  List<Map<String, dynamic>> get courseList => _courseList;
  List<List<Map<String, dynamic>>> get weekCourse => _weekCourse;

  void refreshDateList() {
    _dateList.clear();
    int weekday = DateTime.now().weekday;
    DateTime day = DateTime.now()
        .add(Duration(days: (_selectedWeek - _currentWeek) * 7))
        .subtract(Duration(days: weekday));
    String month = '${day.add(Duration(days: weekday)).month}\n月';
    _dateList.add(month);

    for (int i = 1; i <= 7; i++) {
      DateTime today = day.add(Duration(days: i));
      String todayStr =
          today.day == DateTime.now().day && today.month == DateTime.now().month
              ? '今天'
              : today.day.toString();
      Color todayColor = todayStr == '今天' ? Color(0xffEF3473) : Colors.black;
      String weekdayStr =
          '周${BaseFunctionUtil().getWeekdayByNum(i)}\n$todayStr';
      _dateList.add({'color': todayColor, 'weekday': weekdayStr});
    }
  }

  Future<void> refreshTimetable() async {
    List<List<Map<String, dynamic>>> weekCourse = [[], [], [], [], [], [], []];
    SQLiteUtil su = await SQLiteUtil.getInstance();
    if (!su.dbIsOpen()) return;

    for (int i = 0; i < 7; i++) {
      weekCourse[i].clear();
      int count = 1;
      List<Map<String, dynamic>> queryResult =
          await su.queryCourse(_selectedWeek, i + 1);

      if (queryResult.length > 0) {
        for (int j = 0; j < queryResult.length; j++) {
          int startTime = queryResult[j]['startTime'];
          int endTime = queryResult[j]['endTime'];
          if (count < startTime) {
            double marginTop = 0.5 * (startTime - count - 1);
            double height = (Constant.VAR_COURSE_HEIGHT * (startTime - count));
            weekCourse[i].add({
              'empty': true,
              'marginTop': marginTop,
              'padding': 0.0,
              'color': Colors.transparent,
              'text': '',
              'height': height
            }); //没到有课的时间段 加个空白填充
            count += startTime - count;
          }
          if (count > startTime) continue;
          int colorIndex = Random.secure().nextInt(Constant.VAR_COLOR.length);
          double height =
              Constant.VAR_COURSE_HEIGHT * (endTime - startTime + 1);
          String text =
              '${queryResult[j]['courseName']}@${queryResult[j]['location']}';
          weekCourse[i].add({
            'empty': false,
            'marginTop': 0.5,
            'padding': 2.0,
            'color': Color(Constant.VAR_COLOR[colorIndex]),
            'text': text,
            'height': height,
            'weekday': i,
            'startTime': startTime,
            'endTime': endTime
          });
          count += endTime - startTime + 1;
        }
      } else {
        weekCourse[i].add({
          'empty': true,
          'marginTop': 0.0,
          'padding': 0.0,
          'color': Colors.transparent,
          'text': '',
          'height': Constant.VAR_COURSE_HEIGHT
        }); // 一整天没课 空白填充
      }
    }
    _weekCourse = weekCourse;
    notifyListeners();
  }

  Future<void> queryCourseList(int weekday, int startTime, int endTime) async {
    _courseList.clear();
    SQLiteUtil su = await SQLiteUtil.getInstance();
    if (!su.dbIsOpen()) return;

    List<Map<String, dynamic>> queryResult = await su.queryCourseByTime(
        _selectedWeek, weekday + 1, startTime, endTime);
    for (int i = 0; i < queryResult.length; i++) {
      _courseList.add({
        'courseName': queryResult[i]['courseName'],
        'teacher': queryResult[i]['teacher'],
        'location': queryResult[i]['location'],
        'week': '${queryResult[i]['startWeek']} - ${queryResult[i]['endWeek']}周'
      });
    }
  }
}
