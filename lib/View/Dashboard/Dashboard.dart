import 'dart:core';

import 'package:flutter/material.dart';
import 'package:glutassistant/Model/Dashboard/RecentExamModel.dart';
import 'package:glutassistant/Model/Dashboard/TodayCourseListModel.dart';
import 'package:glutassistant/View/Dashboard/CourseList.dart';
import 'package:glutassistant/View/Dashboard/Summary.dart';
import 'package:glutassistant/View/Dashboard/TomorrowCourseList.dart';
import 'package:provider/provider.dart';

import 'RecentExamList.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (BuildContext context) => RecentExamModel()),
          ChangeNotifierProvider(
              create: (BuildContext context) => TodayCourseList())
        ],
        child: ListView(children: <Widget>[
          DashboardSummary(),
          DashboardCourseList(),
          TomorrowCourseList(),
          RecentExamList(),
        ]));
  }
}
