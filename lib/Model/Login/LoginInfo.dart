import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/FileUtil2.dart';
import 'package:glutassistant/Utility/HttpUtil.dart';
import 'package:glutassistant/Utility/SPUtil.dart';

enum CampusType { guilinJW, guilinCA, nanning } //桂林教务 桂林统一身份认证 南宁分校

class LoginInfo with ChangeNotifier {
  TextEditingController _verifyCodeController = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true; //密码的明文控制
  bool _savePwd = true; //记住密码开关控制
  bool _isFirst = true;

  CampusType _campusType = CampusType.guilinJW;

  Uint8List _verifyCodeImage;
  String _cookie = '';
  String _msg = '';

  TextEditingController get verifyCodeController => _verifyCodeController;

  bool get isLoading => _isLoading;
  bool get obscure => _obscure;
  bool get savePwd => _savePwd;
  String get cookie => _cookie;
  String get msg => _msg;
  Uint8List get verifyCodeImage => _verifyCodeImage;

  CampusType get campusType => _campusType;

  set obscure(bool obscure) {
    _obscure = !_obscure;
    notifyListeners();
  }

  set savePwd(bool savePwd) {
    _savePwd = savePwd;
    notifyListeners();
  }

  Future<void> changeCampus(int campusIndex) async {
    _campusType = CampusType.values[campusIndex];
    if (campusIndex == 0)
      Constant.URL_JW = Constant.URL_JW_GLUT;
    else
      Constant.URL_JW = Constant.URL_JW_GLUT_NN;
    SharedPreferenceUtil su = await SharedPreferenceUtil.getInstance();
    su.setInt('campus', campusIndex);
  }

  Future<void> refreshVerifyCodeImage() async {
    Map<String, dynamic> result = await HttpUtil().getCode();
    if (result['success']) {
      _verifyCodeImage = base64.decode(result['data']['image']);
      _cookie = result['data']['cookie'];
      _msg = '刷新成功';
    } else
      _msg = '网络有点问题，获取验证码失败啦';
    notifyListeners();
  }

  Future<void> loginJW(String studentId, String password) async {
    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> result = await HttpUtil()
        .loginJW(studentId, password, _verifyCodeController.text, _cookie);

    if (result['success']) {
      SharedPreferenceUtil su = await SharedPreferenceUtil.getInstance();
      FileUtil fp = await FileUtil.getInstance();
      fp.writeFile(result['cookie'], Constant.FILE_SESSION);
      if (!_savePwd) {
        su.setString('student_id', '');
        su.setString('password_JW', '');
        su.setBool('remember_pwd', false);
      }
      _msg = '登录成功, 该界面无需理会, 可跳转至别的界面';
    } else
      _msg = '登录失败, 检查下登录信息是否有误';

    _isLoading = false;
    notifyListeners();
  }

  Future<void> init() async {
    if (!_isFirst) return;
    SharedPreferenceUtil su = await SharedPreferenceUtil.getInstance();
    _campusType = CampusType.values[await su.getInt('campus')];
    await refreshVerifyCodeImage();
  }
}
