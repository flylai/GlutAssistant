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
      for (Score score in examScoreList.examScoreList) {
        Widget scoreWidget = _buildItem(score, globalData.opacity);
        scoreList.add(scoreWidget);
      }
      return ListView(children: scoreList);
    });
  }

  Widget _buildItem(Score examScore, double opacity) {
    return Card(
      color: Colors.white.withOpacity(opacity),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(0))),
      elevation: 4,
      margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: <Widget>[
          Expanded(
              child: ListTile(
                title: Text(examScore.courseName),
                subtitle: Text(examScore.teacher),
              ),
              flex: 5),
          Expanded(
              child: Container(
                  alignment: Alignment.center,
                  height: 80,
                  color: Color(examScore.color).withOpacity(opacity),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          examScore.score,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        Text(
                          examScore.gpa,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ])),
              flex: 2)
        ],
      ),
    );
  }
}
