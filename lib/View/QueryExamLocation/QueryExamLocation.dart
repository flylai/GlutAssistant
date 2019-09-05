import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/Model/QueryExamLocation/ExamLocationListModel.dart';
import 'package:glutassistant/Widget/DetailCard.dart';
import 'package:glutassistant/Widget/SnackBar.dart';
import 'package:provider/provider.dart';

class QueryExamLocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        builder: (context) => ExamLocation(), child: _buildBody());
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(13, 13, 13, 0),
          width: double.infinity,
          child: _buildQueryButton(),
        ),
        Expanded(
          child: _buildExamWidgetList(),
        )
      ],
    );
  }

  Widget _buildExamWidgetList() {
    return Consumer2<ExamLocation, GlobalData>(
        builder: (context, examLocation, globalData, _) {
      if (examLocation.isLoading)
        return Center(child: CircularProgressIndicator());

      List<Widget> examWidgetList = [];
      if (examLocation.examList.length <= 0) return Container();
      for (var exam in examLocation.examList) {
        Color color = Color(Constant
            .VAR_COLOR[Random.secure().nextInt(Constant.VAR_COLOR.length)]);
        Widget child = Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child:
                  Text(exam['course'], style: TextStyle(color: Colors.white)),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.white),
                      children: <TextSpan>[
                    TextSpan(text: '还有'),
                    TextSpan(text: exam['leftTime'])
                  ]))
            ]),
            Positioned(
              bottom: 0,
              left: 0,
              child: Text('${exam['datetime']} ${exam['interval']}',
                  style: TextStyle(color: Colors.white)),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Text(exam['type'], style: TextStyle(color: Colors.white)),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child:
                  Text(exam['location'], style: TextStyle(color: Colors.white)),
            )
          ],
        );
        examWidgetList
            .add(DetailCard(color, child, opacity: globalData.opacity));
      }
      return ListView(children: examWidgetList);
    });
  }

  Widget _buildQueryButton() {
    return Consumer<ExamLocation>(
        builder: (context, examLocation, _) => RaisedButton(
            onPressed: () async {
              await examLocation.queryExamList();
              CommonSnackBar.buildSnackBar(context, examLocation.msg);
            },
            color: Colors.blue,
            child: Text(
              '查询考试地点',
              style: TextStyle(color: Colors.white),
            )));
  }
}
