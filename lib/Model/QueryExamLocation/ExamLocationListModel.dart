import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/QueryExamLocation/ExamLocation.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/HttpUtil2.dart' as http;

class ExamLocationModel with ChangeNotifier {
  bool _isLoading = false;
  bool _status = false;
  String _msg = '';
  List<ExamLocation> _examList = [];

  List<ExamLocation> get examList => _examList;
  bool get isLoading => _isLoading;
  String get msg => _msg;
  bool get status => _status;

  Future queryExamList() async {
    if (_isLoading) return; // 如果在查询，就别继续查了
    _isLoading = true;
    notifyListeners();

    FileUtil fp = await FileUtil.getInstance();
    String cookie = fp.readFile(Constant.FILE_SESSION); // 读cookie
    _examList.clear();

    Map<String, dynamic> result = await queryExamLocation(cookie);
    if (!result['success']) {
      _status = false;
      _msg = '未查到考试信息, 也许是你没登入教务或者最近没有考试';
    } else {
      _status = true;
      _msg = '查询成功';
      DateTime now = DateTime.now();
      List<Map<dynamic, dynamic>> tmpList = result['data'];
      for (var exam in tmpList) {
        DateTime examTime = DateTime.parse((exam['datetime'] +
            ' ' +
            exam['interval'].toString().split('--')[0]));
        int days = examTime.difference(now).inDays;
        int hours = examTime.difference(now).inHours - days * 24;
        int minutes =
            examTime.difference(now).inMinutes - days * 24 * 60 - hours * 60;
        String leftTimeStr = '';

        if (days > 0) leftTimeStr += '$days天';
        if (days > 0 || (days == 0 && hours > 0)) leftTimeStr += '$hours小时';
        leftTimeStr += '$minutes分钟';

        _examList.add(ExamLocation(
            exam['courseName'],
            exam['type'],
            exam['location'],
            exam['datetime'] + ' ' + exam['interval'],
            examTime.millisecondsSinceEpoch ~/ 1000)
          ..leftTime = leftTimeStr);
      }
    }

    fp.writeFile(jsonEncode(_examList), Constant.FILE_EXAM_LOCATION);

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> queryExamLocation(String cookie) async {
    try {
      var response = await http.get(
          Constant.URL_JW + Constant.URL_QUERY_EXAMINATION_LOCATION, cookie);
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
      Iterable<Match> examDetailMatches =
          examDetailExp.allMatches(examHTMLMatches.first.group(0));
      for (var examDetail in examDetailMatches) {
        //1课程号 2课程名 3考试时间(天) 4考试时间(区间) 5考试地点 6考核方式
        Map<String, dynamic> exam = {};
        exam['courseName'] = examDetail.group(2);
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
}
