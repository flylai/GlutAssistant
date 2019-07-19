import 'package:flutter/material.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/Model/QueryScore/FitnessScoreModel.dart';
import 'package:glutassistant/Widget/DetailCard.dart';
import 'package:provider/provider.dart';

class FitnessScore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return Consumer2<FitnessScoreList, GlobalData>(
        builder: (context, fitnessScoreList, globalData, _) {
      List<Widget> scoreList = [];

      if (fitnessScoreList.isLoading)
        return Center(child: CircularProgressIndicator());

      if (fitnessScoreList.fitnessDetail.length <= 0) return Container();
      scoreList.add(DetailCard(
        Color.fromARGB(255, 0, 188, 212).withOpacity(globalData.opacity),
        Center(
          child: Text(
              '成绩: ${fitnessScoreList.result['total']}\n结论: ${fitnessScoreList.result['conclusion']}',
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
        elevation: 0,
      ));

      for (var item in fitnessScoreList.fitnessDetail) {
        scoreList.add(
          Container(
              color: Colors.white.withOpacity(globalData.opacity),
              child: ListTile(
                onTap: () {},
                title: Text(item['name']),
                subtitle: Text(item['subtitle']),
                trailing:
                    Text(item['score'], style: TextStyle(color: Colors.green)),
              )),
        );
      }
      return ListView(children: scoreList);
    });
  }
}
