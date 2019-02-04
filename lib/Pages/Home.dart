import 'dart:core';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Pages/ImportTimetable.dart';
import 'package:glutassistant/Pages/Login.dart';
import 'package:glutassistant/Pages/QueryScore.dart';
import 'package:glutassistant/Pages/Timetable.dart';
import 'package:glutassistant/Utility/SharedPreferencesUtil.dart';

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //全局脚手架key
  int _selectIndex = 0;
  int _selectWeek = 1;
  int _currentWeek;
  String firstWeek = '1';
  String firstWeekTimestamp;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("image/0.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: _scaffoldKey,
        drawer: _getDrawer(),
        appBar: _getAppBar(),
        body: _getBodyView(),
      ),
    );
  }

  init() async {
    //计算今天是第几周
    await SharedPreferenceUtil.init();
    await SharedPreferenceUtil.getString('firstweek').then((onValue) {
      firstWeek = onValue == null ? '1' : onValue;
    });
    await SharedPreferenceUtil.getString('firstweektimestamp').then((onValue) {
      firstWeekTimestamp = onValue == null ? '1' : onValue;
    });
    _currentWeek = (DateTime.now().millisecondsSinceEpoch ~/ 1000 -
                int.parse(firstWeekTimestamp)) ~/
            604800 +
        int.parse(firstWeek);
    _currentWeek = _currentWeek > 25 ? 1 : _currentWeek;
    _selectWeek = _currentWeek;
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Widget _drawListItem(context, index) {
    if (index != 0 && index != 7) {
      return ListTile(
          leading: Icon(Constant.DRAWER_LIST_ICON[index]),
          title: Text(Constant.DRAWER_LIST_TITLE[index]),
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
      title: Text(Constant.DRAWER_LIST_TITLE[index],
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
            color: i + 1 == _selectWeek ? Color(0xFFFC0484) : Colors.white,
            alignment: Alignment.center,
            child: Text((i + 1).toString()),
          ),
        ),
      ));
    }
    return chooser;
  }

  Widget _getAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: GestureDetector(
        child: _getAppBarTitle(),
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

  Widget _getAppBarTitle() {
    if (_selectIndex != 2)
      return Text(Constant.DRAWER_LIST_TITLE[_selectIndex]);
    else
      return Text('第$_selectWeek周');
  }

  Widget _getBodyView() {
    switch (_selectIndex) {
      case 0:
        break;
      case 2:
        return new Timetable(_selectWeek);
        break;
      case 3:
        return new QueryScore();
      case 4:
        break;
      case 5:
        return new ImportTimetable();
      case 6:
        return new Login();
        break;
      default:
        break;
    }
  }

  Widget _getDrawer() {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
              accountEmail: Text('XX'),
              accountName: Text('XX'),
              margin: EdgeInsets.zero,
              currentAccountPicture: (CircleAvatar(
                  // backgroundImage: NetworkImage(
                  //     'https://upload.jianshu.io/users/upload_avatars/7700793/dbcf94ba-9e63-4fcf-aa77-361644dd5a87?imageMogr2/auto-orient/strip|imageView2/1/w/240/h/240'),
                  ))),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
                child: ListView.builder(
              itemCount: Constant.DRAWER_LIST_TITLE.length,
              itemBuilder: (context, index) => _drawListItem(context, index),
            )),
          ),
        ],
      ),
    );
  }
}
