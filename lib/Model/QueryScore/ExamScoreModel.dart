import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/HttpUtil.dart';

class ExamScoreList with ChangeNotifier {
  int _year = DateTime.now().year;
  int _term = 2;
  bool _isLoading = false;
  String _msg = '';
  List<Map<String, dynamic>> examScoreList = [];

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

  Future<void> queryExamScore() async {
    _isLoading = true;
    notifyListeners();

    FileUtil fp = await FileUtil.getInstance();
    String cookie = fp.readFile(Constant.FILE_SESSION);

    Map<String, dynamic> result =
        await HttpUtil().queryScore(_year.toString(), _term.toString(), cookie);

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
        examScoreList.add(item);
      }
      _msg = '查询成功';
    } else {
      _msg = '获取成绩失败了，也许是你没登录教务或者连接不上教务';
    }

    _isLoading = false;
    notifyListeners();
  }
}
