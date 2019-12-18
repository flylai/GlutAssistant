import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';

class PasswordData with ChangeNotifier {
  PasswordData() {
    init();
  }

  SharedPreferenceUtil su;

  List<TextEditingController> passwordEditController = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  setPassword(String password, int idx) {
    su.setString(Constant.LIST_LOGIN_TITLE[idx][1], password);
  }

  Future<void> init() async {
    su = await SharedPreferenceUtil.getInstance();

    for (int i = 0; i < Constant.LIST_LOGIN_TITLE.length; i++) {
      passwordEditController[i].text =
          await su.getString(Constant.LIST_LOGIN_TITLE[i][1]);
    }
    notifyListeners();
  }
}
