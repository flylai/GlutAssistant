import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Pages/CourseModify.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:glutassistant/Utility/SQLiteUtil.dart';
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';
import 'package:glutassistant/Widget/DetailCard.dart';

class CoursesManage extends StatefulWidget {
  @override
  _CoursesManageState createState() => _CoursesManageState();
}

class _CoursesManageState extends State<CoursesManage> {
  List<Map<String, dynamic>> _courseList = [];
  double _opacity = Constant.VAR_DEFAULT_OPACITY;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView(
      children: _buildBody(),
    ));
  }

  void initState() {
    _init();
    super.initState();
  }

  List<Widget> _buildBody() {
    List<Widget> mainBody = [];
    for (var item in _courseList) {
      Widget child = Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${item['courseName']}',
                  style: TextStyle(fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
                Text('${item['teacher']}'),
                Text(
                    '${item['startWeek']} - ${item['endWeek']} ${item['weekType'] == 'A' ? '全' : item['weekType'] == 'D' ? '双' : '单'}周 星期${BaseFunctionUtil.getWeekdayByNum(item['weekday'])} ${BaseFunctionUtil.getTimeByNum(item['startTime'])} - ${BaseFunctionUtil.getTimeByNum(item['endTime'])}节'),
                Text('${item['location'] == '' ? '未知地点' : item['location']}'),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                child: Icon(Icons.create, size: 30, color: Colors.cyan),
                onTap: () => _modifyCourse(
                    item['No'],
                    item['courseName'],
                    item['startWeek'],
                    item['endWeek'],
                    item['weekType'],
                    item['weekday'],
                    item['startTime'],
                    item['endTime'],
                    item['teacher'],
                    item['location']),
              ),
              GestureDetector(
                child: Icon(Icons.delete_forever,
                    size: 30, color: Colors.redAccent),
                onTap: () => _deleteCourse(item['No'], item['courseName']),
              )
            ],
          )
        ],
      ));
      mainBody.add(DetailCard(
        Colors.white,
        child,
        elevation: 0,
        height: 95,
        opacity: _opacity,
      ));
    }
    print(_opacity);
    return mainBody;
  }

  void _deleteCourse(int no, String courseName) async {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Text('确定要删除《$courseName》吗？'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    await SQLiteUtil.deleteCourse(no);
                    Navigator.pop(context);
                  },
                  child: Text('确定')),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('手抖点错了'))
            ],
          );
        });
  }

  _init() async {
    await SQLiteUtil.init();
    await SharedPreferenceUtil.init();
    _opacity = await SharedPreferenceUtil.getDouble('opacity');
    _opacity ??= Constant.VAR_DEFAULT_OPACITY;
    await SQLiteUtil.queryCourseList().then((onValue) {
      if (onValue.length > 0) {
        for (int i = 0; i < onValue.length; i++) {
          _courseList.add(onValue[i]);
        }
      }
    });
    setState(() {
      _courseList;
    });
  }

  void _modifyCourse(
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
    Navigator.push(context,
        new MaterialPageRoute(builder: (BuildContext context) {
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
