import 'package:flutter/material.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/Model/Login/LoginInfo.dart';
import 'package:glutassistant/Widget/SnackBar.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LoginInfo loginModel = LoginInfo();
    loginModel.init();
    return ChangeNotifierProvider<LoginInfo>.value(
        value: loginModel,
        child: Container(
          child: _buildBody(),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xff00c9ff), Color(0xff92fe9d)])),
        ));
  }

  Widget _buildBody() {
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
              _buildCampusDropdown(),
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

  Widget _buildCampusDropdown() {
    return Consumer<LoginInfo>(
        builder: (context, loginModel, _) => Container(
            margin: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 3.0),
            child: DropdownButtonHideUnderline(
                child: DropdownButton(
              value: loginModel.campusType.index,
              items: _generateCampusList(),
              isDense: true,
              isExpanded: true,
              onChanged: (value) {
                loginModel.changeCampus(value);
                loginModel.refreshVerifyCodeImage();
              },
            ))));
  }

  Widget _buildCommitButton() {
    //提交按钮
    return Consumer2<LoginInfo, GlobalData>(
        builder: (context, loginModel, globalData, _) {
      if (loginModel.isLoading) return CircularProgressIndicator();
      return Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(15.0, 0, 15.0, 3.0),
          child: Card(
            color: Color.fromARGB(255, 206, 71, 0),
            elevation: 6.0,
            child: FlatButton(
                onPressed: (globalData.studentIdController.text.isEmpty ||
                        globalData.passwordJWController.text.isEmpty)
                    ? null
                    : () async {
                        await globalData.setStudentId();
                        await globalData.setJWPassword();
                        await loginModel.loginJW(
                            globalData.studentId, globalData.passwordJW);
                        CommonSnackBar.buildSnackBar(context, loginModel.msg);
                      },
                // disabledColor: Colors.blue[100],
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    '登录',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                )),
          ));
    });
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
    return Consumer2<LoginInfo, GlobalData>(
        builder: (context, loginModel, globalData, _) => Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
              child: TextField(
                controller: globalData.passwordJWController,
                maxLength: 20,
                decoration: InputDecoration(
                    labelText: '教务密码',
                    suffixIcon: IconButton(
                        icon: Icon(
                          loginModel.obscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => loginModel.obscure = false)),
                obscureText: loginModel.obscure,
              ),
            ));
  }

  Widget _buildSavePwdSwitch() {
    //记住密码开关
    return Consumer<LoginInfo>(
        builder: (context, loginModel, _) => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text('记住密码'),
                Switch(
                  value: loginModel.savePwd,
                  onChanged: (value) => loginModel.savePwd = value,
                ),
              ],
            ));
  }

  Widget _buildStudentIdTextFiled() {
    //学号输入框
    return Consumer2<LoginInfo, GlobalData>(
        builder: (context, loginModel, globalData, _) => Padding(
              padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
              child: TextField(
                controller: globalData.studentIdController,
                maxLength: 15,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '学号',
                ),
              ),
            ));
  }

  Widget _buildVerifyCodeEdit() {
    return Consumer<LoginInfo>(builder: (context, loginModel, _) {
      Widget verifyCodeEdit = TextField(
        controller: loginModel.verifyCodeController,
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
                onTap: () async {
                  await loginModel.refreshVerifyCodeImage();
                  CommonSnackBar.buildSnackBar(context, loginModel.msg);
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
    });
  }

  Widget _buildVerifyCodeImage() {
    return Consumer<LoginInfo>(builder: (context, loginModel, _) {
      if (loginModel.verifyCodeImage != null) {
        return Image.memory(loginModel.verifyCodeImage);
      }
      return Container(
        alignment: Alignment.centerRight,
        child: Icon(Icons.autorenew, size: 25),
      );
    });
  }

  List<DropdownMenuItem> _generateCampusList() {
    List<DropdownMenuItem> items = List();
    DropdownMenuItem item =
        DropdownMenuItem(value: 0, child: Text('桂林理工大学(教务)'));
    items.add(item);
    DropdownMenuItem item2 =
        DropdownMenuItem(value: 1, child: Text('桂林理工大学(统一身份认证)'));
    items.add(item2);
    DropdownMenuItem item3 =
        DropdownMenuItem(value: 2, child: Text('桂林理工大学南宁分校'));
    items.add(item3);
    return items;
  }
}
