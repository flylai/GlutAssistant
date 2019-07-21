import 'package:flutter/material.dart';

import 'package:glutassistant/Model/CourseManage/CourseModel.dart';
import 'package:glutassistant/Model/CourseManage/CoursePoolModel.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/Pages/CourseModify.dart';
import 'package:glutassistant/Utility/SQLiteUtil2.dart';
import 'package:glutassistant/Widget/DetailCard.dart';
import 'package:provider/provider.dart';

class CoursesManage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CoursePool>(
        builder: (context) => CoursePool(),
        child: Container(
          child: _buildBody(),
        ));
  }

  Widget _buildBody() {
    return Consumer<CoursePool>(builder: (context, coursePool, _) {
      coursePool.init();
      return ListView.builder(
          itemCount: coursePool.courses.length,
          itemBuilder: (context, index) {
            SingleCourse sc = coursePool.courses[index];
            return ChangeNotifierProvider<SingleCourse>.value(
              value: sc,
              child: _buildCourseItem(),
            );
          });
    });
  }

  Widget _buildCourseItem() {
    return Consumer2<SingleCourse, GlobalData>(
        builder: (context, singleCourse, globalData, _) {
      Widget child = Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${singleCourse.courseName}',
                  style: TextStyle(fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
                Text('${singleCourse.teacher}'),
                Text(
                    '${singleCourse.startWeek} - ${singleCourse.endWeek} ${singleCourse.weekTypeStr}周 星期${singleCourse.weekdayStr} ${singleCourse.startTime} - ${singleCourse.endTime}节'),
                Text('${singleCourse.location}'),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                child: Icon(Icons.create, size: 30, color: Colors.cyan),
                onTap: () => _modifyCourse(
                    context,
                    singleCourse.courseNo,
                    singleCourse.courseName,
                    singleCourse.startWeek,
                    singleCourse.endWeek,
                    singleCourse.weekType,
                    singleCourse.weekday,
                    singleCourse.startTime,
                    singleCourse.endTime,
                    singleCourse.teacher,
                    singleCourse.location),
              ),
              GestureDetector(
                child: Icon(Icons.delete_forever,
                    size: 30, color: Colors.redAccent),
                onTap: () => _deleteCourse(
                    context, singleCourse.courseNo, singleCourse.courseName),
              )
            ],
          )
        ],
      ));
      return DetailCard(
        Colors.white,
        child,
        elevation: 0,
        height: 95,
        opacity: globalData.opacity,
      );
    });
  }

  void _deleteCourse(BuildContext context, int no, String courseName) async {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Text('确定要删除《$courseName》吗？'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    SQLiteUtil su = await SQLiteUtil.getInstance();
                    await su.deleteCourse(no);
                    Navigator.pop(context);
                  },
                  child: Text('确定')),
              FlatButton(
                  onPressed: () => Navigator.pop(context), child: Text('手抖点错了'))
            ],
          );
        });
  }

  void _modifyCourse(
      BuildContext context,
      int no,
      String courseName,
      int startWeek,
      int endWeek,
      String weekType,
      int weekday,
      int startTime,
      int endTime,
      String teacher,
      String location) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return CourseModify(
          no: no,
          courseName: courseName,
          startWeek: startWeek,
          endWeek: endWeek,
          weekType: weekType,
          weekday: weekday,
          startTime: startTime,
          endTime: endTime,
          teacher: teacher,
          location: location);
    }));
  }
}
