import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/QueryExamLocation/ExamLocation.dart';
import 'package:glutassistant/Utility/FileUtil.dart';

class RecentExamModel with ChangeNotifier {
  RecentExamModel() {
    init();
  }

  List<ExamLocation> _examList = [];

  int get count => _examList.length;
  List<ExamLocation> get examList => _examList;

  init() async {
    int nowTimeStamps = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    FileUtil fp = await FileUtil.getInstance();
    String json = fp.readFile(Constant.FILE_EXAM_LIST);
    if (json != 'ERROR' && json != '') {
      jsonDecode(json).forEach((f) {
        ExamLocation tmp = ExamLocation.fromJson(f);
        if (tmp.timestamps > nowTimeStamps) {
          String leftTimeStr;
          int diff = tmp.timestamps - nowTimeStamps;
          if (diff ~/ 86400 > 0)
            leftTimeStr = '${diff ~/ 86400}天';
          else if (diff ~/ 3600 > 0)
            leftTimeStr = '${diff ~/ 3600}小时';
          else if (tmp.timestamps ~/ 60 > 0) leftTimeStr = '${diff ~/ 60}分钟';
          _examList.add(tmp..leftTime = leftTimeStr);
        }
      });
    }
    notifyListeners();
  }
}
