import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/HttpUtil.dart' as http;
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';

enum LoginType {
  guilinJW,
  guilinOA,
  nanning,
  fitness,
  attendance
} //桂林教务 桂林统一身份认证 南宁分校 体测 考勤

class LoginInfo with ChangeNotifier {
  LoginInfo() {
    init();
  }

  SharedPreferenceUtil su;

  TextEditingController _studentIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _verifyCodeController = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true; //密码的明文控制
  bool _savePwd = true; //记住密码开关控制

  LoginType _loginType = LoginType.guilinJW;

  Uint8List _verifyCodeImage;
  String _cookie = '';
  String _msg = '';

  TextEditingController get studentIdController => _studentIdController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get verifyCodeController => _verifyCodeController;

  bool get isLoading => _isLoading;
  bool get obscure => _obscure;
  bool get savePwd => _savePwd;
  String get cookie => _cookie;
  String get msg => _msg;
  Uint8List get verifyCodeImage => _verifyCodeImage;

  LoginType get loginType => _loginType;

  set obscure(bool obscure) {
    _obscure = !_obscure;
    notifyListeners();
  }

  set savePwd(bool savePwd) {
    _savePwd = savePwd;
    notifyListeners();
  }

  /// 更换登录方式
  Future<void> changeLoginType(int loginTypeIndex) async {
    _loginType = LoginType.values[loginTypeIndex];
    if (loginTypeIndex <= 2) {
      if (loginTypeIndex == 0 || loginTypeIndex == 1)
        Constant.URL_JW = Constant.URL_JW_GLUT;
      else
        Constant.URL_JW = Constant.URL_JW_GLUT_NN;
      su.setInt('login_type', loginTypeIndex);
    }
    setControllerPassword();
    notifyListeners();
  }

  /// 登录操作
  Future<bool> login() async {
    String studentId = _studentIdController.text.trim();
    String password = _passwordController.text.trim();
    String verifyCode = _verifyCodeController.text.trim();

    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> result;
    if (_loginType == LoginType.guilinOA)
      result = await _loginOA(studentId, password, verifyCode, _cookie);
    else
      result = await _loginJW(studentId, password, verifyCode, _cookie);

    if (result['success']) {
      FileUtil fp = await FileUtil.getInstance();
      // 写 session 到文件 TODO 以json存储
      fp.writeFile(
          result['cookie'], Constant.LIST_LOGIN_TITLE[loginType.index][3]);

      _msg = '登录成功, 该界面无需理会, 可跳转至别的界面';
    } else
      _msg = '登录失败, 检查下登录信息是否有误';

    savePassword(); // 不管登录成不成功，写了再说

    _isLoading = false;
    notifyListeners();
    return result['success'];
  }

  /// 切换的登录方式的时候切换密码
  Future<void> setControllerPassword() async {
    String pwd =
        await su.getString(Constant.LIST_LOGIN_TITLE[_loginType.index][1]);
    _passwordController.text = pwd;
  }

  /// 登录的时候写进 sharedpreference
  Future<void> savePassword() async {
    String password = _passwordController.text;
    String studentId = _studentIdController.text;
    if (!_savePwd) {
      password = '';
      studentId = '';
      su.setBool('remember_pwd', false);
    }
    su.setString(Constant.LIST_LOGIN_TITLE[loginType.index][1], password);
    su.setString('student_id', studentId);
  }

  /// 刷新验证码
  Future<void> refreshVerifyCodeImage() async {
    Map<String, dynamic> result = await _getCode();
    if (result['success']) {
      _verifyCodeImage = base64.decode(result['data']['image']);
      _cookie = result['data']['cookie'];
      _msg = '刷新成功';
    } else
      _msg = '网络有点问题，获取验证码失败啦';
    notifyListeners();
  }

  Future<void> init() async {
    su = await SharedPreferenceUtil.getInstance();
    _loginType = LoginType.values[
        await su.getInt('login_type')]; // 由于拥有了屏风校区的选项,原来的campus改成了登录选项,于1.4.4改
    _studentIdController.text = await su.getString('student_id');
    changeLoginType(_loginType.index);
    await refreshVerifyCodeImage();
  }

  // HTTP 请求登录部分
  /// 获取验证码
  Future<Map<String, dynamic>> _getCode() async {
    String verifyCodeURL = Constant.LIST_LOGIN_TITLE[_loginType.index][2];
    try {
      var response = await http.get(verifyCodeURL, '');
      var data = {
        'cookie': response.headers['set-cookie'].split(';')[0],
        'image': base64.encode(response.bodyBytes)
      };
      return {'success': true, 'data': data};
    } catch (e) {
      return {'success': false, 'data': e};
    }
  }

  Future<Map<String, dynamic>> _loginJW(String studentId, String password,
      String verifyCode, String cookie) async {
    try {
      var postData = {
        "j_username": studentId,
        "j_password": password,
        "j_captcha": verifyCode.trim().toString()
      };
      var response = await http
          .post(Constant.URL_JW + Constant.URL_LOGIN, postData, cookie: cookie);
      if (response.headers['location'].contains('index_new'))
        return {
          'success': true,
          'cookie': response.headers['set-cookie'].split(';')[0]
        };
      else
        return {'success': false, 'cookie': ''};
    } catch (e) {
      return {'success': false, 'cookie': ''};
    }
  }

  Future<Map<String, dynamic>> _loginOA(String studentId, String password,
      String verifyCode, String cookie) async {
    print('?');
    try {
      var responseLt = await http.get(Constant.URL_LOGIN_OA, cookie);
      RegExp ltExp = RegExp('name="lt" value="(.*)"');
      RegExpMatch ltMatch = ltExp.firstMatch(responseLt.body);

      String lt = ltMatch.group(1);
      Map<String, dynamic> postData = {
        '_eventId': 'submit',
        'j_captcha_response': verifyCode,
        'lt': lt,
        'password': password,
        'useValidateCode': '1',
        'username': studentId
      };
      // 这谜一样的统一身份认证要跳转3次
      // 先登录统一身份认证
      var response =
          await http.post(Constant.URL_LOGIN_OA, postData, cookie: cookie);
      if (response.body == '') {
        // 登录成功
        // 第一次跳转 获取乱七八糟的认证信息
        // 以下虽然可以走 get 但是写着走 post 是有原因的，可以get，但没必要
        response = await http.post(Constant.URL_OA_TO_JW, {'test': '1'},
            cookie: cookie);
        // 第二次跳转登录教务
        response = await http.post(response.headers['location'], {'test': '1'});
        // 第三次跳转带着验证码和验证码cookie登录到教务并返回cookie，一般都是登录成功
        response = await http.post(response.headers['location'], {'test': '1'},
            cookie: (response.headers['set-cookie'].split(';'))[0]);
        if (response.headers['location'].contains('index_new'))
          return {
            'success': true,
            'cookie': response.headers['set-cookie'].split(';')[0]
          };
        else
          return {'success': false, 'cookie': ''};
      }
    } catch (e) {
      return {'success': false, 'cookie': ''};
    }
    return {'success': false, 'cookie': ''};
  }
}
