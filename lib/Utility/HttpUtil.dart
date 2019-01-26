import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;

import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';

class HttpUtil {
  static getCode(Function callback) async {
    try {
      var response = await http
          .post(Constant.URL_VERIFY_CODE)
          .timeout(Duration(seconds: 2));
      var data = {
        'cookie': response.headers['set-cookie'].split(';')[0],
        'image': base64.encode(response.bodyBytes)
      };
      callback(data);
    } catch (e) {
      return e;
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
          .timeout(Duration(seconds: 2));
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
    print(cookie);
    RegExp exp = RegExp(r'name="stuUserId" value="(\d+?)">');
    Iterable<Match> matches = exp.allMatches(response.body);
    callback(matches.first.group(1));
  }

  static importTimeTable(
      String year, String term, String cookie, Function callback) async {
    int _year = int.parse(year) - 1980;
    var head = {'cookie': cookie};
    var response = await http.get(
        'http://192.168.1.101/' + '?term=' + term + '&year=' + _year.toString(),
        headers: head);
    List<Map> courseList = new List();

    String html = response.body.toString().replaceAll(RegExp(r'\s'), '');
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
            endTime = (endTime >= 5 && endTime <= 16) ? (endTime + 2) : endTime;
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
                Map courseDetail = new Map();
                courseDetail['courseName'] = courseName;
                courseDetail['teacher'] = teacher;
                courseDetail['weekday'] = weekDay;
                courseDetail['weekType'] = weekType;
                courseDetail['location'] = location;
                courseDetail['startTime'] = startTime;
                courseDetail['endTime'] = endTime;
                courseList.add(courseDetail);
                //此处回调db insert
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
              Map courseDetail = new Map();
              courseDetail['courseName'] = courseName;
              courseDetail['teacher'] = teacher;
              courseDetail['weekday'] = weekDay;
              courseDetail['weekType'] = weekType;
              courseDetail['location'] = location;
              courseDetail['startTime'] = startTime;
              courseDetail['endTime'] = endTime;
              courseList.add(courseDetail);
              //此处回调db insert
            }
          }
        }
      }
    }
    print(courseList);
  }
}
