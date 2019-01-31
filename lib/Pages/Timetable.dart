import 'package:flutter/material.dart';

import 'dart:core';
import 'dart:math';

import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/HttpUtil.dart';
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';
import 'package:glutassistant/Utility/SQLiteUtil.dart';

class Timetable extends StatefulWidget {
  _TimetableState createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  List<Widget> mainTimetable = [];
  List<Widget> timetableMon = [];
  List<Widget> timetableTue = [];
  List<Widget> timetableWed = [];
  List<Widget> timetableThu = [];
  List<Widget> timetableFri = [];
  List<Widget> timetableSat = [];
  List<Widget> timetableSun = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  List<Widget> _gernerateDateText() {
    int weekday = DateTime.now().weekday;
    DateTime day = DateTime.now().subtract(Duration(days: weekday));
    List<Widget> datelist = [];
    var month = Expanded(
      child: Text('${DateTime.now().month.toString()}\n月',
          textAlign: TextAlign.center),
      flex: 1,
    );
    datelist.add(month);

    for (int i = 1; i <= 7; i++) {
      int today = day.add(Duration(days: i)).day;
      String todayStr = today == DateTime.now().day ? '今天' : today.toString();
      var wd = Expanded(
        child: Text(
          '${BaseFunctionUtil.getWeekdayByNum(i)}\n$todayStr',
          style: TextStyle(
              color: todayStr == '今天' ? Color(0xffEF3473) : Colors.black),
          textAlign: TextAlign.center,
        ),
        flex: 2,
      );
      datelist.add(wd);
    }
    return datelist;
  }

  Widget _buildDateList() {
    return Row(
      children: _gernerateDateText(),
    );
  }

  Future init() async {
    await SQLiteUtil.init();
    await _buildTimetable();
  }

  Future _buildTimetable() async {
    mainTimetable.clear();
    mainTimetable.add(_buildLeftTimeList());
    List<List<Widget>> list = [
      timetableMon,
      timetableTue,
      timetableWed,
      timetableThu,
      timetableFri,
      timetableSat,
      timetableSun
    ];
    for (int i = 0; i < 7; i++) {
      list[i].clear();
      int count = 1;
      await SQLiteUtil.queryCourse(1, i + 1).then((onValue) {
        if (onValue.length > 0) {
          for (int j = 0; j < onValue.length; j++) {
            int startTime = onValue[j]['startTime'];
            int endTime = onValue[j]['endTime'];
            if (count < startTime) {
              Container item = Container(
                margin: EdgeInsets.fromLTRB(0.5, 0.5, 0.5, 0.5),
                height: ((startTime - count) * Constant.VAR_COURSE_HEIGHT),
              );
              list[i].add(item);
              count += startTime - count;
            }
            if (count > startTime) continue;

            int colorNum = (Random().nextInt(Constant.VAR_COLOR.length - 1) +
                    Random().nextInt(Constant.VAR_COLOR.length + 1)) ~/
                2; //换个写法随机..
            Container item = Container(
              padding: EdgeInsets.all(2),
              margin: EdgeInsets.fromLTRB(0.5, 0.5, 0.5, 0.5),
              color: Color(Constant.VAR_COLOR[colorNum]).withOpacity(0.7),
              alignment: Alignment.topLeft,
              height: Constant.VAR_COURSE_HEIGHT * (endTime - startTime + 1),
              child:
                  Text('${onValue[j]['courseName']}@${onValue[j]['location']}'),
            );
            list[i].add(item);
            count += endTime - startTime + 1;
          }
        } else {
          Container item = Container(
            height: Constant.VAR_COURSE_HEIGHT,
          );
          list[i].add(item);
        }
      });
      setState(() {
        mainTimetable.add(Expanded(
          child: Column(
            children: list[i],
          ),
          flex: 2,
        ));
      });
    }
  }

  Widget _buildLeftTimeList() {
    List<Widget> timelist = [];
    for (int i = 1; i < 15; i++) {
      String _i;
      if (i > 4 && i < 7)
        _i = '中午${i - 4}';
      else if (i > 6)
        _i = (i - 2).toString();
      else
        _i = i.toString();
      Container item = Container(
        color: Colors.white,
        alignment: Alignment.center,
        height: Constant.VAR_COURSE_HEIGHT,
        child: Text(
          _i,
          textAlign: TextAlign.center,
        ),
      );
      timelist.add(Divider(
        height: 0.6,
      ));
      timelist.add(item);
    }
    return Expanded(
      child: Column(
        children: timelist,
      ),
      flex: 1,
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        _buildDateList(),
        Expanded(
          child: ListView(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: mainTimetable,
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _buildBody());
  }
}
