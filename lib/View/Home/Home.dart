import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Model/CourseManage/CourseModel.dart';
import 'package:glutassistant/Model/GlobalData.dart';
import 'package:glutassistant/View/About/About.dart';
import 'package:glutassistant/View/CourseManage/CourseManage.dart';
import 'package:glutassistant/View/CourseManage/CourseModify.dart';
import 'package:glutassistant/View/Dashboard/Dashboard.dart';
import 'package:glutassistant/View/ImportTimetable/ImportTimetable.dart';
import 'package:glutassistant/View/Login/Login.dart';
import 'package:glutassistant/View/QueryExamLocation/QueryExamLocation.dart';
import 'package:glutassistant/View/QueryScore/QueryScore.dart';
import 'package:glutassistant/View/Settings/Settings.dart';
import 'package:glutassistant/View/Timetable/Timetable.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalData>(builder: (context, globalData, _) {
      return Container(
        decoration: globalData.backgroundEnable == BackgroundImage.enable
            ? BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(
                      '/data/data/com.lkm.glutassistant/app_flutter/' +
                          Constant.FILE_BACKGROUND_IMG)),
                  fit: BoxFit.cover,
                ),
              )
            : null,
        child: Scaffold(
          backgroundColor: globalData.backgroundEnable == BackgroundImage.enable
              ? Colors.transparent
              : Colors.white,
          // key: _scaffoldKey,
          drawer: _buildDrawer(),
          appBar: _buildAppBar(context, globalData),
          body: _getBodyView(),
        ),
      );
    });
  }

  Widget _buildAppBar(BuildContext context, GlobalData globalData) {
    return AppBar(
      bottom: _buildAppBarBottom(context, globalData),
      backgroundColor: globalData.backgroundEnable == BackgroundImage.enable
          ? Colors.transparent
          : Theme.of(context).primaryColor,
      elevation: globalData.backgroundEnable == BackgroundImage.enable ? 0 : 4,
      actions: _buildAppBarActions(context, globalData),
      title: GestureDetector(
        child: _buildAppBarTitle(),
        onTap: () {
          if (globalData.selectedPage != 2) return; //是课程表界面的时候才能点
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
                      _buildGridView(),
                    ],
                  ),
                ));
              });
        },
      ),
      // )
    );
  }

  List<Widget> _buildAppBarActions(
      BuildContext context, GlobalData globalData) {
    if (globalData.selectedPage == 9)
      return <Widget>[
        InkWell(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            alignment: Alignment.center,
            child: Text('添加课程'),
          ),
          onTap: () {
            SingleCourse singleCourse = SingleCourse();
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return CourseModify(singleCourse, type: 0);
            }));
          },
        ),
      ];
    return null;
  }

  Widget _buildAppBarBottom(BuildContext context, GlobalData globalData) {
    if (globalData.selectedPage == 3)
      return PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: Row(
          children: <Widget>[
            Expanded(
                child: InkWell(
                    onTap: () {
                      globalData.scoreType = ScoreType.exam;
                    },
                    child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        child: Text(
                          '课程成绩',
                          style: TextStyle(
                              fontSize: 17,
                              color: Theme.of(context).primaryColorBrightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white),
                        )))),
            Expanded(
                child: InkWell(
                    onTap: () {
                      globalData.scoreType = ScoreType.fitness;
                    },
                    child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        child: Text(
                          '体侧成绩',
                          style: TextStyle(
                              fontSize: 17,
                              color: Theme.of(context).primaryColorBrightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white),
                        ))))
          ],
        ),
      );
    return null;
  }

  Widget _buildAppBarTitle() {
    return Consumer<GlobalData>(builder: (context, globalData, _) {
      if (globalData.selectedPage != 2)
        return Text(Constant.LIST_DRAWER[globalData.selectedPage][0]);
      else if (globalData.currentWeek != globalData.selectedWeek)
        return Text('第${globalData.selectedWeek}周(非本周)');
      else
        return Text('第${globalData.selectedWeek}周');
    });
  }

  Widget _buildDrawer() {
    return Consumer<GlobalData>(
        builder: (context, globalData, _) => Drawer(
              child: Column(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                      accountName: Text('桂工助手'),
                      accountEmail: Text('让你的桂工生活更为方便'),
                      margin: EdgeInsets.zero,
                      currentAccountPicture:
                          (Image.asset('assets/images/logo.png'))),
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Expanded(
                        child: ListView.builder(
                      itemCount: Constant.LIST_DRAWER.length,
                      itemBuilder: (context, index) =>
                          _buildListItem(context, index),
                    )),
                  ),
                ],
              ),
            ));
  }

  Widget _buildListItem(BuildContext context, int index) {
    return Consumer<GlobalData>(builder: (context, globalData, _) {
      if (index != 0 && index != 7) {
        return ListTile(
            leading: Icon(Constant.LIST_DRAWER[index][1]),
            title: Text(Constant.LIST_DRAWER[index][0]),
            dense: true,
            onTap: () {
              print(index);
              globalData.selectedWeek = globalData.currentWeek;
              Navigator.pop(context);
              globalData.selectedPage = index;
            });
      }
      return ListTile(
        title: Text(Constant.LIST_DRAWER[index][0],
            style: TextStyle(color: Colors.blue, fontSize: 12.0)),
      );
    });
  }

  Widget _buildGridView() {
    return Consumer<GlobalData>(builder: (context, globalData, _) {
      List<Widget> chooser = [];
      for (int i = 0; i < 25; i++) {
        chooser.add(Container(
          margin: EdgeInsets.all(3),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.blue, width: 0.5)),
          child: InkWell(
            onTap: () {
              globalData.selectedWeek = i + 1;

              Navigator.pop(context);
            },
            child: Container(
              color:
                  i + 1 == globalData.selectedWeek ? Color(0xFFFC0484) : null,
              alignment: Alignment.center,
              child: Text((i + 1).toString(),
                  style: TextStyle(
                    color: i + 1 == globalData.selectedWeek
                        ? Colors.white
                        : Colors.black,
                  )),
            ),
          ),
        ));
      }
      return Container(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        height: 300,
        width: 300,
        child: GridView.count(
          crossAxisCount: 5,
          primary: false,
          children: chooser,
        ),
      );
    });
  }

  Widget _getBodyView() {
    return Consumer<GlobalData>(builder: (context, globalData, _) {
      switch (globalData.selectedPage) {
        case 1:
          return Dashboard();
        case 2:
          return Timetable(globalData.selectedWeek, globalData.currentWeek);
        case 3:
          return QueryScore();
        case 4:
          return QueryExamLocation();
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
          return Dashboard();
      }
    });
  }
}
