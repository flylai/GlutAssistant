import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/Dashboard/BalanceModel.dart';
import 'package:glutassistant/Model/GlobalData.dart';
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
        builder: (context) => Balance(),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Text('一卡通余额', style: TextStyle(color: Colors.white)),
            ),
            // Consumer<Balance>(builder: (context, balance, _) {
            //   balance.init();
            // return
            _buildBalanceText(),
            // }),
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
    Color color = Color(
        Constant.VAR_COLOR[Random.secure().nextInt(Constant.VAR_COLOR.length)]);
    return Consumer<GlobalData>(
        builder: (context, globalData, _) => DetailCard(
              color,
              child,
              elevation: 0.5,
              opacity: globalData.opacity,
            ));
  }

  Widget _buildBalanceText() {
    return Consumer<Balance>(builder: (context, balance, _) {
      balance.init();
      if (balance.isLoading) return CircularProgressIndicator();
      return Text(
        '￥${balance.balance}',
        style: TextStyle(fontSize: 40, color: Colors.white),
      );
    });
  }
}
