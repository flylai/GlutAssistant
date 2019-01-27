import 'dart:convert';
import 'dart:core';

import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:http/http.dart' as http;

import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';

class HttpUtil {
  static getCode(Function callback) async {
    try {
      var response = await http
          .post(Constant.URL_VERIFY_CODE)
          .timeout(Duration(milliseconds: 2));
      var data = {
        'cookie': response.headers['set-cookie'].split(';')[0],
        'image': base64.encode(response.bodyBytes)
      };
      callback({'success': true, 'data': data});
    } catch (e) {
      callback({'success': false, 'data': e});
    }
  }

  static loginJW(String studentId, String password, String verifyCode,
      String cookie, Function callback) async {
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
          .post(Constant.URL_LOGIN, body: postData, headers: head)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
      if (response.headers['location'].contains('index_new'))
        callback({
          'success': true,
          'cookie': response.headers['set-cookie'].split(';')[0]
        });
      else
        callback({'success': false, 'cookie': ''});
    } catch (e) {
      callback({'success': false, 'cookie': ''});
      print('err' + e);
    }
  }

  static _getStudentId(String cookie, Function callback) async {
    var head = {'cookie': cookie};
    var response = await http.get(Constant.URL_GET_STUDENT_ID, headers: head);
    RegExp exp = RegExp(r'name="stuUserId" value="(\d+?)">');
    Iterable<Match> matches = exp.allMatches(response.body);
    callback(matches.first.group(1));
  }

  static importTimetable(
      String year, String term, String cookie, Function callback) async {
    int _year = int.parse(year) - 1980;
    var head = {'cookie': cookie};
    try {
      var response = await http
          .get(
              Constant.URL_CLASS_SCHEDULE_ALL +
                  '?term=' +
                  term +
                  '&year=' +
                  _year.toString(),
              headers: head)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
      List<Map> courseList = new List();
      String html = decodeGbk(response.bodyBytes).replaceAll(RegExp(r'\s'), '');
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
              int weekDay = BaseFunctionUtil.getNumByWeekDay(timeListItem[2]);
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
                } else {
                  if (timeByHyphen.length > 1) {
                    startTime = int.parse(timeByHyphen[0]);
                    endTime = int.parse(timeByHyphen[1]);
                  }
                }
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
      callback({'success': true, 'data': courseList});
    } catch (e) {
      callback({'success': false, 'data': e});
    }
  }

  static queryScore(
      String year, String term, String cookie, Function callback) async {
    print('queryScaore');
    int _year = int.parse(year) - 1980;
    var head = {'cookie': cookie};
    var postData = {'year': _year.toString(), 'term': term, 'para': '0'};
    try {
      var response = await http
          .post(Constant.URL_QUERY_SCORE, body: postData, headers: head)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
      List<Map> scoreList = new List();
      String html = response.body.replaceAll(RegExp(r'\s'), '');
      RegExp scoreExp = RegExp(
          r'<td>[春秋]</td>.*?<td>\d+?</td><td>(.*?)</td><td>\d+?</td><td>(.*?)</td><td>(.*?)</td><td>(\d?\.\d?)</td>',
          caseSensitive: false);
      Iterable<Match> scoreMatches = scoreExp.allMatches(html);
      for (var scoreListItem in scoreMatches) {
        Map<String, String> scoredetail = new Map();
        scoredetail['course'] = scoreListItem.group(1);
        scoredetail['teacher'] = scoreListItem.group(2);
        scoredetail['score'] = scoreListItem.group(3);
        scoredetail['gpa'] = scoreListItem.group(4);
        scoreList.add(scoredetail);
      }
      callback({'success': true, 'data': scoreList});
    } catch (e) {
      callback({'success': false, 'data': e});
    }
  }
}
