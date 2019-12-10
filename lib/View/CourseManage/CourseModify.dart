import 'package:flutter/material.dart';

import 'package:glutassistant/Model/CourseManage/Course.dart';
import 'package:glutassistant/Model/CourseManage/CourseModel.dart';
import 'package:glutassistant/Utility/SQLiteUtil.dart';
import 'package:glutassistant/Widget/TimePicker.dart';
import 'package:glutassistant/Widget/WeekPicker.dart';
import 'package:provider/provider.dart';

class CourseModify extends StatelessWidget {
  final SingleCourse singleCourse;
  final int type; //0添加 1修改
  CourseModify(this.singleCourse, {this.type = 1});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(type == 0 ? '添加课程' : '修改课程')),
      body: ChangeNotifierProvider<SingleCourse>.value(
          value: singleCourse,
          child: Container(
            child: ListView(
              children: <Widget>[
                _buildCourseNameEdit(),
                _buildWeek(context),
                _buildTime(context),
                _buildTeacherEdit(),
                _buildLocationEdit(),
                _buildSaveButton(),
              ],
            ),
          )),
    );
  }

  Widget _buildCourseNameEdit() {
    return Consumer<SingleCourse>(
        builder: (context, singleCourse, _) => Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: singleCourse.courseNameController,
              decoration: InputDecoration(
                  icon: Icon(Icons.book, size: 30, color: Colors.amber),
                  hintText: '课程名称'),
            )));
  }

  Widget _buildLocationEdit() {
    return Consumer<SingleCourse>(
        builder: (context, singleCourseX, _) => Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: singleCourse.locationController,
              decoration: InputDecoration(
                  icon: Icon(Icons.location_on, size: 30, color: Colors.pink),
                  hintText: '上课地点'),
            )));
  }

  Widget _buildSaveButton() {
    return Consumer<SingleCourse>(
        builder: (context, singleCourse, _) => Container(
              width: 120,
              padding: EdgeInsets.all(10),
              child: FlatButton(
                shape: Border.all(color: Colors.blue),
                onPressed: () async {
                  singleCourse.courseName =
                      singleCourse.courseNameController.text;
                  singleCourse.teacher = singleCourse.teacherController.text;
                  singleCourse.location = singleCourse.locationController.text;

                  Course course = Course(
                      singleCourse.courseNameController.text,
                      singleCourse.teacherController.text,
                      singleCourse.startWeek,
                      singleCourse.endWeek,
                      singleCourse.weekday,
                      singleCourse.weekType,
                      singleCourse.startTime,
                      singleCourse.endTime,
                      singleCourse.locationController.text);

                  SQLiteUtil su = await SQLiteUtil.getInstance();

                  if (type == 0)
                    await su.insertTimetable(course);
                  else
                    await su.updateCourse(singleCourse.courseNo, course);
                  Navigator.of(context).pop();
                },
                child: Text('保存'),
              ),
            ));
  }

  Widget _buildTeacherEdit() {
    return Consumer<SingleCourse>(builder: (context, singleCourseX, _) {
      return Container(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: singleCourse.teacherController,
            decoration: InputDecoration(
                icon: Icon(Icons.person, size: 30, color: Colors.purple),
                hintText: '教师'),
          ));
    });
  }

  Widget _buildTime(BuildContext context) {
    return Consumer<SingleCourse>(
        builder: (context, singleCourseX, _) => Container(
              padding: EdgeInsets.all(10),
              height: 68,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Positioned(
                    left: 0,
                    child: Icon(Icons.timeline, size: 30, color: Colors.cyan),
                  ),
                  Positioned(
                    left: 46,
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 48,
                        child: Text(
                            '星期${singleCourse.weekdayStr}  第 ${singleCourse.startTimeStr} 至 ${singleCourse.endTimeStr} 节'),
                      ),
                      onTap: () => {
                        TimePicker.showTimePicker(
                          context,
                          showTitleActions: true,
                          initialWeekday: singleCourse.weekday,
                          initialStartTime: singleCourse.startTime,
                          initialEndTime: singleCourse.endTime,
                          confirm: Text(
                            '确定',
                            style: TextStyle(color: Colors.red),
                          ),
                          cancel: Text(
                            '取消',
                            style: TextStyle(color: Colors.cyan),
                          ),
                          onConfirm: (weekday, startTime, endTime) {
                            singleCourse.weekday = weekday;
                            singleCourse.startTime = startTime;
                            singleCourse.endTime = endTime;
                          },
                        )
                      },
                    ),
                  )
                ],
              ),
            ));
  }

  Widget _buildWeek(BuildContext context) {
    return Consumer<SingleCourse>(
        builder: (context, singleCourseX, _) => Container(
              padding: EdgeInsets.all(10),
              height: 68,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Positioned(
                    left: 0,
                    child: Icon(Icons.calendar_today,
                        size: 30, color: Colors.teal),
                  ),
                  Positioned(
                    left: 46,
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 48,
                        child: Text(
                            '${singleCourse.startWeek} - ${singleCourse.endWeek} ${singleCourse.weekTypeStr}周'),
                      ),
                      onTap: () {
                        WeekPicker.showWeekPicker(context,
                            startWeek: singleCourse.startWeek,
                            endWeek: singleCourse.endWeek,
                            weekType: singleCourse.weekType == 'A'
                                ? 0
                                : singleCourse.weekType == 'D' ? 2 : 1,
                            onConfirm: (startWeek, endWeek, weekType) {
                          singleCourse.startWeek = startWeek;
                          singleCourse.endWeek = endWeek;
                          singleCourse.weekType =
                              weekType == 0 ? 'A' : weekType == 2 ? 'D' : 'S';
                        });
                      },
                    ),
                  )
                ],
              ),
            ));
  }
}
