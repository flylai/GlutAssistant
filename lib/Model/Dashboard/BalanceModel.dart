import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:glutassistant/Utility/BalanceUtil.dart';

class Balance with ChangeNotifier {
  Balance() {
    init();
  }

  bool _status = false;
  String _studentId;
  String _balance = '未知';
  String _lastUpdate = '从未更新';
  String _msg = '';
  bool _isLoading = true;

  bool isFirst = true;

  bool get status => _status;
  String get studentId => _studentId;
  String get balance => _balance;
  String get lastUpdate => _lastUpdate;
  bool get isLoading => _isLoading;
  String get msg => _msg;

  set balance(String newBalance) {
    if (_balance == newBalance) return;
    _balance = newBalance;
    notifyListeners();
  }

  Future refreshBalance() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    BalanceUtil bu = BalanceUtil();
    await bu.init();
    Map<String, dynamic> data = await bu.refreshBalance();
    _status = data['success'];
    _lastUpdate = data['lastupdate'];
    _balance = data['balance'];
    _msg = data['msg'];

    _isLoading = false;
    notifyListeners();
  }

  Future getCacheBalance() async {
    BalanceUtil bu = BalanceUtil();
    await bu.init();
    Map<String, dynamic> data = bu.getCacheBalance();
    _lastUpdate = data['lastupdate'];
    _balance = data['balance'];
    _isLoading = false;
    notifyListeners();
  }

  init() async {
    if (!isFirst) return;
    await getCacheBalance();
    isFirst = false;
  }
}
