import 'package:flutter/foundation.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/HttpUtil.dart';

class ExamLocation with ChangeNotifier {
  bool _isLoading = false;
  bool _status = false;
  String _msg = '';
  List<Map<String, dynamic>> _examList = [];

  bool get isLoading => _isLoading;
  bool get status => _status;
  String get msg => _msg;
  List<Map<String, dynamic>> get examList => _examList;

  Future queryExamList() async {
    _isLoading = true;
    notifyListeners();

    FileUtil fp = await FileUtil.getInstance();
    String cookie = fp.readFile(Constant.FILE_SESSION);
    _examList.clear();
    Map<String, dynamic> result = await HttpUtil().queryExamLocation(cookie);
    print(result);
    if (!result['success']) {
      _status = false;
      _msg = '未查到考试信息, 也许是你没登入教务或者最近没有考试';
    } else {
      _status = true;
      _msg = '查询成功';
      DateTime now = DateTime.now();
      List<Map<dynamic, dynamic>> tmpList = result['data'];
      for (var exam in tmpList) {
        DateTime examTime = DateTime.parse(exam['datetime']);
        int days = examTime.difference(now).inDays;
        int hours = examTime.difference(now).inHours - days * 24;
        int minutes =
            examTime.difference(now).inMinutes - days * 24 * 60 - hours * 60;
        String leftTimeStr = '';

        if (days > 0) leftTimeStr += '$days天';
        if (days > 0 || (days == 0 && hours > 0)) leftTimeStr += '$hours小时';
        leftTimeStr += '$minutes分钟';
        exam['leftTime'] = leftTimeStr;
        _examList.add(exam);
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}
