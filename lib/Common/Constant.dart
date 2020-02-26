import 'package:flutter/material.dart';

class Constant {
  static final String FILE_SESSION = "session";
  static final String FILE_SESSION_FITNESS = 'session_fitness';
  static final String FILE_SESSION_ATTENDANCE = 'session_attendance';
  static final String FILE_EXAM_LIST = "exam_location";
  static final String FILE_DATA_CAIWU = "caiwu_data";
  static final String FILE_DB = "db.db3";
  static final String FILE_BACKGROUND_IMG = "background";

  static final String VAR_COOKIE = ";x=1;";
  static final String VAR_TABLE_NAME = "classSchedule";
  static final int VAR_HTTP_TIMEOUT_MS = 6000;
  static final double VAR_COURSE_HEIGHT = 63.0;
  static final double VAR_DEFAULT_OPACITY = 0.7;
  static final String VAR_VERSION = '1.5.0';

  /// 每次启动检查更新标记
  static int VAR_UPDATE_CHECKED = 0;
  static final List<int> VAR_COLOR = [
    0x5CB3CC,
    0x4F383E,
    0xEC2D7A,
    0xFBA414,
    0x5BAE23,
    0x0F95B0,
    0x2E317C,
    0xEF3473,
    0x983680,
    0x2775B6,
    0x248067,
    0xBEC936,
    0xEEA08C,
    0xAD6598,
    0x1BA784,
  ];

  static final int DB_VERSION = 1;
  static final String SQL_CREATE_TABLE = "CREATE TABLE IF NOT EXISTS " +
      VAR_TABLE_NAME +
      " ( No INTEGER NOT NULL PRIMARY KEY, courseName TEXT NULL DEFAULT NULL, teacher TEXT NULL DEFAULT NULL, startWeek INT NOT NULL, endWeek INT NOT NULL,weekType TEXT NOT NULL, weekday INT, startTime INT, endTime INT, location TEXT, courseType TEXT)";
  static final String SQL_DROP_TABLE = "DROP TABLE IF EXISTS " + VAR_TABLE_NAME;

  static final String URL_JW_GLUT = "http://jw.glut.edu.cn";
  static final String URL_JW_GLUT_NN = "http://jw.glutnn.cn";

  static String URL_JW = URL_JW_GLUT; //教务全局变量 可更改

  static final String URL_LOGIN = "/academic/j_acegi_security_check";
  static final String URL_LOGIN_OA = "http://ca.glut.edu.cn:8888/zfca/login";
  static final String URL_VERIFY_CODE_JW = "/academic/getCaptcha.do";
  static final String URL_VERIFY_CODE_OA =
      "http://ca.glut.edu.cn:8888/zfca/captcha.htm";
  static final String URL_VERIFY_CODE_FITNESS =
      'http://tzcs.glut.edu.cn/servlet/UpdateDate?method=validateCode';
  static final String URL_VERIFY_CODE_ATTENDANCE =
      'http://xxfw.glut.edu.cn/kaoqin/rest/user/login/validateCodeServlet';
  static final String URL_OA_TO_JW =
      'http://ca.glut.edu.cn:8888/zfca/login?yhlx=all&login=0122579031373493708&url=index_new.jsp&gnmkdm=M011';
  static final String URL_GET_STUDENT_ID =
      "/academic/student/studentinfo/studentInfoModifyIndex.do?frombase=0&wantTag=0&groupId=&moduleId=2060";
  static final String URL_CLASS_SCHEDULE =
      "/academic/manager/coursearrange/showTimetable.do?timetableType=STUDENT&sectionType=BASE";
  static final String URL_CLASS_SCHEDULE_ALL =
      "/academic/student/currcourse/currcourse.jsdo";
  //     static final String URL_CLASS_SCHEDULE_ALL = "http://192.168.6.73/c/c.html";
  static final String URL_QUERY_SCORE =
      "/academic/manager/score/studentOwnScore.do?groupId=&moduleId=2020";
  static final String URL_QUERY_EXAMINATION_LOCATION =
      "/academic/student/exam/index.jsdo?stuid=";
  static final String URL_LOGIN_CAIWU =
      "http://cwjf.glut.edu.cn/interface/login";
  static final String URL_CAIWU_INTERFACE =
      "http://cwjf.glut.edu.cn/interface/index";
  static final String URL_FITNESS_TEST =
      'http://tzcs.glut.edu.cn/servlet/adminservlet';
  static final String URL_FIRNESS_TEST_INFO =
      'http://tzcs.glut.edu.cn/student/queryHealthInfo.jsp';

  /// 不登也能查啊
  static final String URL_FITNESS_TEST_LOGIN_WECHAT =
      'http://tzcs.glut.edu.cn/wxlogin?method=login';
  static final String URL_FITNESS_TEST_INFO_WECHAT =
      'http://tzcs.glut.edu.cn/spQuery';

  static final String URL_CHECK_UPDDATE =
      'https://raw.githubusercontent.com/flylai/GlutAssistant/master/version.json';

  static final LIST_DRAWER_GENERAL = [
    ['常用', Icons.book],
    ['一览', Icons.dashboard],
    ['课程表', Icons.date_range],
    ['查成绩', Icons.photo_library],
    ['查考试地点', Icons.location_on],
    ['导入课表', Icons.import_export],
    ['登录教务', Icons.slideshow]
  ];
  static final LIST_DRAWER_OTHER = [
    ['其他', Icons.book],
    ['设置', Icons.build],
    ['课程管理', Icons.create],
    ['FAQ', Icons.question_answer],
    ['关于', Icons.label],
  ];
  static final LIST_DRAWER = LIST_DRAWER_GENERAL + LIST_DRAWER_OTHER;
  static final LIST_THEME_COLOR = [
    ['什么黑', Colors.black],
    ['姨妈红', Colors.red],
    ['蓝绿色', Colors.teal],
    ['少女粉', Colors.pink],
    ['琥珀黄', Colors.amber],
    ['橘子黄', Colors.orange],
    ['原谅绿', Colors.green],
    ['大海蓝', Colors.blue],
    ['天空蓝', Colors.lightBlue],
    ['基佬紫', Colors.purple],
    ['桂工紫', Color(0xff1a1c81)],
    ['水绿色', Colors.cyan],
    ['马鞍棕', Colors.brown],
    ['石板灰', Colors.grey],
    ['火药蓝', Colors.blueGrey]
  ];
  static final LIST_SETTING_TITLE = [
    '学号',
    '教务密码',
    '当前周',
    '使用背景图',
    '选择背景图',
  ];
  static final LIST_LOGIN_TODO = [
    ['查成绩', Icons.photo_library, 3], // 第三个是页面标号
    ['查考试地点', Icons.location_on, 4],
    ['导入课表', Icons.import_export, 5]
  ];
  static final LIST_LOGIN_TITLE = [
    ['教务', 'password_JW', URL_JW_GLUT + URL_VERIFY_CODE_JW, FILE_SESSION],
    ['统一身份认证', 'password_OA', URL_VERIFY_CODE_OA, FILE_SESSION],
    [
      '南宁分校教务',
      'password_JW',
      URL_JW_GLUT_NN + URL_VERIFY_CODE_JW,
      FILE_SESSION
    ],
    // ['体测系统', 'password_FITNESS', URL_VERIFY_CODE_FITNESS, FILE_SESSION_FITNESS],
    // [
    //   '考勤系统',
    //   'password_ATTENDANCE',
    //   URL_VERIFY_CODE_ATTENDANCE,
    //   FILE_SESSION_ATTENDANCE
    // ],
  ];
  static final LIST_ABOUT_ITEM = [
    [Icons.update, '检查更新', 'https://www.coolapk.com/apk/com.lkm.glutassistant'],
    [Icons.code, 'GitHub', 'https://github.com/flylai/GlutAssistant']
  ];
  static final List<List<List<int>>> CLASS_TIME = [
    [
      // 雁山
      [00, 00],
      [00, 00],
      [08, 30],
      [09, 15],
      [09, 20],
      [10, 05],
      [10, 25],
      [11, 10],
      [11, 15],
      [12, 00],
      [12, 30],
      [13, 15],
      [13, 20],
      [14, 05],
      [14, 30],
      [15, 15],
      [15, 20],
      [16, 05],
      [16, 15],
      [17, 00],
      [17, 05],
      [17, 50],
      [18, 20],
      [19, 05],
      [19, 10],
      [19, 55],
      [20, 05],
      [20, 50],
      [20, 55],
      [21, 40],
    ],
    [
      // 屏风
      [00, 00],
      [00, 00],
      [08, 10],
      [08, 55],
      [09, 05],
      [09, 50],
      [10, 20],
      [11, 05],
      [11, 15],
      [12, 00],
      [12, 30], // 未知的屏风中午上课时间
      [13, 15],
      [13, 20],
      [14, 05], // 结束
      [14, 30],
      [15, 15],
      [15, 25],
      [16, 10],
      [16, 20],
      [17, 05],
      [17, 15],
      [18, 00],
      [18, 30],
      [19, 15],
      [19, 25],
      [20, 10],
      [20, 20],
      [21, 05],
      [21, 15],
      [22, 00]
    ]
  ];
}
