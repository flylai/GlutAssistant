import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/HttpUtil.dart';
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';

class BalanceUtil {
  static String _studentid = '';
  static String _data = '';
  static String _balance = '未知';
  static String _lastupdate = '';
  static Map<String, dynamic> getCacheBalance() {
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
    print('init $result');
    return result;
  }

  static init() async {
    await SharedPreferenceUtil.init();
    await SharedPreferenceUtil.getString('studentid').then((onValue) {
      _studentid = onValue;
    });
    await FileUtil.getFileDir();
    _data = FileUtil.readFile(Constant.FILE_DATA_CAIWU);
  }

  static Future<Map<String, dynamic>> refreshBalance() async {
    //写了半天逻辑发现查余额只要学号 我....
    Map<String, dynamic> result = {
      'success': false,
      'msg': '未知',
      'balance': '0'
    };
    if (_studentid != '') {
      //有cookie和学号，先查一波
      await HttpUtil.queryBalance(_studentid, (callback) {
        if (!callback['success']) {
          //cookie过期或者学号不对或者财务炸了
          result['success'] = false;
          result['msg'] = '查询失败,未知原因,请稍后再试';
        } else {
          //cookie没过期有结果
          _lastupdate = '${DateTime.now().hour}:${DateTime.now().minute}';
          _balance = callback['balance'];
          result['success'] = true;
          result['msg'] = '查询成功';
          result['balance'] = _balance;
          result['lastupdate'] = _lastupdate;
        }
      });
    } else {
      //没设置学号，第一次使用
      result['success'] = false;
      result['msg'] = '请设置学号再试';
    }
    if (result['success']) _saveData();
    print('refresh $result');
    return result;
  }

  static void _saveData() {
    Map<String, dynamic> data = {};
    data['balance'] = _balance;
    data['lastupdate'] = _lastupdate;
    print('_saveData $data');
    FileUtil.writeFile(jsonEncode(data), Constant.FILE_DATA_CAIWU);
  }
}
