import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/Dashboard/CourseListModel.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:glutassistant/Widget/DetailCard.dart';
import 'package:provider/provider.dart';

class DashboardCourseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (context) => CourseList(),
      child: Container(child: _buildCourseList()),
    );
  }

  Widget _buildCourseListByCard() {
    return Consumer2<CourseList, GlobalData>(
        builder: (context, courseList, globalData, _) {
      List<Widget> todayCourseList = [];
      for (var course in courseList.courseList) {
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
        todayCourseList.add(DetailCard(
          color,
          child,
          elevation: 0.5,
          opacity: globalData.opacity,
        ));
      }

      return ListView(shrinkWrap: true, children: todayCourseList);
    });
  }

  Widget _buildCourseListByTimeline() {
    DateTime nowDateTime = DateTime.now();
    int year = nowDateTime.year;
    int month = nowDateTime.month;
    int day = nowDateTime.day;

    return Consumer<CourseList>(builder: (context, courseList, _) {
      List<Step> todayCourseList = [];
      int stepPosition = 0;
      bool isCheck = false; // 时间早于第一节课的判定

      for (int i = 0; i < courseList.courseList.length; i++) {
        int startTime = courseList.courseList[i]['startTime'];
        int endTime = courseList.courseList[i]['endTime'];
        String startTimeStr = BaseFunctionUtil().getTimeByNum(startTime);
        String endTimeStr = BaseFunctionUtil().getTimeByNum(endTime);

        // 时间轴
        int classStartHour =
            Constant.CLASS_TIME[courseList.courseList[i]['startTime']][0][0];
        int classStartMinute =
            Constant.CLASS_TIME[courseList.courseList[i]['startTime']][0][1];

        int classEndHour =
            Constant.CLASS_TIME[courseList.courseList[i]['endTime']][1][0];
        int classEndMinute =
            Constant.CLASS_TIME[courseList.courseList[i]['endTime']][1][1];

        DateTime classBeginTime =
            DateTime(year, month, day, classStartHour, classStartMinute);
        DateTime classOverTime =
            DateTime(year, month, day, classEndHour, classEndMinute);
        String beforeClassBeginTime =
            BaseFunctionUtil().getDuration(classBeginTime, nowDateTime);
        String beforeClassOverTime =
            BaseFunctionUtil().getDuration(classOverTime, nowDateTime);

        RichText courseText = RichText(text: TextSpan(text: '?'));
        StepState courseState = StepState.indexed;
        if (beforeClassBeginTime[0] == '-' && beforeClassOverTime[0] != '-') {
          stepPosition = i;
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
        } else if (beforeClassBeginTime[0] != '-' && !isCheck) {
          stepPosition = i;
          isCheck = true;
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
                  text: '${courseList.courseList[i]['courseName']}',
                  style: TextStyle(color: Colors.black, fontSize: 20))
            ]),
          ),
          subtitle: RichText(
              text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                TextSpan(
                    text: '${courseList.courseList[i]['location']}',
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                TextSpan(text: '  |  '),
                TextSpan(
                    text: '${courseList.courseList[i]['teacher']}',
                    style: TextStyle(color: Colors.black))
              ])),
          content: Center(child: courseText),
        );
        todayCourseList.add(course);
      }

      return Consumer<GlobalData>(
          builder: (context, globalData, _) => Container(
              child: Stepper(
                physics: ClampingScrollPhysics(),
                currentStep: stepPosition,
                controlsBuilder: (BuildContext context,
                    {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                  return Container();
                },
                steps: todayCourseList,
              ),
              color: Colors.white.withOpacity(globalData.opacity)));
    });
  }

  Widget _buildCourseList() {
    return Consumer2<CourseList, GlobalData>(
        builder: (context, courseList, globalData, _) {
      courseList.init();
      if (courseList.courseList.length > 0) {
        if (globalData.dashboardType == 0)
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
}
