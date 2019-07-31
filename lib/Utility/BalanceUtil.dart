import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/HttpUtil.dart';
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';

class BalanceUtil {
  String _studentid = '';
  String _data = '';
  String _balance = '未知';
  String _lastupdate = '';

  FileUtil _fp;

  Map<String, dynamic> getCacheBalance() {
    _data = _fp.readFile(Constant.FILE_DATA_CAIWU);
    Map<String, dynamic> result = {};
    if (_data != 'ERROR' && _data != '') {
      Map<String, dynamic> json = jsonDecode(_data);
      _balance = json['balance'];
      _lastupdate = json['lastupdate'];
      result = json;
    } else {
      result['balance'] = '未知';
      result['lastupdate'] = '从未更新';
    }
    return result;
  }

  Future init() async {
    SharedPreferenceUtil sp = await SharedPreferenceUtil.getInstance();
    _studentid = await sp.getString('student_id');
    _fp = await FileUtil.getInstance();
    _data = _fp.readFile(Constant.FILE_DATA_CAIWU);
  }

  Future<Map<String, dynamic>> refreshBalance() async {
    //写了半天逻辑发现查余额只要学号 我....
    Map<String, dynamic> returnResult = {
      'success': false,
      'msg': '未知',
      'balance': '0'
    };
    if (_studentid != '') {
      //有cookie和学号，先查一波
      Map<String, dynamic> queryResult =
          await HttpUtil().queryBalance(_studentid);
      if (!queryResult['success']) {
        //cookie过期或者学号不对或者财务炸了
        returnResult['success'] = false;
        returnResult['msg'] = '查询失败,未知原因,请稍后再试';
      } else {
        //cookie没过期有结果
        _lastupdate =
            '${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}';
        _balance = queryResult['balance'];
        returnResult['success'] = true;
        returnResult['msg'] = '查询成功';
        returnResult['balance'] = _balance;
        returnResult['lastupdate'] = _lastupdate;
        _saveData();
      }
    } else {
      //没设置学号，第一次使用
      returnResult['success'] = false;
      returnResult['msg'] = '请设置学号再试';
    }
    return returnResult;
  }

  void _saveData() {
    Map<String, dynamic> data = {};
    data['balance'] = _balance;
    data['lastupdate'] = _lastupdate;
    _fp.writeFile(jsonEncode(data), Constant.FILE_DATA_CAIWU);
  }
}
