import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/Model/Login/LoginInfoModel.dart';
import 'package:glutassistant/Widget/SnackBar.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginInfo>(
        create: (BuildContext context) => LoginInfo(),
        child: Consumer<GlobalData>(
            builder: (context, globalData, _) => Container(
                  color: Color.fromRGBO(228, 228, 228, 1)
                      .withOpacity(globalData.opacity),
                  child: _buildBody(),
                  alignment: Alignment.center,
                )));
  }

  Widget _buildBody() {
    return ListView(
      children: <Widget>[
        SizedBox(height: 100),
        Container(
          //输入框之类的
          margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(102, 0, 150, 255),
                  offset: Offset(1.5, 1.5),
                  blurRadius: 6.0),
            ],
          ),
          child: Stack(children: [
            Positioned(
              child: _buildLock(),
              right: 0,
              bottom: -180,
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildLoginTypeDropdown(),
                _buildStudentIdTextFiled(),
                _buildDivider(),
                _buildPasswordTextFiled(),
                _buildDivider(),
                _buildVerifyCodeEdit(),
                _buildDivider(),
                _buildSavePwdSwitch(),
                _buildCommitButton(),
              ],
            ),
          ]),
        )
      ],
    );
  }

  Widget _buildLock() {
    return Container(
        transform: Matrix4.rotationZ(-0.6),
        child: Stack(
          children: <Widget>[
            Icon(
              Icons.lock,
              size: 300,
              color: Colors.grey.withOpacity(0.3),
            ),
          ],
        ));
  }

  Widget _buildLoginTypeDropdown() {
    return Consumer<LoginInfo>(
        builder: (context, loginInfo, _) => Container(
            margin: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 3.0),
            child: DropdownButtonHideUnderline(
                child: DropdownButton(
              value: loginInfo.loginType.index,
              items: _generateLoginTypeList(),
              isDense: true,
              isExpanded: true,
              onChanged: (value) async {
                await loginInfo.changeLoginType(value);
                await loginInfo.refreshVerifyCodeImage();
              },
            ))));
  }

  Widget _buildCommitButton() {
    //提交按钮
    return Consumer2<LoginInfo, GlobalData>(
        builder: (context, loginInfo, globalData, _) {
      if (loginInfo.isLoading)
        return Container(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 15),
            child: CircularProgressIndicator());
      return Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(16, 0, 16, 15),
        child: OutlineButton(
            onPressed: () async {
              if (loginInfo.studentIdController.text.isEmpty ||
                  loginInfo.passwordController.text.isEmpty) {
                CommonSnackBar.buildSnackBar(context, '登录信息似乎没有填写完呢');
                return;
              }
              if (await loginInfo.login()) {
                showModalBottomSheet(
                    context: context,
                    builder: (ctx) {
                      return _buildTodoList(ctx);
                    });
              } else {
                CommonSnackBar.buildSnackBar(context, loginInfo.msg);
                loginInfo.refreshVerifyCodeImage();
              }
            },
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                '登录',
                style: TextStyle(color: Colors.blue, fontSize: 16.0),
              ),
            )),
      );
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
            foregroundColor: Colors.pink,
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
    return Consumer<LoginInfo>(
        builder: (context, loginInfo, _) => Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
              child: TextField(
                controller: loginInfo.passwordController,
                // maxLength: 20,
                decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: '密码',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                        icon: Icon(
                          loginInfo.obscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => loginInfo.obscure = false)),
                obscureText: loginInfo.obscure,
              ),
            ));
  }

  Widget _buildSavePwdSwitch() {
    //记住密码开关
    return Consumer<LoginInfo>(
        builder: (context, loginInfo, _) => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text('记住密码'),
                Switch(
                  value: loginInfo.savePwd,
                  onChanged: (value) => loginInfo.savePwd = value,
                ),
              ],
            ));
  }

  Widget _buildStudentIdTextFiled() {
    //学号输入框
    return Consumer<LoginInfo>(
        builder: (context, loginInfo, _) => Padding(
              padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
              child: TextField(
                controller: loginInfo.studentIdController,
                // maxLength: 15,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.person),
                  labelText: '学号',
                ),
              ),
            ));
  }

  Widget _buildTodoList(BuildContext context) {
    return Consumer<GlobalData>(builder: (context, globalData, _) {
      List<Widget> list = [];
      list.add(ListTile(
        title: Text('教务登录成功啦！你想？'),
        subtitle: Text('登录了就可以使用教务系列查询啦，短时间内不必多次登录。'),
      ));
      for (var item in Constant.LIST_LOGIN_TODO) {
        list.add(ListTile(
          title: Text(item[0]),
          leading: Icon(item[1]),
          onTap: () {
            globalData.selectedPage = item[2];
            Navigator.of(context).pop();
          },
        ));
      }
      list.add(ListTile(
          title: Text('啥也不干...'),
          onTap: () {
            Navigator.of(context).pop();
          }));
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    });
  }

  Widget _buildDivider() {
    return Divider(
        color: Colors.blue.shade400,
        height: 0,
        indent: 20,
        endIndent: 20,
        thickness: 0.5);
  }

  Widget _buildVerifyCodeEdit() {
    return Consumer<LoginInfo>(builder: (context, loginInfo, _) {
      Widget verifyCodeEdit = TextField(
        controller: loginInfo.verifyCodeController,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.vpn_key),
          labelText: '验证码',
        ),
        keyboardType: TextInputType.number,
      );
      Widget getNewVerifyImage = GestureDetector(
          onTap: () async {
            await loginInfo.refreshVerifyCodeImage();
            CommonSnackBar.buildSnackBar(context, loginInfo.msg);
          },
          child: _buildVerifyCodeImage());
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Stack(
          children: <Widget>[
            verifyCodeEdit,
            Positioned(
              right: 5,
              top: 20,
              child: getNewVerifyImage,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildVerifyCodeImage() {
    return Consumer<LoginInfo>(builder: (context, loginInfo, _) {
      if (loginInfo.verifyCodeImage != null) {
        return Image.memory(loginInfo.verifyCodeImage);
      }
      return Container(
        alignment: Alignment.centerRight,
        child: Icon(Icons.autorenew, size: 25),
      );
    });
  }

  List<DropdownMenuItem> _generateLoginTypeList() {
    List<DropdownMenuItem> items = [];
    for (int i = 0; i < Constant.LIST_LOGIN_TITLE.length; i++) {
      if (i >= 3) break;
      items.add(DropdownMenuItem(
          value: i, child: Text(Constant.LIST_LOGIN_TITLE[i][0])));
    }
    return items;
  }
}
