import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/Model/Timetable/WeekCoureListModel.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:provider/provider.dart';

class Timetable extends StatelessWidget {
  final int _selectedWeek;
  final int _currentWeek;

  Timetable(this._selectedWeek, this._currentWeek);

  @override
  Widget build(BuildContext context) {
    WeekCourseList wcl = WeekCourseList();
    wcl.selectedWeek = _selectedWeek;
    wcl.currentWeek = _currentWeek;
    wcl.refreshDateList();
    wcl.refreshTimetable();
    return ChangeNotifierProvider<WeekCourseList>.value(
      value: wcl,
      child: Container(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return Consumer2<WeekCourseList, GlobalData>(
        builder: (context, weekCourseList, globalData, _) => Column(
              children: <Widget>[
                _buildDateList(),
                Expanded(
                  child: GestureDetector(
                      onHorizontalDragEnd: (value) {
                        if (value.velocity.pixelsPerSecond.dx > 1000 &&
                            weekCourseList.selectedWeek - 1 > 0) {
                          weekCourseList.selectedWeek--;
                          globalData.selectedWeek--;
                        }
                        if (value.velocity.pixelsPerSecond.dx < -1000 &&
                            weekCourseList.selectedWeek + 1 < 26) {
                          weekCourseList.selectedWeek++;
                          globalData.selectedWeek++;
                        }
                      },
                      child: ListView(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                    color: Colors.white
                                        .withOpacity(globalData.opacity),
                                    child: _buildLeftTimeList()),
                                flex: 1,
                              ),
                              Expanded(
                                child: _buildTimetable(),
                                flex: 14,
                              )
                            ],
                          )
                        ],
                      )),
                )
              ],
            ));
  }

  Widget _buildDateList() {
    return Consumer<GlobalData>(
        builder: (context, globalData, _) => Container(
            child: _gernerateDateText(),
            color: Colors.white.withOpacity(globalData.opacity)));
  }

  Widget _buildLeftTimeList() {
    List<Widget> leftTimeList = [];
    for (int i = 1; i < 15; i++) {
      Container item = Container(
        alignment: Alignment.center,
        height: Constant.VAR_COURSE_HEIGHT,
        child: Text(
          BaseFunctionUtil().getTimeByNum(i),
          textAlign: TextAlign.center,
        ),
      );
      leftTimeList.add(Divider(
        height: 0.6,
      ));
      leftTimeList.add(item);
    }
    return Column(children: leftTimeList);
  }

  Widget _buildTimetable() {
    return Consumer2<WeekCourseList, GlobalData>(
        builder: (context, weekCourseList, globalData, _) {
      List<Widget> timetable = [];
      for (int i = 0; i < 7; i++) {
        // ä¸€å‘¨ä¸ƒå¤©
        List<Widget> weekdayCourseList = [];
        for (int j = 0; j < weekCourseList.weekCourse[i].length; j++) {
          Widget widget = GestureDetector(
              onTap: () async {
                if (weekCourseList.weekCourse[i][j]['empty']) return;
                await _queryCourseList(
                    context,
                    weekCourseList.weekCourse[i][j]['weekday'],
                    weekCourseList.weekCourse[i][j]['startTime'],
                    weekCourseList.weekCourse[i][j]['endTime']);
              },
              child: Container(
                padding:
                    EdgeInsets.all(weekCourseList.weekCourse[i][j]['padding']),
                margin: EdgeInsets.fromLTRB(0.5,
                    weekCourseList.weekCourse[i][j]['marginTop'], 0.5, 0.5),
                color: weekCourseList.weekCourse[i][j]['color'].withOpacity(
                    weekCourseList.weekCourse[i][j]['empty']
                        ? 0.0
                        : globalData.opacity),
                alignment: Alignment.topLeft,
                height: weekCourseList.weekCourse[i][j]['height'],
                child: Text(
                  '${weekCourseList.weekCourse[i][j]['text']}',
                  style: TextStyle(color: Colors.white),
                ),
              ));
          weekdayCourseList.add(widget);
        }
        timetable.add(Expanded(
          child: Column(
            children: weekdayCourseList,
          ),
          flex: 2,
        ));
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: timetable,
      );
    });
  }

  Future<void> _queryCourseList(context, weekday, startTime, endTime) async {
    WeekCourseList weekCourseList = Provider.of<WeekCourseList>(context);
    await weekCourseList.queryCourseList(weekday, startTime, endTime);
    List<Widget> courselistwidget = [];
    for (int i = 0; i < weekCourseList.courseList.length; i++) {
      Container course = Container(
        margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
        padding: EdgeInsets.all(7),
        decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.book, color: Colors.amber),
                Text(weekCourseList.courseList[i]['courseName'])
              ],
            ),
            Row(
              children: <Widget>[
                Icon(Icons.person, color: Colors.pink),
                Text(weekCourseList.courseList[i]['teacher'])
              ],
            ),
            Row(
              children: <Widget>[
                Icon(Icons.location_on, color: Colors.teal),
                Text(weekCourseList.courseList[i]['location'])
              ],
            ),
            Row(
              children: <Widget>[
                Icon(Icons.access_time, color: Colors.cyan),
                Text('${weekCourseList.courseList[i]['week']}')
              ],
            )
          ],
        ),
      );
      courselistwidget.add(course);
    }
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: courselistwidget,
          ));
        });
  }

  Widget _gernerateDateText() {
    return Consumer<WeekCourseList>(builder: (context, weekCourseList, _) {
      List<Widget> datelist = [];
      Widget month = Expanded(
        child:
            Text('${weekCourseList.dateList[0]}', textAlign: TextAlign.center),
        flex: 1,
      );
      datelist.add(month);

      for (int i = 1; i <= 7; i++) {
        Widget wd = Expanded(
          child: Text(
            '${weekCourseList.dateList[i]['weekday']}',
            style: TextStyle(color: weekCourseList.dateList[i]['color']),
            textAlign: TextAlign.center,
          ),
          flex: 2,
        );
        datelist.add(wd);
      }
      return Row(children: datelist);
    });
  }
}
