import 'dart:core';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/HttpUtil.dart';
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';
import 'package:glutassistant/Widget/DetailCard.dart';
import 'package:glutassistant/Widget/ProgressDialog.dart';
import 'package:glutassistant/Widget/SnackBar.dart';

class QueryScore extends StatefulWidget {
  final int _queryScoreType;
  QueryScore(this._queryScoreType);
  _QueryScoreState createState() => _QueryScoreState();
}

class _QueryScoreState extends State<QueryScore> {
  int _selectYearValue = DateTime.now().year;
  int _selectTermValue = 2;
  bool _isLoading = false;
  double _opacity = Constant.VAR_DEFAULT_OPACITY;
  String _cookie;
  String _studentId;
  List<Widget> scoreList = [];
  List<Widget> fitnessList = [];

  @override
  Widget build(BuildContext context) {
    return Container(child: _buildBody());
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  Widget _buildBody() {
    if (_isLoading)
      return Center(child: new ProgressDialog());
    else if (widget._queryScoreType == 1) {
      return Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(13, 13, 13, 0),
            width: double.infinity,
            child: _buildQueryButton(),
          ),
          Expanded(
            child: ListView(
              children: fitnessList,
            ),
          )
        ],
      );
    }
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
          child: Column(
            children: <Widget>[
              _buildDropdownArea(),
              _buildQueryButton(),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: scoreList,
          ),
        )
      ],
    );
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

  Widget _buildQueryButton() {
    return Row(
      children: <Widget>[
        Expanded(
          child: RaisedButton(
            onPressed: () async {
              _cookie = FileUtil.readFile(Constant.FILE_SESSION);
              setState(() {
                _isLoading = true;
              });
              if (widget._queryScoreType == 1) {
                if (_studentId == null) {
                  await SharedPreferenceUtil.getString('student_id')
                      .then((onValue) {
                    _studentId = onValue;
                  });
                }

                await HttpUtil.queryFitnessTestScore(_studentId, (callback) {
                  fitnessList.clear();
                  if (callback['success'] && callback['data'].length > 0) {
                    fitnessList.add(DetailCard(
                      Color.fromARGB(255, 0, 188, 212).withOpacity(_opacity),
                      Center(
                        child: Text(
                            '成绩: ${callback['result']['total']}\n结论: ${callback['result']['conclusion']}',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      elevation: 0,
                    ));

                    for (var item in callback['data']) {
                      fitnessList.add(
                        Container(
                            color: Colors.white.withOpacity(_opacity),
                            child: ListTile(
                              onTap: () {},
                              title: Text(item['name']),
                              subtitle: Text(
                                  '成绩: ${item['record']} 结论:${item['result']}'),
                              trailing: Text(item['score'],
                                  style: TextStyle(color: Colors.green)),
                            )),
                      );
                    }
                  }
                });
              } else {
                await HttpUtil.queryScore(_selectYearValue.toString(),
                    _selectTermValue.toString(), _cookie, (callback) async {
                  scoreList.clear();
                  if (callback['success'] && callback['data'].length > 0) {
                    int campusType =
                        Constant.URL_JW == Constant.URL_JW_GLUT ? 1 : 2;
                    for (var item in callback['data']) {
                      String score;
                      if (item['score'].contains(RegExp(r'(?!不)[秀中良格]$'))) {
                        score = item['score'] +
                            (campusType == 1
                                ? ('(' +
                                    ((5 + double.parse(item['gpa'])) * 10)
                                        .toString() +
                                    ')')
                                : '');
                      } else {
                        score = item['score']
                            .toString()
                            .replaceAllMapped(RegExp(r'.*>(\d+|不及格)<.*'),
                                (Match m) => '${m[1]}')
                            .replaceAll('&nbsp;', '');
                      }
                      scoreList.add(Container(
                          color: Colors.white.withOpacity(_opacity),
                          child: ListTile(
                            title: Text(item['course']),
                            subtitle: Text(item['teacher'] +
                                (item['teacher'] == '' ? '' : '    ') +
                                (campusType == 1 ? '绩点: ' : '学分: ') +
                                item['gpa']),
                            trailing: Text(
                              score,
                              style: TextStyle(
                                  color: double.parse(item['gpa']) == 0
                                      ? Colors.red
                                      : Colors.green),
                            ),
                            onTap: () {},
                          )));
                    }
                  } else
                    CommonSnackBar.buildSnackBar(
                        context, '获取成绩失败了，也许是你没登录教务或者连接不上教务');
                });
              }
              setState(() {
                _isLoading = false;
              });
            },
            color: Colors.blue,
            child: Text(
              '查询成绩',
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTermDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: _selectTermValue,
        items: _generateTermList(),
        onChanged: (value) {
          setState(() {
            _selectTermValue = value;
            print(value);
          });
        },
      ),
    );
  }

  Widget _buildYearDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: _selectYearValue,
        items: _generateYearList(),
        onChanged: (value) {
          setState(() {
            _selectYearValue = value;
          });
        },
      ),
    );
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

  _init() async {
    await FileUtil.init();
    await SharedPreferenceUtil.init();
    _opacity = await SharedPreferenceUtil.getDouble('opacity');
    setState(() {
      _opacity ??= Constant.VAR_DEFAULT_OPACITY;
    });
  }
}
