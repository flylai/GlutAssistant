import 'package:flutter/material.dart';
import 'package:glutassistant/Model/Dashboard/BalanceModel.dart';
import 'package:glutassistant/Model/Dashboard/RecentExamModel.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/Widget/SnackBar.dart';
import 'package:provider/provider.dart';

class DashboardSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (BuildContext context) => BalanceModel(),
        child: Container(child: _buildSummary(context)));
  }

  /// 柱状图
  Widget _buildItem(String title, String subtitle, Color color) {
    return ListTile(
      leading: Container(
        alignment: Alignment.center,
        width: 45.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              height: 20,
              width: 8.0,
              color: Colors.grey.shade300,
            ),
            SizedBox(width: 4.0),
            Container(
              height: 25,
              width: 8.0,
              color: Colors.grey.shade300,
            ),
            SizedBox(width: 4.0),
            Container(
              height: 40,
              width: 8.0,
              color: color,
            ),
            SizedBox(width: 4.0),
            Container(
              height: 30,
              width: 8.0,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(12, 10, 12, 0), // 都是 16 的话, 看起来比下面的课程那里要短
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text(
                    'Summary',
                    style: Theme.of(context).textTheme.headline4.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  )),
              Consumer<GlobalData>(
                  builder: (context, globalData, _) => Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0))),
                        elevation: 4.0,
                        color: Colors.white.withOpacity(globalData.opacity),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Consumer<RecentExamModel>(
                                  builder: (context, recentExamModel, _) =>
                                      _buildItem(
                                          '近期有',
                                          '${recentExamModel.count} 门考试',
                                          Colors.red)),
                            ),
                            VerticalDivider(),
                            Expanded(
                              child: Consumer<BalanceModel>(
                                  builder: (context, balanceModel, _) {
                                if (balanceModel.isLoading)
                                  return Column(children: <Widget>[
                                    CircularProgressIndicator()
                                  ]); // 不用 column 包裹会畸形
                                else
                                  return GestureDetector(
                                      onTap: () async {
                                        await balanceModel.refreshBalance();
                                        CommonSnackBar.buildSnackBar(
                                            context, balanceModel.msg);
                                      },
                                      child: _buildItem(
                                          '饭卡余额',
                                          '${balanceModel.balance} 元',
                                          Colors.green));
                              }),
                            ),
                          ],
                        ),
                      ))
            ]));
  }
}
