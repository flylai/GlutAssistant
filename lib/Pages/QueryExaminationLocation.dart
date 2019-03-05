import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/HttpUtil.dart';
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';
import 'package:glutassistant/Widget/DetailCard.dart';
import 'package:glutassistant/Widget/ProgressDialog.dart';
import 'package:glutassistant/Widget/SnackBar.dart';

class QueryExaminationLocation extends StatefulWidget {
  _QueryExaminationLocationState createState() =>
      _QueryExaminationLocationState();
}

class _QueryExaminationLocationState extends State<QueryExaminationLocation> {
  String _cookie = '';
  bool _isLoading = false;
  double _opacity = Constant.VAR_DEFAULT_OPACITY;
  List<Widget> examList = [];

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  void initState() {
    super.initState();
    _init();
  }

  Widget _buildBody() {
    if (_isLoading) return Center(child: new ProgressDialog());
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(13, 13, 13, 0),
          width: double.infinity,
          child: _buildQueryButton(),
        ),
        Expanded(
          child: ListView(
            children: examList,
          ),
        )
      ],
    );
  }

  _buildExamWidgetList(examListData) {
    List<Widget> examWidgetList = [];
    int timestamps = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    for (var exam in examListData) {
      Color color = Color(Constant
          .VAR_COLOR[Random.secure().nextInt(Constant.VAR_COLOR.length)]);
      Widget child = Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Text('${exam['course']}',
                style: TextStyle(color: Colors.white)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('还有 ', style: TextStyle(color: Colors.white)),
              Text(
                '${(DateTime.parse(exam['datetime']).millisecondsSinceEpoch ~/ 1000 - timestamps) ~/ 86400}',
                style: TextStyle(color: Colors.red, fontSize: 25),
              ),
              Text(' 天', style: TextStyle(color: Colors.white)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Text('${exam['datetime']} ${exam['interval']}',
                style: TextStyle(color: Colors.white)),
          ),
          Positioned(
            top: 0,
            right: 0,
            child:
                Text('${exam['type']}', style: TextStyle(color: Colors.white)),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Text('${exam['location']}',
                style: TextStyle(color: Colors.white)),
          )
        ],
      );
      examWidgetList.add(DetailCard(color, child));
    }
    setState(() {
      examList = examWidgetList;
    });
  }

  Widget _buildQueryButton() {
    return RaisedButton(
      onPressed: () {
        setState(() {
          _isLoading = true;
        });
        _cookie = FileUtil.readFile(Constant.FILE_SESSION);
        HttpUtil.queryExaminationLocation(_cookie, (callback) {
          if (callback['success'])
            _buildExamWidgetList(callback['data']);
          else
            CommonSnackBar.buildSnackBar(context, '未查到考试信息, 也许是你没登入教务或者最近没有考试');
          setState(() {
            _isLoading = false;
          });
        });
      },
      color: Colors.blue,
      child: Text(
        '查询考试地点',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  _init() async {
    await FileUtil.init();
    await SharedPreferenceUtil.init();
    _opacity = await SharedPreferenceUtil.getDouble('opacity');
    _opacity ??= Constant.VAR_DEFAULT_OPACITY;
    await FileUtil.init();
  }
}
