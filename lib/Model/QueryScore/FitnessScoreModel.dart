import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/QueryScore/FitnessScore.dart';
import 'package:glutassistant/Utility/HttpUtil2.dart' as http;
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';

class FitnessScoreList with ChangeNotifier {
  bool _isLoading = false;
  String _msg = '';
  List<FitnessDetail> _fitnessDetail = [];
  FitnessResult _result;

  List<FitnessDetail> get fitnessDetail => _fitnessDetail;
  bool get isLoading => _isLoading;
  String get msg => _msg;
  FitnessResult get result => _result;

  Future<void> queryFitnessScore() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    _fitnessDetail.clear();

    SharedPreferenceUtil sp = await SharedPreferenceUtil.getInstance();
    String studentID = await sp.getString('student_id');

    Map<String, dynamic> result = await queryFitnessTestScoreWeChat(studentID);
    if (result['success'] && result['data'].length > 0) {
      _result = result['result'];
      _fitnessDetail = result['data'];

      _msg = '查询成功';
    } else {
      _msg = '查询失败';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// 原来网页接口 要登录才能用 登录需要验证码
  Future<Map<String, dynamic>> queryFitnessTestScore(String studentId) async {
    // 登录部分
    var postData = {
      'operType': '911',
      'loginflag': '0',
      'loginType': '0',
      'userName': studentId,
      'passwd': studentId
    };
    try {
      var response = await http.post(Constant.URL_FITNESS_TEST, postData);

      String cookie = response.headers['set-cookie'];

      var res = await http.get(
          'http://tzcs.glut.edu.cn/student/studentInfo.jsp?userName=' +
              studentId +
              '&passwd=' +
              studentId,
          cookie);

      // 登录结束
      var responsex = await http.get(Constant.URL_FIRNESS_TEST_INFO, cookie);
      String html =
          responsex.body.replaceAll(RegExp(r'\s'), '').replaceAll('&nbsp;', '');

      RegExp resultExp = RegExp(
          r'align="center"><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><tdrowspan="16">(.*?)</td><tdrowspan="16">(.*?)</td><tdalign="center"rowspan="16">(.*?)</td><tdalign="center"rowspan="16">(.*?)</td>',
          caseSensitive: false);

      List<FitnessDetail> fitnessList = [];
      FitnessResult result;

      Iterable<Match> resultMatches = resultExp.allMatches(html);
      for (var item in resultMatches) {
        // 1项目 2成绩 3分数 4结论 5加分 6减分 7总成绩 8总结论

        fitnessList.add(FitnessDetail(
            item.group(1), item.group(2), item.group(3), item.group(4)));

        // 结论
        result = FitnessResult(
            item.group(5), item.group(6), item.group(7), item.group(8));
      }

      RegExp itemExp = RegExp(
          r'<tdalign="center">(.*?)</td><tdalign="center">(.*?)</td><tdalign="center">(.*?)</td><tdalign="center">(.*?)</td>',
          caseSensitive: false);
      Iterable<Match> itemMatches = itemExp.allMatches(html);

      for (var item in itemMatches) {
        // 1项目 2成绩 3分数 4结论
        fitnessList.add(FitnessDetail(
            item.group(1), item.group(2), item.group(3), item.group(4)));
      }

      return {'success': true, 'data': fitnessList, 'result': result};
    } catch (e) {
      return {'success': false, 'data': e};
    }
  }

  /// 微信接口
  Future<Map<String, dynamic>> queryFitnessTestScoreWeChat(
      String studentId) async {
    var postData = {
      'method': 'healthscore',
      'stuNo': base64Encode(utf8.encode(studentId)),
      'schoolid': '100001'
    };
    try {
      // 走 get 也行
      var response =
          await http.post(Constant.URL_FITNESS_TEST_INFO_WECHAT, postData);
      String html =
          response.body.replaceAll(RegExp(r'\s'), '').replaceAll('&nbsp;', '');
      // 匹配项目
      RegExp itemExp = RegExp(
          r'<tr><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td></tr>',
          caseSensitive: false,
          unicode: true);
      List<FitnessDetail> fitnessList = [];

      Iterable<Match> itemMatches = itemExp.allMatches(html);
      itemMatches.forEach((f) => fitnessList
          .add(FitnessDetail(f.group(1), f.group(2), f.group(3), f.group(4))));
      fitnessList.removeLast(); // 删掉最后一个, 那个是总成绩

      RegExp resultExp = RegExp(
          r'<td><b>总成绩</b></td><td><b>(.*?)</b></td><td><b>(.*?)</b></td>');
      FitnessResult result;
      RegExpMatch resultMatch = resultExp.firstMatch(html);
      result =
          FitnessResult('0', '0', resultMatch.group(1), resultMatch.group(2));

      return {'success': true, 'data': fitnessList, 'result': result};
    } catch (e) {
      return {'success': false, 'data': ''};
    }
  }
}
