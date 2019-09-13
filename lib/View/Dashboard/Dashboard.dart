import 'dart:core';

import 'package:flutter/material.dart';
import 'package:glutassistant/Model/Dashboard/TodayCourseListModel.dart';
import 'package:glutassistant/View/Dashboard/Balance.dart';
import 'package:glutassistant/View/Dashboard/CourseList.dart';
import 'package:glutassistant/View/Dashboard/TomorrowCourseList.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TodayCourseList tcl = TodayCourseList();

    return ChangeNotifierProvider<TodayCourseList>.value(
        value: tcl,
        child: ListView(
          children: <Widget>[
            TomorrowCourseList(),
            DashboardCourseList(),
            DashBoardBalance()
          ],
        ));
  }
}
