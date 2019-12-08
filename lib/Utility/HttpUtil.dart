import 'dart:convert';
import 'dart:core';

import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:http/http.dart' as http;

class HttpUtil {
  Future<Map<String, dynamic>> getCode({bool isOA = false}) async {
    String verifyCodeURL = Constant.URL_JW + Constant.URL_VERIFY_CODE;
    if (isOA) verifyCodeURL = Constant.URL_VERIFY_CODE_OA;
    try {
      var response = await http
          .post(verifyCodeURL)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
      var data = {
        'cookie': response.headers['set-cookie'].split(';')[0],
        'image': base64.encode(response.bodyBytes)
      };
      return {'success': true, 'data': data};
    } catch (e) {
      return {'success': false, 'data': e};
    }
  }

  Future<Map<String, dynamic>> importTimetable(
      String year, String term, String cookie) async {
    int _year = int.parse(year) - 1980;
    if (term == '2' && Constant.URL_JW == Constant.URL_JW_GLUT_NN)
      term = '3'; // 南宁分校秋季是3
    var head = {'cookie': cookie};
    try {
      var response = await http
          .get(
              Constant.URL_JW +
                  Constant.URL_CLASS_SCHEDULE_ALL +
                  '?term=' +
                  term +
                  '&year=' +
                  _year.toString(),
              headers: head)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
      List<Map> courseList = new List();
      String html =
          gbk.decode(response.bodyBytes).replaceAll(RegExp(r'\s'), '');
      RegExp courseListExp = RegExp(
          r'infolist_common"onmouseover="(.*?)</a></td></tr>',
          caseSensitive: false);
      Iterable<Match> courseListMatches = courseListExp.allMatches(html);
      for (var courseListItem in courseListMatches) {
        RegExp teacherExp = RegExp(
            r'class="infolist">(.*?)</a></td>(.*?)arget=(.*?)</a><br></td>'); //课程 & 老师
        Iterable<Match> teacherMatches =
            teacherExp.allMatches(courseListItem.group(0));
        for (var teacherListItem in teacherMatches) {
          //1课程名 3老师 3多老师时候匹配异常 用0进行匹配老师
          RegExp timeHTMLExp = RegExp(
              r'class="none"><tr><tdwid(.*?)</td></tr></table></td>',
              caseSensitive: false); //匹配时间
          Iterable<Match> timeHTMLMatches =
              timeHTMLExp.allMatches(courseListItem.group(0));
          for (var timeHTMLListItem in timeHTMLMatches) {
            RegExp timeExp = RegExp(
                r'nowrap>(.*?)</td>.*?nowrap>(.*?)</td>.*?nowrap>(.*?)</td>.*?nowrap>(.*?)</td>',
                caseSensitive: false);
            Iterable<Match> timeMatches = timeExp.allMatches(timeHTMLListItem
                .group(0)
                .replaceAll(RegExp(r'周|第|节|&nbsp;'), '')
                .replaceAll(RegExp(r'中午1'), '100')
                .replaceAll(RegExp(r'中午2'), '200'));
            for (var timeListItem in timeMatches) {
              //详细上课时间 1为 第几周上 2为星期几 3为第几节 4为上课地点
              int startTime = 0, endTime = 0, startWeek = 0, endWeek = 0;
              int weekDay = BaseFunctionUtil.getNumByWeekday(timeListItem[2]);
              String weekType = 'A';
              String location = timeListItem.group(4);
              String courseName = teacherListItem.group(1);
              String teacher = teacherListItem
                  .group(0)
                  .replaceAllMapped(
                      RegExp('.*?k\'>(.*?)</a>.*?', caseSensitive: false),
                      (Match m) => "${m[1]},")
                  .replaceAll(RegExp(',<.*>'), '');
              if (timeListItem.group(1).contains('单')) weekType = 'S';
              if (timeListItem.group(1).contains('双')) weekType = 'D';
              List<String> weekByComma = timeListItem
                  .group(1)
                  .replaceAll(RegExp(r'[单双]'), '')
                  .split(',');
              List<String> timeByHyphen = timeListItem.group(3).split('-');
              List<String> timeByDot = timeListItem.group(3).split('、');
              //判断上课时间 第X节
              if (timeByDot.length > 1) {
                if (int.parse(timeByDot[1]) - int.parse(timeByDot[0]) == 1) {
                  startTime = int.parse(timeByDot[0]);
                  endTime = int.parse(timeByDot[1]);
                }
              } else if (timeByHyphen.length > 1) {
                startTime = int.parse(timeByHyphen[0]);
                endTime = int.parse(timeByHyphen[1]);
              } else if (timeListItem.group(3) == '中午') { // 奇葩写法 中午两节课直接写中午
                startTime = 100;
                endTime = 200;
              }

              //对5,6节特殊处理 变7 8节
              startTime = (startTime >= 5 && startTime <= 16)
                  ? (startTime + 2)
                  : startTime;
              endTime =
                  (endTime >= 5 && endTime <= 16) ? (endTime + 2) : endTime;
              //对中午12特殊处理 变56节
              startTime = startTime == 100 ? 5 : startTime;
              endTime = endTime == 100 ? 5 : endTime;
              startTime = startTime == 200 ? 6 : startTime;
              endTime = endTime == 200 ? 6 : endTime;
              //判断周
              if (weekByComma.length > 1) {
                for (String _weekByComma in weekByComma) {
                  List<String> weekByHyphen = _weekByComma.split('-');
                  if (weekByHyphen.length > 1) {
                    startWeek = int.parse(weekByHyphen[0]);
                    endWeek = int.parse(weekByHyphen[1]);
                  } else
                    startWeek = endWeek = int.parse(weekByHyphen[0]);
                  Map<String, dynamic> courseDetail = new Map();
                  courseDetail['courseName'] = courseName;
                  courseDetail['teacher'] = teacher;
                  courseDetail['startWeek'] = startWeek;
                  courseDetail['endWeek'] = endWeek;
                  courseDetail['weekType'] = weekType;
                  courseDetail['weekday'] = weekDay;
                  courseDetail['startTime'] = startTime;
                  courseDetail['endTime'] = endTime;
                  courseDetail['location'] = location;
                  courseList.add(courseDetail);
                }
              } else {
                List<String> weekByHyphen = timeListItem
                    .group(1)
                    .replaceAll(RegExp(r'[单双]'), '')
                    .split('-');
                if (weekByHyphen.length > 1) {
                  startWeek = int.parse(weekByHyphen[0]);
                  endWeek = int.parse(weekByHyphen[1]);
                } else
                  startWeek = endWeek =
                      int.parse(timeListItem.group(1).replaceAll("[单双]", ""));
                Map<String, dynamic> courseDetail = new Map();
                courseDetail['courseName'] = courseName;
                courseDetail['teacher'] = teacher;
                courseDetail['startWeek'] = startWeek;
                courseDetail['endWeek'] = endWeek;
                courseDetail['weekType'] = weekType;
                courseDetail['weekday'] = weekDay;
                courseDetail['startTime'] = startTime;
                courseDetail['endTime'] = endTime;
                courseDetail['location'] = location;
                courseList.add(courseDetail);
              }
            }
          }
        }
      }
      return {'success': true, 'data': courseList};
    } catch (e) {
      return {'success': false, 'data': e};
    }
  }

  Future<Map<String, dynamic>> loginCW(
      String studentId, String password) async {
    try {
      var postData = {
        'sid': studentId,
        'passWord': password,
      };
      var response = await http
          .post(Constant.URL_LOGIN_CAIWU, body: postData)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
      if (response.headers.containsKey('set-cookie'))
        return {
          'success': true,
          'cookie': response.headers['set-cookie'].split(';')[0]
        };
      else
        return {'success': false, 'cookie': ''};
    } catch (e) {
      return {'success': false, 'cookie': ''};
    }
  }

  Future<Map<String, dynamic>> loginJW(String studentId, String password,
      String verifyCode, String cookie) async {
    try {
      var head = {'cookie': cookie};
      var postData = {
        "j_username": studentId,
        "j_password": password,
        "j_captcha": verifyCode.trim().toString()
      };
      print(postData);
      print(head);
      var response = await http
          .post(Constant.URL_JW + Constant.URL_LOGIN,
              body: postData, headers: head)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
      if (response.headers['location'].contains('index_new'))
        return {
          'success': true,
          'cookie': response.headers['set-cookie'].split(';')[0]
        };
      else
        return {'success': false, 'cookie': ''};
    } catch (e) {
      return {'success': false, 'cookie': ''};
    }
  }

  Future<Map<String, dynamic>> loginOA(String studentId, String password,
      String verifyCode, String cookie) async {
    var head = {'cookie': cookie};
    try {
      var responseLt = await http
          .post(Constant.URL_LOGIN_OA, headers: head)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
      RegExp ltExp = RegExp('name="lt" value="(.*)"');
      RegExpMatch ltMatch = ltExp.firstMatch(responseLt.body);

      String lt = ltMatch.group(1);
      Map postData = {
        '_eventId': 'submit',
        'j_captcha_response': verifyCode,
        'lt': lt,
        'password': password,
        'useValidateCode': '1',
        'username': studentId
      };
      // 这谜一样的统一身份认证要跳转3次
      // 先登录统一身份认证
      var response = await http
          .post(Constant.URL_LOGIN_OA, body: postData, headers: head)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
      if (response.body == '') {
        // 登录成功
        // 第一次跳转 获取乱七八糟的认证信息
        response = await http.post(Constant.URL_OA_TO_JW, headers: head);
        // 第二次跳转登录教务
        response = await http.post(response.headers['location']);
        head = {'cookie': (response.headers['set-cookie'].split(';'))[0]};
        // 第三次跳转带着验证码和验证码cookie登录到教务并返回cookie，一般都是登录成功
        response = await http.post(response.headers['location'], headers: head);
        if (response.headers['location'].contains('index_new'))
          return {
            'success': true,
            'cookie': response.headers['set-cookie'].split(';')[0]
          };
        else
          return {'success': false, 'cookie': ''};
      }
    } catch (e) {
      return {'success': false, 'cookie': ''};
    }
    return {'success': false, 'cookie': ''};
  }

  Future<Map<String, dynamic>> queryBalance(String studentId) async {
    try {
      var postData = {
        'method': 'getecardinfo',
        'stuid': '0',
        'carno': studentId
      };
      var response = await http
          .post(Constant.URL_CAIWU_INTERFACE, body: postData)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
      if (response.body.contains('true')) {
        Map<String, dynamic> json = jsonDecode(response.body);
        String balance = json['data']['Balance'];
        return {'success': true, 'balance': balance};
      } else
        return {'success': false, 'balance': ''};
    } catch (e) {
      return {'success': false, 'balance': ''};
    }
  }

  Future<Map<String, dynamic>> queryExamLocation(String cookie) async {
    var head = {'cookie': cookie};
    try {
      var response = await http
          .get(Constant.URL_JW + Constant.URL_QUERY_EXAMINATION_LOCATION,
              headers: head)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
      List<Map> examList = new List();
      String html = gbk
          .decode(response.bodyBytes)
          .replaceAll(RegExp(r'\s'), '')
          .replaceAll('&nbsp;', '');
      RegExp examHTMLExp =
          RegExp(r'class="infolist_tab">(.*?)</table>', caseSensitive: false);
      Iterable<Match> examHTMLMatches = examHTMLExp.allMatches(html);
      RegExp examDetailExp = RegExp(
          r'class="infolist_common"><td>(\d+?)</td><td>(.*?)</td><td>(\d{4}-\d{2}-\d{2})(\d{2}:\d{2}--\d{2}:\d{2})</td><td>(.*?)</td><!--<td></td>--><td>(.*?)</td>',
          caseSensitive: false);
      // if (examHTMLMatches.length > 0) {
      Iterable<Match> examDetailMatches =
          examDetailExp.allMatches(examHTMLMatches.first.group(0));
      for (var examDetail in examDetailMatches) {
        //1课程号 2课程名 3考试时间(天) 4考试时间(区间) 5考试地点 6考核方式
        Map<String, dynamic> exam = {};
        exam['course'] = examDetail.group(2);
        exam['datetime'] = examDetail.group(3);
        exam['interval'] = examDetail.group(4);
        exam['location'] = examDetail.group(5);
        exam['type'] = examDetail.group(6);
        examList.add(exam);
      }
      if (examList.length > 0) {
        return {'success': true, 'data': examList};
      } else {
        return {'success': false, 'data': ''};
      }
    } catch (e) {
      return {'success': false, 'data': e};
    }
  }

  Future<Map<String, dynamic>> queryFitnessTestScore(String studentId) async {
    var postData = {
      'operType': '911',
      'loginflag': '0',
      'loginType': '0',
      'userName': studentId,
      'passwd': studentId
    };
    try {
      var response = await http
          .post(Constant.URL_FITNESS_TEST, body: postData)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));

      String cookie = response.headers['set-cookie'];
      var head = {'cookie': cookie.split(';')[0]};

      var res = await http
          .get(
              'http://tzcs.glut.edu.cn/student/studentInfo.jsp?userName=' +
                  studentId +
                  '&passwd=' +
                  studentId,
              headers: head)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));

      var responsex = await http
          .get(Constant.URL_FIRNESS_TEST_INFO, headers: head)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
      String html =
          responsex.body.replaceAll(RegExp(r'\s'), '').replaceAll('&nbsp;', '');

      RegExp resultExp = RegExp(
          r'align="center"><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><tdrowspan="16">(.*?)</td><tdrowspan="16">(.*?)</td><tdalign="center"rowspan="16">(.*?)</td><tdalign="center"rowspan="16">(.*?)</td>',
          caseSensitive: false);

      List<Map> fitnessList = new List();
      Map<String, String> result = {};

      Iterable<Match> resultMatches = resultExp.allMatches(html);
      for (var item in resultMatches) {
        // 1项目 2成绩 3分数 4结论 5加分 6减分 7总成绩 8总结论
        Map<String, String> fitnessDetail = {};
        fitnessDetail['name'] = item.group(1);
        fitnessDetail['record'] = item.group(2);
        fitnessDetail['score'] = item.group(3);
        fitnessDetail['result'] = item.group(4);
        fitnessList.add(fitnessDetail);

        // 结论
        result['add'] = item.group(5);
        result['subtraction'] = item.group(6);
        result['total'] = item.group(7);
        result['conclusion'] = item.group(8);
      }

      RegExp itemExp = RegExp(
          r'<tdalign="center">(.*?)</td><tdalign="center">(.*?)</td><tdalign="center">(.*?)</td><tdalign="center">(.*?)</td>',
          caseSensitive: false);
      Iterable<Match> itemMatches = itemExp.allMatches(html);

      for (var item in itemMatches) {
        // 1项目 2成绩 3分数 4结论
        Map<String, String> fitnessDetail = {};
        fitnessDetail['name'] = item.group(1);
        fitnessDetail['record'] = item.group(2);
        fitnessDetail['score'] = item.group(3);
        fitnessDetail['result'] = item.group(4);
        fitnessList.add(fitnessDetail);
      }

      return {'success': true, 'data': fitnessList, 'result': result};
    } catch (e) {
      return {'success': false, 'data': e};
    }
  }

  Future<Map<String, dynamic>> queryScore(
      String year, String term, String cookie) async {
    int _year = int.parse(year) - 1980;
    var head = {'cookie': cookie};
    RegExp scoreExp = RegExp(r'');
    if (Constant.URL_JW == Constant.URL_JW_GLUT)
      scoreExp = RegExp(
          r'<td>[春秋]</td>.*?<td>\d+?</td><td>(.*?)</td><td>\d+?</td><td>(.*?)</td><td>(.*?)</td><td>(\d?\.\d?)</td>',
          caseSensitive: false);
    else {
      scoreExp = RegExp(
          r'<td>[春秋]</td><td>.*?</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td>',
          caseSensitive: false);
      term = term == '2' ? '3' : '1'; // 南宁分校秋季学期是3
    }
    var postData = {'year': _year.toString(), 'term': term, 'para': '0'};
    try {
      var response = await http.post(Constant.URL_JW + Constant.URL_QUERY_SCORE,
          body: postData, headers: head);
      List<Map> scoreList = new List();
      String html = response.body.replaceAll(RegExp(r'\s'), '');
      Iterable<Match> scoreMatches = scoreExp.allMatches(html);
      for (var scoreListItem in scoreMatches) {
        Map<String, String> scoredetail = new Map();
        scoredetail['course'] = scoreListItem.group(1);
        scoredetail['teacher'] = scoreListItem.group(2);
        scoredetail['score'] = scoreListItem.group(3);
        scoredetail['gpa'] = scoreListItem.group(4); // 南宁分校此处是学分
        scoreList.add(scoredetail);
      }
      return {'success': true, 'data': scoreList};
    } catch (e) {
      return {'success': false, 'data': e};
    }
  }

  // static _getStudentId(String cookie, Function callback) async {
  //   var head = {'cookie': cookie};
  //   var response = await http.get(Constant.URL_GET_STUDENT_ID, headers: head);
  //   RegExp exp = RegExp(r'name="stuUserId" value="(\d+?)">');
  //   Iterable<Match> matches = exp.allMatches(response.body);
  //   callback(matches.first.group(1));
  // }
}
