import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/Dashboard/BalanceModel.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:glutassistant/Widget/DetailCard.dart';
import 'package:glutassistant/Widget/SnackBar.dart';
import 'package:provider/provider.dart';

class DashBoardBalance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: _buildBalanceArea());
  }

  Widget _buildBalanceArea() {
    Widget child = ChangeNotifierProvider(
        create: (BuildContext context) => Balance(),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Text('一卡通余额', style: TextStyle(color: Colors.white)),
            ),
            _buildBalanceText(),
            Positioned(
              bottom: 0,
              right: 0,
              child: Consumer<Balance>(
                  builder: (context, balance, _) => Row(
                        children: <Widget>[
                          Text(
                            balance.lastUpdate,
                            style: TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await balance.refreshBalance();
                              CommonSnackBar.buildSnackBar(
                                  context, balance.msg);
                            },
                            child: Icon(
                              Icons.sync,
                              color: Colors.white,
                            ),
                          )
                        ],
                      )),
            )
          ],
        ));
    return Consumer<GlobalData>(
        builder: (context, globalData, _) => DetailCard(
              BaseFunctionUtil.getRandomColor(),
              child,
              elevation: 0.5,
              opacity: globalData.opacity,
            ));
  }

  Widget _buildBalanceText() {
    return Consumer<Balance>(builder: (context, balance, _) {
      if (balance.isLoading) return CircularProgressIndicator();
      return Text(
        '￥${balance.balance}',
        style: TextStyle(fontSize: 40, color: Colors.white),
      );
    });
  }
}
