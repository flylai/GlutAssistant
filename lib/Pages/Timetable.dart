import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:glutassistant/Utility/SQLiteUtil.dart';

class Timetable extends StatefulWidget {
  final int _week;
  Timetable(this._week);
  @override
  _TimetableState createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  static int _preweek = 1;
  List<Widget> mainTimetable = [];
  List<Widget> timetableMon = [];
  List<Widget> timetableTue = [];
  List<Widget> timetableWed = [];
  List<Widget> timetableThu = [];
  List<Widget> timetableFri = [];
  List<Widget> timetableSat = [];
  List<Widget> timetableSun = []; //防止死循环

  @override
  Widget build(BuildContext context) {
    _buildTimetable(widget._week);
    return Container(child: _buildBody());
  }

  Future init() async {
    _preweek = widget._week - 1;
    await SQLiteUtil.init();
    await _buildTimetable(widget._week);
  }

  @override
  void initState() {
    super.initState();
    init();
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

  Widget _buildDateList() {
    return Row(
      children: _gernerateDateText(),
    );
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

  Future _buildTimetable(int week) async {
    if (week == _preweek || !SQLiteUtil.dbIsOpen()) return;
    _preweek = week;
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
      await SQLiteUtil.queryCourse(widget._week, i + 1).then((onValue) {
        if (onValue.length > 0) {
          for (int j = 0; j < onValue.length; j++) {
            int startTime = onValue[j]['startTime'];
            int endTime = onValue[j]['endTime'];
            if (count < startTime) {
              Container item = Container(
                margin: EdgeInsets.fromLTRB(
                    0.5, 0.5 * (startTime - count - 1), 0.5, 0.5),
                height: ((startTime - count) * Constant.VAR_COURSE_HEIGHT),
              );
              list[i].add(item);
              count += startTime - count;
            }
            if (count > startTime) continue;

            int colorNum =
                Random.secure().nextInt(Constant.VAR_COLOR.length); //随机颜色
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
}
