import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/Dashboard/TodayCourseListModel.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:glutassistant/Widget/DetailCard.dart';
import 'package:provider/provider.dart';

class DashboardCourseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (context) => TodayCourseList(),
      child: Container(child: _buildCourseList()),
    );
  }

  Widget _buildCourseList() {
    return Consumer2<TodayCourseList, GlobalData>(
        builder: (context, todayCourseList, globalData, _) {
      todayCourseList.init(globalData.currentWeek, DateTime.now().weekday);
      if (todayCourseList.courseList['courseList'].length > 0) {
        if (globalData.dashboardType == DashboardType.card)
          return _buildCourseListByCard();
        else
          return _buildCourseListByTimeline();
      } else {
        Color color = Color(Constant
            .VAR_COLOR[Random.secure().nextInt(Constant.VAR_COLOR.length)]);
        return DetailCard(
          color,
          Container(
              alignment: Alignment.center,
              child: Text('今天没有课上哦(๑˙ー˙๑)',
                  style: TextStyle(fontSize: 20, color: Colors.white))),
          elevation: 0.5,
          opacity: globalData.opacity,
        );
      }
    });
  }

  Widget _buildCourseListByCard() {
    return Consumer2<TodayCourseList, GlobalData>(
        builder: (context, todayCourseList, globalData, _) {
      List<Widget> courseListWidget = [];
      for (var course in todayCourseList.courseList['courseList']) {
        int startTime = course['startTime'];
        int endTime = course['endTime'];
        String startTimeStr = BaseFunctionUtil().getTimeByNum(startTime);
        String endTimeStr = BaseFunctionUtil().getTimeByNum(endTime);
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
                      course['courseName'],
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
                      course['location'],
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
        courseListWidget.add(DetailCard(
          color,
          child,
          elevation: 0.5,
          opacity: globalData.opacity,
        ));
      }

      return ListView(shrinkWrap: true, children: courseListWidget);
    });
  }

  Widget _buildCourseListByTimeline() {
    return Consumer<TodayCourseList>(builder: (context, courseList, _) {
      List<Step> todayCourseList = [];
      for (var course in courseList.courseList['courseList']) {
        RichText courseText = RichText(
            // X分钟上/下课 / 上完了
            text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
              TextSpan(text: course['text1']),
              TextSpan(
                  text: course['text2'],
                  style: TextStyle(fontSize: 18, color: Colors.pink)),
              TextSpan(text: course['text3'])
            ]));
        Step step = Step(
          // 什么课 什么时间 谁上 在哪上
          state: course['state'] == CourseState.waiting
              ? StepState.indexed
              : StepState.complete,
          isActive: true,
          title: RichText(
            text: TextSpan(children: <TextSpan>[
              TextSpan(
                  text: course['classTime'],
                  style: TextStyle(color: Colors.black)),
              TextSpan(
                  text: course['course'],
                  style: TextStyle(color: Colors.black, fontSize: 20))
            ]),
          ),
          subtitle: RichText(
              text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                TextSpan(
                    text: course['location'],
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                TextSpan(text: '  |  '),
                TextSpan(
                    text: course['teacher'],
                    style: TextStyle(color: Colors.black))
              ])),
          content: Center(
            child: courseText,
          ),
        );
        todayCourseList.add(step);
      }

      return Consumer<GlobalData>(
          builder: (context, globalData, _) => Container(
              child: Stepper(
                physics: ClampingScrollPhysics(),
                currentStep: courseList.courseList['currentStep'], // 现在第几节
                controlsBuilder: (BuildContext context,
                    {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                  return Container();
                },
                steps: todayCourseList,
              ),
              color: Colors.white.withOpacity(globalData.opacity)));
    });
  }
}
