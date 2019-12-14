import 'package:flutter/foundation.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/CourseManage/Course.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:glutassistant/Utility/SQLiteUtil.dart';

enum CourseState { waiting, finished }

class TodayCourse {
  final String courseName;
  final String teacher;
  final String location;
  final String classTime;
  final String startTimeStr;
  final String endTimeStr;
  final CourseState courseState;
  final String text1;
  final String text2;
  final String text3;

  TodayCourse(
      this.courseName,
      this.teacher,
      this.location,
      this.classTime,
      this.startTimeStr,
      this.endTimeStr,
      this.courseState,
      this.text1,
      this.text2,
      this.text3);
}

class TodayCourseList with ChangeNotifier {
  Map<String, dynamic> _todayCourseList = {'courseList': []};
  List<Course> _tomorrowCourseList = [];

  bool _isFirst = true;
  bool _isTodayCourseOver = false;

  bool get isTodayCourseOver => _isTodayCourseOver;

  Map<String, dynamic> get todayCourseList => _todayCourseList;
  List<Course> get tomorrowCourseList => _tomorrowCourseList;

  void init(currentWeek, weekday) async {
    if (!_isFirst) return;
    await refreshCourseList(currentWeek, weekday);
    await queryTomorrowCourseList(currentWeek, weekday);
    _isFirst = false;
  }

  Future<void> queryTomorrowCourseList(int currentWeek, int weekday) async {
    SQLiteUtil su = await SQLiteUtil.getInstance();
    List<Course> queryCourseList =
        await su.queryCourse(currentWeek, weekday + 1);
    _tomorrowCourseList = queryCourseList;
    notifyListeners();
  }

  Future<void> refreshCourseList(currentWeek, weekday) async {
    SQLiteUtil su = await SQLiteUtil.getInstance();
    List<Course> queryCourseList = await su.queryCourse(currentWeek, weekday);
    List<TodayCourse> courseList = [];
    DateTime nowDateTime = DateTime.now();
    int year = nowDateTime.year;
    int month = nowDateTime.month;
    int day = nowDateTime.day;

    int stepPosition = 0;
    bool isCheck = false; // 时间早于第一节课的判定

    for (int i = 0; i < queryCourseList.length; i++) {
      int startTime = queryCourseList[i].startTime;
      int endTime = queryCourseList[i].endTime;
      String startTimeStr = BaseFunctionUtil.getTimeByNum(startTime);
      String endTimeStr = BaseFunctionUtil.getTimeByNum(endTime);

      // 时间轴
      int classStartHour =
          Constant.CLASS_TIME[queryCourseList[i].startTime][0][0];
      int classStartMinute =
          Constant.CLASS_TIME[queryCourseList[i].startTime][0][1];

      int classEndHour = Constant.CLASS_TIME[queryCourseList[i].endTime][1][0];
      int classEndMinute =
          Constant.CLASS_TIME[queryCourseList[i].endTime][1][1];

      DateTime classBeginTime =
          DateTime(year, month, day, classStartHour, classStartMinute);
      DateTime classOverTime =
          DateTime(year, month, day, classEndHour, classEndMinute);
      String beforeClassBeginTime =
          BaseFunctionUtil.getDuration(classBeginTime, nowDateTime);
      String beforeClassOverTime =
          BaseFunctionUtil.getDuration(classOverTime, nowDateTime);

      String text1 = '';
      String text2 = '';
      String text3 = '';

      CourseState courseState = CourseState.waiting;
      if (beforeClassBeginTime[0] == '-' && beforeClassOverTime[0] != '-') {
        stepPosition = i;
        text1 = '还有 ';
        text2 = beforeClassOverTime;
        text3 = ' 才下课,认真听课哟~';
        isCheck = true;
      } else if (beforeClassBeginTime[0] != '-' && !isCheck) {
        stepPosition = i;
        isCheck = true;
        text1 = '还有 ';
        text2 = beforeClassBeginTime;
        text3 = ' 就要上课啦';
      } else if (beforeClassOverTime[0] == '-') {
        text1 = '这节课已经过去了哦';
        if (i + 1 == queryCourseList.length) {
          _isTodayCourseOver = true;
          stepPosition = i;
          text1 = '今天的课已经上完了哦';
          text2 = '';
          text3 = '';
        }
        courseState = CourseState.finished;
      }
      String classTime = '$startTimeStr - $endTimeStr节 ';
      String courseName = queryCourseList[i].courseName;
      String location = queryCourseList[i].location;
      String teacher = queryCourseList[i].teacher;
      courseList.add(TodayCourse(courseName, teacher, location, classTime,
          startTimeStr, endTimeStr, courseState, text1, text2, text3));
    }
    Map<String, dynamic> data = {
      'currentStep': stepPosition,
      'courseList': courseList
    };
    _todayCourseList = data;
    notifyListeners();
  }
}
