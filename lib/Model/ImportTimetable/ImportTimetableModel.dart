import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/CourseManage/Course.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/HttpUtil2.dart' as http;
import 'package:glutassistant/Utility/SQLiteUtil.dart';

class ImportTimetableModel with ChangeNotifier {
  int _year = DateTime.now().year;
  int _term = 2;
  bool _isLoading = false;
  String _msg = '';

  int get year => _year;
  int get term => _term;
  bool get isLoading => _isLoading;
  String get msg => _msg;

  set year(int year) {
    if (year == _year) return;
    _year = year;
    notifyListeners();
  }

  set term(int term) {
    if (term == _year) return;
    _term = term;
    notifyListeners();
  }

  Future<void> importTimetable() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> result;

    FileUtil fp = await FileUtil.getInstance();
    String cookie = fp.readFile(Constant.FILE_SESSION);

    result = await queryTimeTable(
        _year.toString(), _term.toString(), cookie); // 获取课表

    if (result['success'] && result['data'].length > 0) {
      SQLiteUtil su = await SQLiteUtil.getInstance();
      await su.dropTable();
      await su.createTable();
      for (var item in result['data']) await su.insertTimetable(item); // 写数据库
      _msg = '课表导入成功了，请前往课程表界面查看';
    } else
      _msg = '获取得到的课表为空，请检查是否选对学年学期或者重新登录教务';

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> queryTimeTable(
      String year, String term, String cookie) async {
    int _year = int.parse(year) - 1980;
    if (term == '2' && Constant.URL_JW == Constant.URL_JW_GLUT_NN)
      term = '3'; // 南宁分校秋季是3
    try {
      var response = await http
          .get(
              Constant.URL_JW +
                  Constant.URL_CLASS_SCHEDULE_ALL +
                  '?term=' +
                  term +
                  '&year=' +
                  _year.toString(),
              cookie)
          .timeout(Duration(milliseconds: Constant.VAR_HTTP_TIMEOUT_MS));
      List<Course> courseList = [];
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
              int weekday = BaseFunctionUtil.getNumByWeekday(timeListItem[2]);
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
              } else if (timeListItem.group(3) == '中午') {
                // 奇葩写法 中午两节课直接写中午
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
              }
              courseList.add(Course(courseName, teacher, startWeek, endWeek,
                  weekday, weekType, startTime, endTime, location));
            }
          }
        }
      }
      return {'success': true, 'data': courseList};
    } catch (e) {
      return {'success': false, 'data': e};
    }
  }
}
