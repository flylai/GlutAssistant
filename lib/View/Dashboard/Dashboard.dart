import 'dart:core';

import 'package:flutter/material.dart';
import 'package:glutassistant/View/Dashboard/Balance.dart';
import 'package:glutassistant/View/Dashboard/CourseList.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[DashboardCourseList(), DashBoardBalance()],
    );
  }
}
