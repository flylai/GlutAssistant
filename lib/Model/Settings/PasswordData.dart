import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';

class PasswordData with ChangeNotifier {
  SharedPreferenceUtil su;

  TextEditingController _studentIdController = TextEditingController();
  String _studentId = '';

  List<TextEditingController> passwordEditController = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];
  PasswordData() {
    init();
  }

  TextEditingController get studentIdController => _studentIdController;
  String get studentId => _studentId;

  Future<void> init() async {
    su = await SharedPreferenceUtil.getInstance();

    for (int i = 0; i < Constant.LIST_LOGIN_TITLE.length; i++) {
      passwordEditController[i].text =
          await su.getString(Constant.LIST_LOGIN_TITLE[i][1]);
    }

    _studentIdController.text = await su.getString('student_id');
    _studentId = _studentIdController.text;
    notifyListeners();
  }

  setPassword(String password, int idx) {
    su.setString(Constant.LIST_LOGIN_TITLE[idx][1], password);
  }

  void setStudentId() {
    su.setString('student_id', _studentIdController.text);
    _studentId = _studentIdController.text;
    notifyListeners();
  }
}
