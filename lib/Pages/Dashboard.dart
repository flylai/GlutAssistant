import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/BalanceUtil.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:glutassistant/Utility/SQLiteUtil.dart';
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';
import 'package:glutassistant/Widget/DetailCard.dart';
import 'package:glutassistant/Widget/SnackBar.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _dashboardDisplayType = 0;
  int _weekday = DateTime.now().weekday;
  bool _isLoading = false;
  double _opacity = Constant.VAR_DEFAULT_OPACITY;

  Map<String, dynamic> _balance = {'balance': '未知', 'lastupdate': '从未更新'};
  List<Map<String, dynamic>> _courseList = [];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _buildBody(),
    );
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  Widget _buildBalanceArea() {
    Widget child = Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          child: Text('一卡通余额', style: TextStyle(color: Colors.white)),
        ),
        _buildBalanceText(),
        Positioned(
          bottom: 0,
          right: 0,
          child: Row(
            children: <Widget>[
              Text(
                '${_balance['lastupdate']}',
                style: TextStyle(color: Colors.white),
              ),
              GestureDetector(
                onTap: () {
                  if (_isLoading) return;
                  setState(() {
                    _isLoading = true;
                  });
                  BalanceUtil.refreshBalance().then((onValue) {
                    setState(() {
                      _balance = onValue;
                    });
                    CommonSnackBar.buildSnackBar(context, _balance['msg']);
                    setState(() {
                      _isLoading = false;
                    });
                  });
                },
                child: Icon(
                  Icons.sync,
                  color: Colors.white,
                ),
              )
            ],
          ),
        )
      ],
    );
    Color color = Color(
        Constant.VAR_COLOR[Random.secure().nextInt(Constant.VAR_COLOR.length)]);
    return DetailCard(
      color,
      child,
      elevation: 0.5,
      opacity: _opacity,
    );
  }

  Widget _buildBalanceText() {
    if (_isLoading) return CircularProgressIndicator();
    return Text(
      '￥${_balance['balance']}',
      style: TextStyle(fontSize: 40, color: Colors.white),
    );
  }

  List<Widget> _buildBody() {
    List<Widget> mainBody = [];
    mainBody = _buildCourseList();
    mainBody.add(_buildBalanceArea());
    return mainBody;
  }

  List<Widget> _buildCourseList() {
    DateTime nowDateTime = DateTime.now();
    int year = nowDateTime.year;
    int month = nowDateTime.month;
    int day = nowDateTime.day;
    int count = -1;

    List<Widget> todayCourseList = [];
    List<Step> courseTimeline = [];
    courseTimeline.clear();
    if (_courseList.length > 0) {
      for (int i = 0; i < _courseList.length; i++) {
        int startTime = _courseList[i]['startTime'];
        int endTime = _courseList[i]['endTime'];
        String startTimeStr = BaseFunctionUtil.getTimeByNum(startTime);
        String endTimeStr = BaseFunctionUtil.getTimeByNum(endTime);
        if (_dashboardDisplayType == 0) {
          Widget child = Row(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.fromLTRB(1, 0, 10, 0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        color: Color(0xFFF9FF69),
                        size: 25,
                      ),
                      Text(
                        '$startTimeStr - $endTimeStr节',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )
                    ],
                  )),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Row(children: <Widget>[
                      Icon(
                        Icons.class_,
                        color: Color(0xFFF1F2FF),
                        size: 25,
                      ),
                      Expanded(
                          child: Text(
                        _courseList[i]['courseName'],
                        style: TextStyle(fontSize: 20, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ))
                    ]),
                  ),
                  Container(
                    child: Row(children: <Widget>[
                      Icon(
                        Icons.location_on,
                        color: Color(0xFF43E9FF),
                        size: 25,
                      ),
                      Text(
                        _courseList[i]['location'],
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )
                    ]),
                  )
                ],
              ))
            ],
          );
          Color color = Color(Constant
              .VAR_COLOR[Random.secure().nextInt(Constant.VAR_COLOR.length)]);
          DetailCard course = DetailCard(
            color,
            child,
            elevation: 0.5,
            opacity: _opacity,
          );
          todayCourseList.add(course);
        } else {
          int classStartHour =
              Constant.CLASS_TIME[_courseList[i]['startTime']][0][0];
          int classStartMinute =
              Constant.CLASS_TIME[_courseList[i]['startTime']][0][1];

          int classEndHour =
              Constant.CLASS_TIME[_courseList[i]['endTime']][1][0];
          int classEndMinute =
              Constant.CLASS_TIME[_courseList[i]['endTime']][1][1];

          DateTime classBeginTime =
              DateTime(year, month, day, classStartHour, classStartMinute);
          DateTime classOverTime =
              DateTime(year, month, day, classEndHour, classEndMinute);
          String beforeClassBeginTime =
              BaseFunctionUtil.getDuration(classBeginTime, nowDateTime);
          String beforeClassOverTime =
              BaseFunctionUtil.getDuration(classOverTime, nowDateTime);
          print(beforeClassOverTime);

          RichText courseText = RichText(text: null);
          StepState courseState = StepState.indexed;
          if (beforeClassBeginTime[0] == '-' && beforeClassOverTime[0] != '-') {
            count = i;
            courseText = RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: <TextSpan>[
                  TextSpan(text: '还有'),
                  TextSpan(
                      text: '$beforeClassOverTime',
                      style: TextStyle(fontSize: 18, color: Colors.pink)),
                  TextSpan(text: '才下课,认真听课哟~')
                ]));
          } else if (beforeClassBeginTime[0] != '-' && count == -1) {
            count = i;
            courseText = RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: <TextSpan>[
                  TextSpan(text: '还有'),
                  TextSpan(
                      text: '$beforeClassBeginTime',
                      style: TextStyle(fontSize: 18, color: Colors.pink)),
                  TextSpan(text: '就要上课啦')
                ]));
          } else if (beforeClassOverTime[0] == '-') {
            if (i == _courseList.length - 1) count = i;
            courseText = RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: <TextSpan>[TextSpan(text: '这节课已经过去了哦')]));
            courseState = StepState.complete;
          }
          Step course = Step(
            state: courseState,
            isActive: true,
            title: RichText(
              text: TextSpan(children: <TextSpan>[
                TextSpan(
                    text: '$startTimeStr - $endTimeStr节 ',
                    style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: '${_courseList[i]['courseName']}',
                    style: TextStyle(color: Colors.black, fontSize: 20))
              ]),
            ),
            subtitle: RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: <TextSpan>[
                  TextSpan(
                      text: '${_courseList[i]['location']}',
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                  TextSpan(text: '  |  '),
                  TextSpan(
                      text: '${_courseList[i]['teacher']}',
                      style: TextStyle(color: Colors.black))
                ])),
            content: Center(child: courseText),
          );
          courseTimeline.add(course);
        }
      }
      todayCourseList.add(Container(
          child: Stepper(
            physics: ClampingScrollPhysics(),
            currentStep: count,
            controlsBuilder: (BuildContext context,
                {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
              return Container();
            },
            steps: courseTimeline,
          ),
          color: Colors.white.withOpacity(_opacity)));
    } else {
      Color color = Color(Constant
          .VAR_COLOR[Random.secure().nextInt(Constant.VAR_COLOR.length)]);
      todayCourseList.add(DetailCard(
        color,
        Container(
            alignment: Alignment.center,
            child: Text('今天没有课上哦(๑˙ー˙๑)',
                style: TextStyle(fontSize: 20, color: Colors.white))),
        elevation: 0.5,
        opacity: _opacity,
      ));
    }
    return todayCourseList;
  }

  void _init() async {
    await BalanceUtil.init();
    await SharedPreferenceUtil.init();
    _opacity = await SharedPreferenceUtil.getDouble('opacity');
    _opacity ??= Constant.VAR_DEFAULT_OPACITY;
    _dashboardDisplayType = await SharedPreferenceUtil.getInt('dashboard_type');
    _dashboardDisplayType ??= 0;

    await SQLiteUtil.init();
    await SharedPreferenceUtil.init();
    String _firstWeek = await SharedPreferenceUtil.getString('first_week');
    _firstWeek ??= '1';
    String _firstWeekTimestamp =
        await SharedPreferenceUtil.getString('first_week_timestamp');
    _firstWeekTimestamp ??= '1';
    DateTime _now = DateTime.now();
    DateTime _startWeek = DateTime(_now.year, _now.month, _now.day)
        .subtract(Duration(days: _now.weekday - 1));
    int _currentWeek = (((_startWeek.millisecondsSinceEpoch / 1000 -
                    int.parse(_firstWeekTimestamp)) ~/
                25200 /
                24)
            .ceil() +
        int.parse(_firstWeek));

    await SQLiteUtil.queryCourse(_currentWeek, _weekday).then((onValue) {
      if (onValue.length > 0) {
        for (int i = 0; i < onValue.length; i++) {
          _courseList.add(onValue[i]);
        }
      }
      setState(() {
        _balance = BalanceUtil.getCacheBalance();
        _dashboardDisplayType;
        _courseList;
        _opacity;
      });
    });
  }
}
