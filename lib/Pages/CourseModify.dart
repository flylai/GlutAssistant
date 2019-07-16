import 'package:flutter/material.dart';
import 'package:glutassistant/Utility/BaseFunctionUtil.dart';
import 'package:glutassistant/Utility/SQLiteUtil.dart';
import 'package:glutassistant/Widget/TimePicker.dart';
import 'package:glutassistant/Widget/WeekPicker.dart';

class CourseModify extends StatefulWidget {
  final int no;
  final String courseName;
  final Color color;
  final int startWeek;
  final int endWeek;
  final String weekType;
  final int weekday;
  final int startTime;
  final int endTime;
  final String teacher;
  final String location;

  CourseModify(
      {Key key,
      this.no,
      this.courseName = '',
      this.color,
      this.weekday = 1,
      this.startWeek = 1,
      this.endWeek = 1,
      this.weekType = 'A',
      this.startTime = 1,
      this.endTime = 1,
      this.teacher = '',
      this.location = ''})
      : super(key: key);
  @override
  _CourseModifyState createState() => _CourseModifyState();
}

class _CourseModifyState extends State<CourseModify> {
  int _no;
  int _type = 1; //0添加 1修改
  String _weekType;
  int _weekday, _startTime, _endTime, _startWeek, _endWeek;
  Color _color; //TODO: 课程颜色，待添加
  TextEditingController _courseNameController = TextEditingController();
  TextEditingController _teacherController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_type == 0 ? '添加课程' : '修改课程')),
      body: Container(
        child: ListView(
          children: <Widget>[
            _buildCourseNameEdit(),
            _buildWeek(),
            _buildTime(),
            _buildTeacherEdit(),
            _buildLocationEdit(),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  void initState() {
    _init();
    super.initState();
  }

  Widget _buildCourseNameEdit() {
    return Container(
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: _courseNameController,
          decoration: InputDecoration(
              icon: Icon(Icons.book, size: 30, color: Colors.amber),
              hintText: '课程名称'),
        ));
  }

  Widget _buildLocationEdit() {
    return Container(
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: _locationController,
          decoration: InputDecoration(
              icon: Icon(Icons.location_on, size: 30, color: Colors.pink),
              hintText: '上课地点'),
        ));
  }

  Widget _buildSaveButton() {
    return Container(
      width: 120,
      padding: EdgeInsets.all(10),
      child: FlatButton(
        shape: Border.all(color: Colors.blue),
        onPressed: () async {
          Map<String, dynamic> courseDetail = new Map();
          courseDetail['courseName'] = _courseNameController.text;
          courseDetail['teacher'] = _teacherController.text;
          courseDetail['startWeek'] = _startWeek;
          courseDetail['endWeek'] = _endWeek;
          courseDetail['weekType'] = _weekType;
          courseDetail['weekday'] = _weekday;
          courseDetail['startTime'] = _startTime;
          courseDetail['endTime'] = _endTime;
          courseDetail['location'] = _locationController.text;
          print(_no);
          if (_type == 1)
            await SQLiteUtil.updateCourse(_no, courseDetail);
          else
            await SQLiteUtil.insertTimetable(courseDetail);
          Navigator.of(context).pop();
        },
        child: Text('保存'),
      ),
    );
  }

  Widget _buildTeacherEdit() {
    return Container(
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: _teacherController,
          decoration: InputDecoration(
              icon: Icon(Icons.person, size: 30, color: Colors.purple),
              hintText: '教师'),
        ));
  }

  Widget _buildTime() {
    return Container(
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
                    '星期${BaseFunctionUtil().getWeekdayByNum(_weekday)}  第 ${BaseFunctionUtil().getTimeByNum(_startTime)} 至 ${BaseFunctionUtil().getTimeByNum(_endTime)} 节'),
              ),
              onTap: () => {
                    TimePicker.showTimePicker(
                      context,
                      showTitleActions: true,
                      initialWeekday: _weekday,
                      initialStartTime: _startTime,
                      initialEndTime: _endTime,
                      confirm: Text(
                        '确定',
                        style: TextStyle(color: Colors.red),
                      ),
                      cancel: Text(
                        '取消',
                        style: TextStyle(color: Colors.cyan),
                      ),
                      onConfirm: (weekday, starttime, endtime) {
                        setState(() {
                          _weekday = weekday;
                          _startTime = starttime;
                          _endTime = endtime;
                        });
                      },
                    )
                  },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWeek() {
    return Container(
      padding: EdgeInsets.all(10),
      height: 68,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Positioned(
            left: 0,
            child: Icon(Icons.calendar_today, size: 30, color: Colors.teal),
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
                    '$_startWeek - $_endWeek ${_weekType == 'A' ? '全' : _weekType == 'D' ? '双' : '单'}周'),
              ),
              onTap: () {
                WeekPicker.showWeekPicker(context,
                    startWeek: _startWeek,
                    endWeek: _endWeek,
                    weekType: _weekType == 'A' ? 0 : _weekType == 'D' ? 2 : 1,
                    onConfirm: (startweek, endweek, weektype) {
                  setState(() {
                    _startWeek = startweek;
                    _endWeek = endweek;
                    _weekType = weektype == 0 ? 'A' : weektype == 2 ? 'D' : 'S';
                  });
                });
              },
            ),
          )
        ],
      ),
    );
  }

  _init() {
    _courseNameController.text = widget.courseName;
    _teacherController.text = widget.teacher;
    _locationController.text = widget.location;
    _no = widget.no;
    if (widget.courseName == '' &&
        widget.teacher == '' &&
        widget.location == '') {
      _type = 0;
    }
    setState(() {
      _weekday ??= widget.weekday;
      _startTime ??= widget.startTime;
      _endTime ??= widget.endTime;
      _startWeek ??= widget.startWeek;
      _endWeek ??= widget.endWeek;
      _weekType ??= widget.weekType;
    });
  }
}
