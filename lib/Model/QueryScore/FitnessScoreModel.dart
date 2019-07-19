import 'package:flutter/foundation.dart';
import 'package:glutassistant/Utility/HttpUtil.dart';
import 'package:glutassistant/Utility/SPUtil.dart';

class FitnessScoreList with ChangeNotifier {
  bool _isLoading = false;
  String _msg = '';
  List<Map<dynamic, dynamic>> _fitnessDetail = [];
  Map<String, dynamic> _result = {};

  List<Map<dynamic, dynamic>> get fitnessDetail => _fitnessDetail;
  Map<String, dynamic> get result => _result;
  bool get isLoading => _isLoading;
  String get msg => _msg;

  Future<void> queryFitnessScore() async {
    _isLoading = true;
    notifyListeners();

    _fitnessDetail.clear();
    _result.clear();

    SharedPreferenceUtil sp = await SharedPreferenceUtil.getInstance();
    String studentID = await sp.getString('student_id');

    Map<String, dynamic> result =
        await HttpUtil().queryFitnessTestScore(studentID);
    if (result['success'] && result['data'].length > 0) {
      for (var item in result['data']) {
        item['subtitle'] = '成绩: ${item['record']} 结论:${item['result']}';
      }

      _result = result['result'];
      _fitnessDetail = result['data'];
      _msg = '查询成功';
    } else {
      _msg = '查询失败';
    }
    _isLoading = false;
    notifyListeners();
  }
}
