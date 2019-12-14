import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/HttpUtil2.dart' as http;

class ExamScoreList with ChangeNotifier {
  int _year = DateTime.now().year;
  int _term = 2;
  bool _isLoading = false;
  String _msg = '';
  List<Score> _examScoreList = [];
  List<Score> get examScoreList => _examScoreList;

  bool get isLoading => _isLoading;
  String get msg => _msg;
  int get term => _term;
  set term(int term) {
    if (term == _year) return;
    _term = term;
    notifyListeners();
  }

  int get year => _year;

  set year(int year) {
    if (year == _year) return;
    _year = year;
    notifyListeners();
  }

  Future<void> queryExamScore() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    FileUtil fp = await FileUtil.getInstance();
    String cookie = fp.readFile(Constant.FILE_SESSION);

    Map<String, dynamic> result =
        await queryScore(_year.toString(), _term.toString(), cookie);

    if (result['success'] && result['data'].length > 0) {
      examScoreList.clear();
      int campusType = Constant.URL_JW == Constant.URL_JW_GLUT ? 1 : 2;
      for (var item in result['data']) {
        String score;
        if (item['score'].contains(RegExp(r'(?!不)[秀中良格]$'))) {
          score = item['score'] +
              (campusType == 1
                  ? ('(' +
                      ((5 + double.parse(item['gpa'])) * 10).toString() +
                      ')')
                  : '');
        } else {
          score = item['score']
              .toString()
              .replaceAllMapped(
                  RegExp(r'.*>(\d+|不及格)<.*'), (Match m) => '${m[1]}')
              .replaceAll('&nbsp;', '');
        }

        item['score'] = score;
        item['subtitle'] = item['teacher'] +
            (item['teacher'] == '' ? '' : '    ') +
            (campusType == 1 ? '绩点: ' : '学分: ') +
            item['gpa'];

        double gpa = double.parse(item['gpa']);
        int color = 0;
        if (gpa >= 4.0)
          color = 0xFF1B5E20; // 深绿
        else if (gpa >= 3.0)
          color = 0xFF558B2F; // 绿
        else if (gpa >= 2.0)
          color = 0xFFFDD835; // 黄
        else if (gpa >= 1.0)
          color = 0xFFFF8F00; // 橙黄
        else
          color = 0xFFE83015; // 红
        item['color'] = color;
        examScoreList.add(Score.fromJson(item));
      }
      _msg = '查询成功';
    } else {
      _msg = '获取成绩失败了，也许是你没登录教务或者连接不上教务或者成绩还没出来';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> queryScore(
      String year, String term, String cookie) async {
    int _year = int.parse(year) - 1980;
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
      var response = await http.post(
          Constant.URL_JW + Constant.URL_QUERY_SCORE, postData,
          cookie: cookie);
      List<Map> scoreList = [];
      String html = response.body.replaceAll(RegExp(r'\s'), '');
      Iterable<Match> scoreMatches = scoreExp.allMatches(html);
      for (var scoreListItem in scoreMatches) {
        Map<String, dynamic> scoredetail = {};
        scoredetail['courseName'] = scoreListItem.group(1);
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
}

class Score {
  final String courseName;
  final String teacher;
  final String subtitle;
  final String score;
  final String gpa;
  final int color;

  Score(this.courseName, this.teacher, this.subtitle, this.score, this.gpa,
      this.color);

  Score.fromJson(Map<String, dynamic> json)
      : courseName = json['courseName'],
        teacher = json['teacher'],
        subtitle = json['subtitle'],
        score = json['score'],
        gpa = json['gpa'],
        color = json['color'];
}
