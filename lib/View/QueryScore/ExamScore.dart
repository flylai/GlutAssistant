import 'package:flutter/material.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/Model/QueryScore/ExamScoreModel.dart';
import 'package:provider/provider.dart';

class ExamScore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return Consumer2<ExamScoreList, GlobalData>(
        builder: (context, examScoreList, globalData, _) {
      List<Widget> scoreList = [];

      if (examScoreList.isLoading)
        return Center(child: CircularProgressIndicator());
      for (var score in examScoreList.examScoreList) {
        Widget scoreWidget = Container(
            color: Colors.white.withOpacity(globalData.opacity),
            child: ListTile(
              title: Text(score['course']),
              subtitle: Text(score['subtitle']),
              trailing: Text(
                score['score'],
                style: TextStyle(
                    color: double.parse(score['gpa']) == 0
                        ? Colors.red
                        : Colors.green),
              ),
              onTap: () {},
            ));
        scoreList.add(scoreWidget);
      }
      return ListView(children: scoreList);
    });
  }
}
