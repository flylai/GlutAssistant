import 'package:flutter/material.dart';
import 'package:glutassistant/Model/Dashboard/TodayCourseListModel.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:provider/provider.dart';

class TomorrowCourseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildTomorrowCourseListNew();
  }

  Widget _buildTitle() {
    return Text(
      'Tomorrow',
      style: TextStyle(
        color: Colors.deepOrange,
      ),
    );
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
                    child: Text(
                        '${BaseFunctionUtil.getTimeByNum(item.startTime)} - ${BaseFunctionUtil.getTimeByNum(item.endTime)}节')),
                Text(
                  item.courseName,
                  style: TextStyle(fontSize: 20),
                )
              ],
            ));
        list.add(course);
      }
      return list.length == 1
          ? Container()
          : Container(
              child: Column(
              children: list,
            )); // 只有一个就是明天没课 不显示
    });
  }

  Widget _buildTomorrowCourseListNew() {
    return Consumer<TodayCourseList>(builder: (context, todayCourseList, _) {
      List<Widget> widgetList = [];
      widgetList..add(_buildTitle())..add(SizedBox(height: 10)); // 添加标题
      todayCourseList.tomorrowCourseList.forEach((item) => widgetList
        ..add(_buildTomorrowCourseRow(item.courseName,
            '${BaseFunctionUtil.getTimeByNum(item.startTime)} - ${BaseFunctionUtil.getTimeByNum(item.endTime)}节'))
        ..add(SizedBox(height: 5)));

      if (widgetList.length == 2) {
        // 只有标题和占位格子 / 明天没课
        widgetList.add(InkWell(
          child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 30,
              child: Text(
                '明天没有课上哦',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              )),
          onTap: () {},
        ));
      }

      return Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgetList,
        ),
      );
    });
  }

  Widget _buildTomorrowCourseRow(String course, String time) {
    return Row(
      children: <Widget>[
        CircleAvatar(
            maxRadius: 17,
            child: Text(
              course[0],
              style: TextStyle(fontSize: 16),
            ),
            foregroundColor: Colors.white,
            backgroundColor: BaseFunctionUtil.getRandomColor().withOpacity(1)),
        const SizedBox(width: 10.0),
        Text(
          time + '  ' + course,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
