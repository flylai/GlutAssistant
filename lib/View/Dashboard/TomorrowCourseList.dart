import 'package:flutter/material.dart';
import 'package:glutassistant/Model/Dashboard/TodayCourseListModel.dart';
import 'package:provider/provider.dart';

class TomorrowCourseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildTomorrowCourseList();
  }

  Widget _buildTomorrowCourseList() {
    return Consumer<TodayCourseList>(builder: (context, todayCourseList, _) {
      if (!todayCourseList.isTodayCourseOver) return Container(); // 今天课没上完就不显示
      List<Widget> list = [];
      list.add(Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(10),
          child: Text(
            '明天的课程:',
            style: TextStyle(fontSize: 18),
          )));
      for (var item in todayCourseList.tomorrowCourseList) {
        var course = Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Color.fromARGB(102, 0, 150, 255),
                    offset: Offset(1.5, 1.5),
                    blurRadius: 3.0),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 8, 0),
                  height: 60,
                  width: 10,
                  color: Color.fromARGB(255, 0, 120, 215),
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Text('${item['startTime']} - ${item['endTime']}节')),
                Text(
                  item['courseName'],
                  style: TextStyle(fontSize: 20),
                )
              ],
            ));
        list.add(course);
      }
      return list.length == 1
          ? Container()
          : Container(
              child: ListView(
              children: list,
              shrinkWrap: true,
            )); // 只有一个就是明天没课 不显示
    });
  }
}
