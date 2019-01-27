import 'package:flutter/material.dart';

class Constant {
  static final String FILE_SESSION = "Session";
  static final String File_DB = "db.db3";
  static final String FILE_BACKGROUND_IMG = "background";

  static final String VAR_COOKIE = ";x=1;";
  static final String VAR_TABLE_NAME = "classSchedule";
  static final int VAR_HTTP_TIMEOUT_MS = 2000;

  static final int DB_VERSION = 1;
  static final String SQL_CREATE_TABLE = "CREATE TABLE IF NOT EXISTS " +
      VAR_TABLE_NAME +
      " ( No INTEGER NOT NULL PRIMARY KEY, courseName TEXT NULL DEFAULT NULL, teacher TEXT NULL DEFAULT NULL, startWeek INT NOT NULL, endWeek INT NOT NULL,weekType TEXT NOT NULL, weekday INT, startTime INT, endTime INT, location TEXT, courseType TEXT)";
  static final String SQL_DROP_TABLE = "DROP TABLE IF EXISTS " + VAR_TABLE_NAME;

  static final String URL_LOGIN =
      "http://202.193.80.58/academic/j_acegi_security_check";
  static final String URL_VERIFY_CODE =
      "http://202.193.80.58/academic/getCaptcha.do";
  static final String URL_GET_STUDENT_ID =
      "http://202.193.80.58/academic/student/studentinfo/studentInfoModifyIndex.do?frombase=0&wantTag=0&groupId=&moduleId=2060";
  static final String URL_CLASS_SCHEDULE =
      "http://202.193.80.58/academic/manager/coursearrange/showTimetable.do?timetableType=STUDENT&sectionType=BASE";
  static final String URL_CLASS_SCHEDULE_ALL =
      "http://202.193.80.58/academic/student/currcourse/currcourse.jsdo";
  //     static final String URL_CLASS_SCHEDULE_ALL = "http://192.168.6.73/c/c.html";
  static final String URL_QUERY_SCORE =
      "http://202.193.80.58/academic/manager/score/studentOwnScore.do?groupId=&moduleId=2020";
  static final String URL_QUERY_EXAMINATION_LOCATION =
      "http://202.193.80.58/academic/student/exam/index.jsdo?stuid=";

  static final DRAWER_MAIN_LIST_TITLE = [
    '常用',
    '一览',
    '课程表',
    '查成绩',
    '查考试地点',
    '导入课表',
    '登录教务',
  ];
  static final DRAWER_OTHER_LIST_TITLE = ['其他', '设置', '分享', '关于'];
  static final DRAWER_LIST_TITLE =
      DRAWER_MAIN_LIST_TITLE + DRAWER_OTHER_LIST_TITLE;
  static final DRAWER_LIST_ICON = [
    Icons.book,
    Icons.dashboard, //总览
    Icons.date_range, //课程表
    Icons.photo_library, //成绩
    Icons.location_on, //考试地点
    Icons.import_export, //导入课表
    Icons.slideshow, //教务登录
    Icons.book,
    Icons.build, //设置
    Icons.share, //分享
    Icons.label //关于
  ];
}
