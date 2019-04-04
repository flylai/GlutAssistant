import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Pages/About.dart';
import 'package:glutassistant/Pages/CourseModify.dart';
import 'package:glutassistant/Pages/CoursesManage.dart';
import 'package:glutassistant/Pages/Dashboard.dart';
import 'package:glutassistant/Pages/ImportTimetable.dart';
import 'package:glutassistant/Pages/Login.dart';
import 'package:glutassistant/Pages/QueryExaminationLocation.dart';
import 'package:glutassistant/Pages/QueryScore.dart';
import 'package:glutassistant/Pages/Settings.dart';
import 'package:glutassistant/Pages/Timetable.dart';
import 'package:glutassistant/Redux/State.dart';
import 'package:glutassistant/Redux/ThemeRedux.dart';
import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';
import 'package:redux/redux.dart';

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //全局脚手架key
  int _selectIndex = 1;
  int _selectWeek = 1;
  int _currentWeek = 1;
  int _themeIndex = 1;
  String _firstWeek = '1';
  String _firstWeekTimestamp = '1';
  String _image = '';
  Store<GlobalState> _store;
  bool _backgroundImageEnable = false;

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      _store = store;
      return Container(
        decoration: _backgroundImageEnable
            ? BoxDecoration(
                image: DecorationImage(
                  image: FileImage(
                      File(_image + '/' + Constant.FILE_BACKGROUND_IMG)),
                  fit: BoxFit.cover,
                ),
              )
            : null,
        child: Scaffold(
          backgroundColor:
              _backgroundImageEnable ? Colors.transparent : Colors.white,
          key: _scaffoldKey,
          drawer: _buildDrawer(),
          appBar: _buildAppBar(),
          body: _getBodyView(),
        ),
      );
    });
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: _backgroundImageEnable
          ? Colors.transparent
          : Theme.of(context).primaryColor,
      elevation: _backgroundImageEnable ? 0 : 4,
      actions: _buildAppBarActions(),
      title: GestureDetector(
        child: _buildAppBarTitle(),
        onTap: () {
          if (_selectIndex != 2) return; //是课程表界面的时候才能点
          showDialog(
              context: context,
              builder: (BuildContext ctx) {
                return Dialog(
                    child: Container(
                  height: 350,
                  width: 350,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                        child: Text(
                          '选择周次课表',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                        height: 300,
                        width: 300,
                        child: GridView.count(
                          crossAxisCount: 5,
                          primary: false,
                          children: _generateGridView(),
                        ),
                      ),
                    ],
                  ),
                ));
              });
        },
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_selectIndex == 9)
      return <Widget>[
        InkWell(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            alignment: Alignment.center,
            child: Text('添加课程'),
          ),
          onTap: () {
            Navigator.push(context,
                new MaterialPageRoute(builder: (BuildContext context) {
              return CourseModify();
            }));
          },
        ),
      ];
    return null;
  }

  Widget _buildAppBarTitle() {
    if (_selectIndex != 2)
      return Text(Constant.DRAWER_LIST[_selectIndex][0]);
    else if (_currentWeek != _selectWeek)
      return Text('第$_selectWeek周(非本周)');
    else
      return Text('第$_selectWeek周');
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
              accountName: Text('桂工助手'),
              accountEmail: Text('让你的桂工生活更为方便'),
              margin: EdgeInsets.zero,
              currentAccountPicture: (Image.asset('assets/images/logo.png'))),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
                child: ListView.builder(
              itemCount: Constant.DRAWER_LIST.length,
              itemBuilder: (context, index) => _buildListItem(context, index),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    if (index != 0 && index != 7) {
      return ListTile(
          leading: Icon(Constant.DRAWER_LIST[index][1]),
          title: Text(Constant.DRAWER_LIST[index][0]),
          dense: true,
          onTap: () {
            print(index);
            _selectWeek = _currentWeek;
            Navigator.pop(context);
            setState(() {
              _selectIndex = index;
            });
          });
    }
    return ListTile(
      title: Text(Constant.DRAWER_LIST[index][0],
          style: TextStyle(color: Colors.blue, fontSize: 12.0)),
    );
  }

  List<Widget> _generateGridView() {
    List<Widget> chooser = [];
    for (int i = 0; i < 25; i++) {
      chooser.add(Container(
        margin: EdgeInsets.all(3),
        decoration:
            BoxDecoration(border: Border.all(color: Colors.blue, width: 0.5)),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectWeek = i + 1;
            });
            Navigator.pop(context);
          },
          child: Container(
            color: i + 1 == _selectWeek ? Color(0xFFFC0484) : null,
            alignment: Alignment.center,
            child: Text((i + 1).toString(),
                style: TextStyle(
                  color: i + 1 == _selectWeek ? Colors.white : Colors.black,
                )),
          ),
        ),
      ));
    }
    return chooser;
  }

  Widget _getBodyView() {
    switch (_selectIndex) {
      case 1:
        return Dashboard();
      case 2:
        return Timetable(_currentWeek, _selectWeek, callback: (val) {
          print(val);
          setState(() {
            _selectWeek = val;
          });
        });
      case 3:
        return QueryScore();
      case 4:
        return QueryExaminationLocation();
      case 5:
        return ImportTimetable();
      case 6:
        return Login();
      case 8:
        return Settings();
      case 9:
        return CoursesManage();
      case 11:
        return About();

      default:
        break;
    }
    // return Dashboard(_currentWeek);
  }

  _init() async {
    //计算今天是第几周
    await FileUtil.init();
    _image = FileUtil.getDir();
    await SharedPreferenceUtil.init();
    _themeIndex = await SharedPreferenceUtil.getInt('theme_color');
    _themeIndex ??= 9;
    _store.dispatch(
        RefreshColorAction(Constant.THEME_LIST_COLOR[_themeIndex][1]));
    _backgroundImageEnable =
        await SharedPreferenceUtil.getBool('background_enable');
    _backgroundImageEnable ??= false;

    _firstWeek = await SharedPreferenceUtil.getString('first_week');
    _firstWeek ??= '1';
    _firstWeekTimestamp =
        await SharedPreferenceUtil.getString('first_week_timestamp');
    _firstWeekTimestamp ??= '1';

    DateTime _now = DateTime.now();
    DateTime _startWeek = DateTime(_now.year, _now.month, _now.day)
        .subtract(Duration(days: _now.weekday - 1));
    _currentWeek = (((_startWeek.millisecondsSinceEpoch / 1000 -
                    int.parse(_firstWeekTimestamp)) ~/
                25200 /
                24)
            .ceil() +
        int.parse(_firstWeek));
    setState(() {
      _currentWeek = _currentWeek > 25 ? 1 : _currentWeek;
    });
    _selectWeek = _currentWeek;
  }
}
