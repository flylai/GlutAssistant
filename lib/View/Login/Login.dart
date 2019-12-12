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
        child: Container(
          child: _buildBody(),
          alignment: Alignment.center,
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
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(102, 0, 150, 255),
                  offset: Offset(1.5, 1.5),
                  blurRadius: 6.0),
            ],
          ),
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
        builder: (context, loginInfo, _) => Container(
            margin: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 3.0),
            child: DropdownButtonHideUnderline(
                child: DropdownButton(
              value: loginInfo.loginType.index,
              items: _generateCampusList(),
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
      if (loginInfo.isLoading) return CircularProgressIndicator();
      return Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(15.0, 0, 15.0, 3.0),
          child: Card(
            color: Color.fromARGB(255, 206, 71, 0),
            elevation: 6.0,
            child: FlatButton(
                onPressed: () async {
                  if (loginInfo.studentIdController.text.isEmpty ||
                      loginInfo.passwordController.text.isEmpty) {
                    CommonSnackBar.buildSnackBar(context, '登录信息似乎没有填写完呢');
                    return;
                  }
                  // await globalData.setStudentId(needRefresh: false);
                  // await loginInfo.setPassword();
                  if (await loginInfo.login()) {
                    showModalBottomSheet(
                        context: context,
                        builder: (ctx) {
                          return Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _buildTodoList(ctx, globalData),
                            ),
                          );
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
    return Consumer2<LoginInfo, GlobalData>(
        builder: (context, loginInfo, globalData, _) => Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
              child: TextField(
                controller: loginInfo.passwordController,
                maxLength: 20,
                decoration: InputDecoration(
                    labelText: '密码',
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
    return Consumer2<LoginInfo, GlobalData>(
        builder: (context, loginInfo, globalData, _) => Padding(
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

  List<Widget> _buildTodoList(BuildContext context, GlobalData globalData) {
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
    return list;
  }

  Widget _buildVerifyCodeEdit() {
    return Consumer<LoginInfo>(builder: (context, loginInfo, _) {
      Widget verifyCodeEdit = TextField(
        controller: loginInfo.verifyCodeController,
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
                  await loginInfo.refreshVerifyCodeImage();
                  CommonSnackBar.buildSnackBar(context, loginInfo.msg);
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

  List<DropdownMenuItem> _generateCampusList() {
    List<DropdownMenuItem> items = [];
    for (int i = 0; i < Constant.LIST_LOGIN_TITLE.length; i++) {
      items.add(DropdownMenuItem(
          value: i, child: Text(Constant.LIST_LOGIN_TITLE[i][0])));
    }
    return items;
  }
}
