import 'package:flutter/material.dart';
import 'package:glutassistant/Model/Dashboard/RecentExamModel.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:provider/provider.dart';

class RecentExamList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16), child: _buildList());
  }

  Widget _buildItem(Color color, String name, String leftTime) {
    return Container(
      padding: EdgeInsets.all(8.0),
      height: 80,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            name,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            leftTime,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Consumer2<RecentExamModel, GlobalData>(
        builder: (context, recentExamModel, globalData, _) {
      List<Widget> examList = []..add(Text(
          'Recent Exam(s)',
          style: TextStyle(
            color: Colors.deepOrange,
          ),
        ));

      List<Widget> row;
      int len = recentExamModel.count;
      for (int i = 0; i < len; i++) {
        if (i % 2 == 0) row = [];
        row.add(Expanded(
            child: _buildItem(
                Colors.green.withOpacity(globalData.opacity),
                recentExamModel.examList[i].courseName,
                recentExamModel.examList[i].leftTime)));
        if (i % 2 == 0 && i != len - 1)
          row.add(SizedBox(width: 16.0)); // 加了一个就加个占位置的

        // 满一行两节或者只有一节
        if (i % 2 == 0 || (i == len - 1 && i % 2 == 0)) {
          // 单行的考试加入列表
          examList.add(Container(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Row(
              children: row,
            ),
          ));
        }
      }
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: examList);
    });
  }
}
