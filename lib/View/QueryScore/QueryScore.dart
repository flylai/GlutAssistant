import 'dart:core';

import 'package:flutter/material.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/Model/QueryScore/ExamScoreModel.dart';
import 'package:glutassistant/Model/QueryScore/FitnessScoreModel.dart';
import 'package:glutassistant/View/QueryScore/ExamScore.dart';
import 'package:glutassistant/View/QueryScore/FitnessScore.dart';
import 'package:glutassistant/Widget/SnackBar.dart';
import 'package:provider/provider.dart';

class QueryScore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<ExamScoreList>(
        create: (BuildContext context) => ExamScoreList(),
      ),
      ChangeNotifierProvider<FitnessScoreList>(
          create: (BuildContext context) => FitnessScoreList())
    ], child: Container(child: _buildBody()));
  }

  Widget _buildBody() {
    return Consumer<GlobalData>(
        builder: (context, globalData, _) => Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: Column(
                    children: <Widget>[
                      globalData.scoreType == ScoreType.exam
                          ? _buildDropdownArea()
                          : Container(),
                      _buildQueryButton(),
                    ],
                  ),
                ),
                Expanded(
                    child: globalData.scoreType == ScoreType.exam
                        ? ExamScore()
                        : FitnessScore())
              ],
            ));
  }

  Widget _buildQueryButton() {
    return Consumer3<ExamScoreList, FitnessScoreList, GlobalData>(
        builder: (context, examScoreList, fitnessScoreList, globalData, _) =>
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    onPressed: () async {
                      if (globalData.scoreType == ScoreType.exam) {
                        await examScoreList.queryExamScore();
                        CommonSnackBar.buildSnackBar(
                            context, examScoreList.msg);
                      } else {
                        await fitnessScoreList.queryFitnessScore();
                        CommonSnackBar.buildSnackBar(
                            context, fitnessScoreList.msg);
                      }
                    },
                    color: Colors.blue,
                    child: Text(
                      '查询成绩',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ));
  }

  Widget _buildDropdownArea() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildYearDropdown(),
        ),
        Expanded(
          child: _buildTermDropdown(),
        )
      ],
    );
  }

  Widget _buildTermDropdown() {
    return Consumer2<ExamScoreList, GlobalData>(
        builder: (context, examScore, globalData, _) =>
            DropdownButtonHideUnderline(
              child: DropdownButton(
                value: examScore.term,
                items: _generateTermList(),
                onChanged: (value) {
                  examScore.term = value;
                },
              ),
            ));
  }

  Widget _buildYearDropdown() {
    return Consumer2<ExamScoreList, GlobalData>(
        builder: (context, examScore, globalData, _) =>
            DropdownButtonHideUnderline(
              child: DropdownButton(
                value: examScore.year,
                items: _generateYearList(),
                onChanged: (value) {
                  examScore.year = value;
                },
              ),
            ));
  }

  List<DropdownMenuItem> _generateTermList() {
    List<DropdownMenuItem> items = List();
    DropdownMenuItem item = DropdownMenuItem(value: 1, child: Text('春'));
    items.add(item);
    DropdownMenuItem item2 = DropdownMenuItem(value: 2, child: Text('秋'));
    items.add(item2);
    return items;
  }

  List<DropdownMenuItem> _generateYearList() {
    List<DropdownMenuItem> items = List();
    int year = DateTime.now().year;
    for (var i = 0; i < 5; i++) {
      int _year = year - i;
      DropdownMenuItem item =
          DropdownMenuItem(value: _year, child: Text(_year.toString()));
      items.add(item);
    }
    return items;
  }
}
