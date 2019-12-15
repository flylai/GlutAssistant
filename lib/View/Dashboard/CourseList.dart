import 'package:flutter/material.dart';
import 'package:glutassistant/Model/Dashboard/TodayCourseListModel.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:glutassistant/Widget/DetailCard.dart';
import 'package:provider/provider.dart';

class DashboardCourseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'Today',
                style: Theme.of(context).textTheme.display1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              )),
          _buildCourseList()
        ]);
  }

  Widget _buildCard(
      IconData icon, String course, String time, String location, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(26, 26, 10, 26),
          alignment: Alignment.centerRight,
          child: Opacity(
              opacity: 0.3,
              child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              )),
          decoration: BoxDecoration(
            color: color,
            // borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10.0),
              Text(
                course,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      time,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildCourseList() {
    return Consumer2<TodayCourseList, GlobalData>(
        builder: (context, todayCourseList, globalData, _) {
      todayCourseList.init(globalData.currentWeek, DateTime.now().weekday,
          globalData.campusType.index);
      if (todayCourseList.todayCourseList['courseList'].length > 0) {
        if (globalData.dashboardType == DashboardType.card)
          return _buildCourseListByCardNew();
        else
          return _buildCourseListByTimeline();
      } else {
        return DetailCard(
          BaseFunctionUtil.getRandomColor(),
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

  /// 旧的卡片
  Widget _buildCourseListByCard() {
    return Consumer2<TodayCourseList, GlobalData>(
        builder: (context, todayCourseList, globalData, _) {
      List<Widget> courseListWidget = [];
      for (TodayCourse course
          in todayCourseList.todayCourseList['courseList']) {
        String startTimeStr = course.startTimeStr;
        String endTimeStr = course.endTimeStr;
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
                      course.courseName,
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
                      course.location,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )
                  ]),
                )
              ],
            ))
          ],
        );

        courseListWidget.add(DetailCard(
          BaseFunctionUtil.getRandomColor(),
          child,
          elevation: 0.5,
          opacity: globalData.opacity,
        ));
      }

      return ListView(shrinkWrap: true, children: courseListWidget);
    });
  }

  Widget _buildCourseListByCardNew() {
    return Consumer2<TodayCourseList, GlobalData>(
        builder: (context, todayCourseList, globalData, _) {
      List<Widget> courseListWidget = []; // 课程的列表
      List<Widget> row;

      int len = todayCourseList.todayCourseList['courseList'].length;
      for (int i = 0; i < len; i++) {
        TodayCourse course = todayCourseList.todayCourseList['courseList'][i];
        if (i % 2 == 0) row = []; // 初始化一个新的列表

        String startTimeStr = course.startTimeStr;
        String endTimeStr = course.endTimeStr;

        row.add(Expanded(
          // 加课程
          child: _buildCard(
              Icons.bookmark,
              course.courseName,
              '$startTimeStr-$endTimeStr节',
              course.location,
              BaseFunctionUtil.getRandomColor()
                  .withOpacity(globalData.opacity)),
        ));
        if (i % 2 == 0 && i != len - 1)
          row.add(SizedBox(width: 16.0)); // 加了一个就加个占位置的

        // 满一行两节或者只有一节
        if (i % 2 == 0 || (i == len - 1 && i % 2 == 0)) {
          // 单行的课加入列表
          courseListWidget.add(Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: row,
            ),
          ));
        }
      }

      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: courseListWidget);
    });
  }

  Widget _buildCourseListByTimeline() {
    return Consumer<TodayCourseList>(builder: (context, courseList, _) {
      List<Step> todayCourseList = [];
      for (TodayCourse course in courseList.todayCourseList['courseList']) {
        RichText courseText = RichText(
            // X分钟上/下课 / 上完了
            text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
              TextSpan(text: course.text1),
              TextSpan(
                  text: course.text2,
                  style: TextStyle(fontSize: 18, color: Colors.pink)),
              TextSpan(text: course.text3)
            ]));
        Step step = Step(
          // 什么课 什么时间 谁上 在哪上
          state: course.courseState == CourseState.waiting
              ? StepState.indexed
              : StepState.complete,
          isActive: true,
          title: RichText(
            text: TextSpan(children: <TextSpan>[
              TextSpan(
                  text: course.classTime,
                  style: TextStyle(color: Colors.black)),
              TextSpan(
                  text: course.courseName,
                  style: TextStyle(color: Colors.black, fontSize: 20))
            ]),
          ),
          subtitle: RichText(
              text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                TextSpan(
                    text: course.location,
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                TextSpan(text: '  |  '),
                TextSpan(
                    text: course.teacher, style: TextStyle(color: Colors.black))
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
                currentStep: courseList.todayCourseList['currentStep'], // 现在第几节
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
