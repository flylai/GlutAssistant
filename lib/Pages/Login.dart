import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/HttpUtil.dart';
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';
import 'package:glutassistant/Widget/ProgressDialog.dart';
import 'package:glutassistant/Widget/SnackBar.dart';

class Login extends StatefulWidget {
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var _studentIdController = TextEditingController();
  var _passwordController = TextEditingController();
  var _verifyCodeController = TextEditingController();
  bool _obscure = true; //密码的明文控制
  bool _savePwd = true; //记住密码开关控制
  bool _isLoading = false; //登录加载动画显示控制
  var _pwdVisibility = Icons.visibility; //右边眼睛的控制
  String _cookie = ';x=1;'; //验证码的cookie

  Uint8List _verifyCodeImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildBody(),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xff00c9ff), Color(0xff92fe9d)])),
    );
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    _verifyCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
    _getNewVerifyCode();
  }

  Widget _buildBody() {
    if (_isLoading) return new ProgressDialog();
    return ListView(
      children: <Widget>[
        _builderCircleAvatar(),
        Container(
          //输入框之类的
          margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildStudentIdTextFiled(),
              _buildPasswordTextFiled(),
              _buildVerifyCodeEdit(),
              _buildSavePwdSwitch(),
              _buildCommitButton()
            ],
          ),
        )
      ],
    );
  }

  Widget _buildCommitButton() {
    //提交按钮
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(15.0, 0, 15.0, 3.0),
      child: Card(
        color: Color.fromARGB(255, 206, 71, 0),
        elevation: 6.0,
        child: FlatButton(
            onPressed: (_studentIdController.text.isEmpty ||
                    _passwordController.text.isEmpty)
                ? null
                : () {
                    setState(() {
                      _isLoading = true;
                    });

                    HttpUtil.loginJW(
                        _studentIdController.text,
                        _passwordController.text,
                        _verifyCodeController.text,
                        _cookie, (callback) {
                      if (callback['success']) {
                        FileUtil.writeFile(
                            callback['cookie'], Constant.FILE_SESSION);
                        if (_savePwd) {
                          SharedPreferenceUtil.setString(
                              'studentid', _studentIdController.text);
                          SharedPreferenceUtil.setString(
                              'passwordJW', _passwordController.text);
                          SharedPreferenceUtil.setBool('rememberpwd', true);
                        } else {
                          SharedPreferenceUtil.setString('studentid', '');
                          SharedPreferenceUtil.setString('passwordJW', '');
                          SharedPreferenceUtil.setBool('rememberpwd', false);
                        }
                        CommonSnackBar.buildSnackBar(
                            context, '登录成功, 该界面无需理会, 可跳转至别的界面');
                      } else
                        CommonSnackBar.buildSnackBar(
                            context, '登录失败, 检查下登录信息是否有误');
                      setState(() {
                        _isLoading = false;
                      });
                    });
                  },

            // disabledColor: Colors.blue[100],
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                '登录',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            )),
      ),
    );
  }

  Widget _builderCircleAvatar() {
    //头部圆形图片
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Container(
        padding: EdgeInsets.all(2.0),
        child: CircleAvatar(
            child: Text(
              'G',
              style: TextStyle(fontSize: 50),
            ),
            foregroundColor: Colors.white,
            backgroundColor: Color(0xfff0)),
        width: 110.0,
        height: 110.0,
        decoration: BoxDecoration(
          color: Color(0x00FFFFFF),
          shape: BoxShape.circle,
          border: Border.all(
            width: 1.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordTextFiled() {
    //密码框
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
      child: TextField(
        controller: _passwordController,
        maxLength: 20,
        decoration: InputDecoration(
            labelText: '教务密码',
            suffixIcon: IconButton(
                icon: Icon(
                  _pwdVisibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                    _pwdVisibility = _pwdVisibility == Icons.visibility
                        ? Icons.visibility_off
                        : Icons.visibility;
                  });
                })),
        obscureText: _obscure,
      ),
    );
  }

  Widget _buildSavePwdSwitch() {
    //记住密码开关
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text('记住密码'),
        Switch(
          value: _savePwd,
          onChanged: (value) {
            setState(() {
              _savePwd = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStudentIdTextFiled() {
    //学号输入框
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
      child: TextField(
        controller: _studentIdController,
        maxLength: 15,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '学号',
        ),
      ),
    );
  }

  Widget _buildVerifyCodeEdit() {
    Widget verifyCodeEdit = TextField(
      controller: _verifyCodeController,
      decoration: InputDecoration(
        labelText: '验证码',
      ),
      maxLength: 8,
      keyboardType: TextInputType.number,
    );
    Widget getNewVerifyImage = InkWell(
      child: Container(
          alignment: Alignment.centerRight,
          width: 100.0,
          height: 70.0,
          child: new GestureDetector(
              onTap: () {
                _getNewVerifyCode();
              },
              child: _buildVerifyCodeImage())),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: Stack(
        children: <Widget>[
          verifyCodeEdit,
          Align(
            alignment: Alignment.topRight,
            child: getNewVerifyImage,
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyCodeImage() {
    if (_verifyCodeImage != null) {
      return Image.memory(_verifyCodeImage);
    }
    return Container(
      alignment: Alignment.centerRight,
      child: Icon(Icons.autorenew, size: 25),
    );
  }

  Future _getNewVerifyCode() async {
    String verifyCodeImageBase64;
    HttpUtil.getCode((callback) {
      if (callback['success']) {
        verifyCodeImageBase64 = callback['data']['image'];
        setState(() {
          _verifyCodeImage = base64.decode(verifyCodeImageBase64);
          _cookie = callback['data']['cookie'];
        });
      } else
        CommonSnackBar.buildSnackBar(context, '网络有点问题，获取验证码失败啦');
    });
  }

  Future _init() async {
    await SharedPreferenceUtil.init().then((value) {
      SharedPreferenceUtil.getBool('rememberpwd').then((onValue) {
        if (onValue) {
          SharedPreferenceUtil.getString('studentid').then((studentid) {
            _studentIdController.text = studentid;
          });
          SharedPreferenceUtil.getString('passwordJW').then((password) {
            _passwordController.text = password;
          });
        }
      });
    });
    FileUtil.getFileDir();
  }
}
